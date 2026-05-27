"""
tools/generate_sounds.py — Pavlovian sound generator.

Writes 4 short synthetic notification sounds to assets/sounds/ using
only the Python standard library (wave + struct + math) — no Pillow
or other deps required.

Output files (all 16-bit PCM mono WAV, 44.1 kHz):
    assets/sounds/chime.wav   ~0.8 s  G5 + B5 ascending two-tone (default)
    assets/sounds/bell.wav    ~1.2 s  A4 with harmonic overtones
    assets/sounds/ping.wav    ~0.3 s  short high E6 ping
    assets/sounds/soft.wav    ~1.0 s  mellow C4 with fifth

Usage (run from project root):
    python tools/generate_sounds.py
"""

import math
import os
import struct
import wave

SAMPLE_RATE = 44100  # Hz
PEAK = 28000         # 16-bit signed max is 32767 — leave headroom


def envelope(t: float, attack: float, release: float, peak: float = 1.0) -> float:
    """Linear attack, exponential release. Returns amplitude in [0..peak]."""
    if t < attack:
        return (t / attack) * peak
    return peak * math.exp(-(t - attack) / release)


def write_wav(path: str, samples: list[int]) -> None:
    """Write 16-bit signed mono PCM WAV to `path`."""
    with wave.open(path, "w") as w:
        w.setnchannels(1)
        w.setsampwidth(2)       # 16-bit
        w.setframerate(SAMPLE_RATE)
        # Pack all samples as little-endian signed 16-bit
        data = struct.pack("<" + "h" * len(samples), *samples)
        w.writeframes(data)


# ── Sound generators ─────────────────────────────────────────────
def gen_chime() -> list[int]:
    """Pleasant chime: G5 + B5 two-tone, gentle decay."""
    duration = 0.8
    f1, f2 = 783.99, 987.77   # G5, B5 (a major-third chord)
    out = []
    n = int(duration * SAMPLE_RATE)
    for i in range(n):
        t = i / SAMPLE_RATE
        env = envelope(t, attack=0.005, release=0.30)
        s = 0.45 * math.sin(2 * math.pi * f1 * t) \
          + 0.35 * math.sin(2 * math.pi * f2 * t)
        out.append(int(s * env * PEAK))
    return out


def gen_bell() -> list[int]:
    """Deeper bell: A4 fundamental with 2x and 3x harmonics, long decay."""
    duration = 1.2
    f = 440.0                  # A4
    out = []
    n = int(duration * SAMPLE_RATE)
    for i in range(n):
        t = i / SAMPLE_RATE
        env = envelope(t, attack=0.003, release=0.65)
        s = (0.50 * math.sin(2 * math.pi * f * t)
           + 0.22 * math.sin(2 * math.pi * f * 2 * t)
           + 0.10 * math.sin(2 * math.pi * f * 3 * t))
        out.append(int(s * env * PEAK))
    return out


def gen_ping() -> list[int]:
    """Quick high ping: E6 with very fast decay."""
    duration = 0.3
    f = 1318.51                # E6
    out = []
    n = int(duration * SAMPLE_RATE)
    for i in range(n):
        t = i / SAMPLE_RATE
        env = envelope(t, attack=0.002, release=0.10)
        s = math.sin(2 * math.pi * f * t)
        out.append(int(s * env * PEAK))
    return out


def gen_soft() -> list[int]:
    """Mellow soft tone: C4 + fifth, slow attack."""
    duration = 1.0
    f = 261.63                 # C4
    out = []
    n = int(duration * SAMPLE_RATE)
    for i in range(n):
        t = i / SAMPLE_RATE
        env = envelope(t, attack=0.05, release=0.40)
        s = (0.55 * math.sin(2 * math.pi * f * t)
           + 0.25 * math.sin(2 * math.pi * f * 1.5 * t))
        out.append(int(s * env * PEAK))
    return out


def main() -> None:
    # Flutter assets dir — used by audioplayers for in-app preview.
    assets_dir = os.path.join("assets", "sounds")
    os.makedirs(assets_dir, exist_ok=True)

    # Android raw resources dir — used by notification channels.
    # Naming rules: lowercase, [a-z0-9_], must start with a letter.
    raw_dir = os.path.join("android", "app", "src", "main", "res", "raw")
    os.makedirs(raw_dir, exist_ok=True)

    print("Generating Pavlovian alert sounds...")
    sounds = [
        ("chime.wav", gen_chime),
        ("bell.wav",  gen_bell),
        ("ping.wav",  gen_ping),
        ("soft.wav",  gen_soft),
    ]
    for filename, generator in sounds:
        samples = generator()

        # Write to assets/sounds (Flutter)
        asset_path = os.path.join(assets_dir, filename)
        write_wav(asset_path, samples)
        size_kb = os.path.getsize(asset_path) / 1024
        print(f"  [ok] {asset_path}  ({size_kb:.1f} KB)")

        # Mirror to android/.../res/raw (notification channels)
        raw_path = os.path.join(raw_dir, filename)
        write_wav(raw_path, samples)
        print(f"  [ok] {raw_path}")

    print("Done.")
    print("Next:")
    print("  flutter pub get   # picks up the new assets")
    print("  flutter run")


if __name__ == "__main__":
    main()
