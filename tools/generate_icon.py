"""
tools/generate_icon.py — Pavlovian app-icon generator.

Renders the hand-drawn bell (same paths as lib/views/components/bell_icon.dart)
into two PNG sources used by flutter_launcher_icons:

    assets/icon/pavlovian_icon.png     1024x1024  paper bg + bell  (legacy launcher)
    assets/icon/pavlovian_icon_fg.png  1024x1024  bell only        (adaptive foreground)

Usage (run from project root):
    pip install Pillow            # one-time
    python tools/generate_icon.py
    dart run flutter_launcher_icons   # generates all mipmap sizes
"""

import os
from PIL import Image, ImageDraw

# ── Colors (from lib/theme/app_theme.dart) ────────────────────────
PAPER       = (251, 247, 238, 255)   # #FBF7EE
INK         = (42,  39,  35,  255)   # #2A2723
TERRA       = (232, 160, 122, 255)   # #E8A07A
TERRA_25    = (232, 160, 122, 64)    # 25 % alpha
TERRA_50    = (232, 160, 122, 128)   # 50 % alpha
INK_30      = (42,  39,  35,  76)    # 30 % alpha (inner highlight)

# ── Canvas sizing ────────────────────────────────────────────────
SIZE_LEGACY  = 1024   # output PNG dimensions
# The SVG paths in bell_icon.dart use an 80x80 coordinate space.
# `BELL_SPAN` controls how much of the canvas the bell occupies.
SVG_VIEWBOX = 80


# ── Bezier samplers ──────────────────────────────────────────────
def cubic(p0, p1, p2, p3, n=40):
    pts = []
    for i in range(n + 1):
        t = i / n
        u = 1 - t
        x = u**3 * p0[0] + 3 * u*u*t * p1[0] + 3 * u*t*t * p2[0] + t**3 * p3[0]
        y = u**3 * p0[1] + 3 * u*u*t * p1[1] + 3 * u*t*t * p2[1] + t**3 * p3[1]
        pts.append((x, y))
    return pts


def quadratic(p0, p1, p2, n=20):
    pts = []
    for i in range(n + 1):
        t = i / n
        u = 1 - t
        x = u*u * p0[0] + 2 * u*t * p1[0] + t*t * p2[0]
        y = u*u * p0[1] + 2 * u*t * p1[1] + t*t * p2[1]
        pts.append((x, y))
    return pts


# ── Bell drawer ──────────────────────────────────────────────────
def draw_bell(img: Image.Image, bell_span: float, offset: tuple[float, float]):
    """
    Draw the bell into `img`. `bell_span` = how many pixels the
    80×80 SVG box maps to. `offset` = top-left of the bell on the canvas.
    """
    draw = ImageDraw.Draw(img, "RGBA")
    scale = bell_span / SVG_VIEWBOX
    ox, oy = offset

    def s(p):
        return (p[0] * scale + ox, p[1] * scale + oy)

    # ── Bell body — concatenate cubics into one closed polygon ──
    body = [s((40, 10))]
    body += [s(p) for p in cubic((40, 10), (26, 10), (18, 22), (17, 36))[1:]]
    body += [s(p) for p in cubic((17, 36), (16, 46), (14, 52), (10, 58))[1:]]
    body.append(s((70, 58)))
    body += [s(p) for p in cubic((70, 58), (66, 52), (64, 46), (63, 36))[1:]]
    body += [s(p) for p in cubic((63, 36), (62, 22), (54, 10), (40, 10))[1:]]

    # Fill with translucent terracotta
    draw.polygon(body, fill=TERRA_25)

    # Outline stroke
    stroke_w = max(1, round(2.5 * scale))
    # ImageDraw.line drawing a list of points draws straight segments
    # between consecutive points. Closing the loop manually.
    draw.line(body + [body[0]], fill=INK, width=stroke_w, joint="curve")

    # ── Bell top stem ──
    stem = [s(p) for p in cubic((37, 10), (37, 7), (43, 7), (43, 10))]
    draw.line(stem, fill=INK, width=max(1, round(2 * scale)), joint="curve")

    # ── Clapper circle (filled + stroked) ──
    cx, cy = s((40, 64))
    r = 4.5 * scale
    draw.ellipse([cx - r, cy - r, cx + r, cy + r],
                 fill=TERRA_50,
                 outline=INK,
                 width=max(1, round(2 * scale)))

    # ── Motion dashes both sides (dashed = sample then skip) ──
    def dashed(points, on=4, off=4):
        i = 0
        while i + on < len(points):
            draw.line(points[i:i + on + 1], fill=INK,
                      width=max(1, round(1.5 * scale)))
            i += on + off

    dashed([s(p) for p in cubic((68, 30), (72, 28), (74, 24), (73, 20), 24)])
    dashed([s(p) for p in cubic((12, 30), (8,  28), (6,  24), (7,  20), 24)])

    # ── Inner highlight squiggle ──
    hl = [s(p) for p in quadratic((30, 38), (36, 34), (42, 38))]
    hl += [s(p) for p in quadratic((42, 38), (48, 42), (52, 38))[1:]]
    draw.line(hl, fill=INK_30, width=max(1, round(1 * scale)), joint="curve")


# ── Output drivers ───────────────────────────────────────────────
def generate_legacy(out_path: str):
    """Square 1024x1024 with paper bg + centred bell. Used for legacy icon."""
    img = Image.new("RGBA", (SIZE_LEGACY, SIZE_LEGACY), PAPER)

    # Bell takes ~75 % of canvas — leaves a 12 % paper margin all round
    bell_span = SIZE_LEGACY * 0.75
    offset = ((SIZE_LEGACY - bell_span) / 2,
              (SIZE_LEGACY - bell_span) / 2)
    draw_bell(img, bell_span, offset)
    img.save(out_path, "PNG")
    print(f"  [ok] {out_path}  ({SIZE_LEGACY}x{SIZE_LEGACY})")


def generate_adaptive_fg(out_path: str):
    """
    Foreground PNG for adaptive icons. Bell is drawn smaller and
    centred so it sits comfortably inside the adaptive-icon SAFE
    ZONE (centre 66 % of canvas). No background — kept transparent.
    """
    img = Image.new("RGBA", (SIZE_LEGACY, SIZE_LEGACY), (0, 0, 0, 0))
    # Bell at 55 % to stay inside the safe zone even when the OS
    # crops to a circle or rounded square.
    bell_span = SIZE_LEGACY * 0.55
    offset = ((SIZE_LEGACY - bell_span) / 2,
              (SIZE_LEGACY - bell_span) / 2)
    draw_bell(img, bell_span, offset)
    img.save(out_path, "PNG")
    print(f"  [ok] {out_path}  ({SIZE_LEGACY}x{SIZE_LEGACY})")


def main():
    out_dir = os.path.join("assets", "icon")
    os.makedirs(out_dir, exist_ok=True)
    print("Generating Pavlovian app icons...")
    generate_legacy(os.path.join(out_dir, "pavlovian_icon.png"))
    generate_adaptive_fg(os.path.join(out_dir, "pavlovian_icon_fg.png"))
    print("Done. Next:")
    print("  dart run flutter_launcher_icons")


if __name__ == "__main__":
    main()
