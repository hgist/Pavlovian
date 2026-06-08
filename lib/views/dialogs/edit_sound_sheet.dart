// Modal bottom sheet for choosing a notification sound.
//
// User taps any row → the sound plays immediately (preview) AND the
// selection moves to that row. Save commits; Cancel discards.
//
// Usage:
//   final newName = await EditSoundSheet.show(context, slot.soundName);
//   if (newName != null) { /* apply */ }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/ringtone_picker.dart';
import '../../services/sound_catalog.dart';
import '../../services/sound_player.dart';
import '../../theme/app_theme.dart';

/// What the sound picker returns: the display name and an optional
/// system-ringtone URI (null = bundled sound, just use the name).
class SoundPick {
  final String name;
  final String? uri;
  const SoundPick({required this.name, this.uri});
}

class EditSoundSheet extends ConsumerStatefulWidget {
  final String currentSound;
  final String? currentSoundUri;
  const EditSoundSheet({
    super.key,
    required this.currentSound,
    this.currentSoundUri,
  });

  static Future<SoundPick?> show(
    BuildContext context,
    String currentName, {
    String? currentUri,
  }) {
    return showModalBottomSheet<SoundPick>(
      context: context,
      backgroundColor: AppColors.paper,
      // `true` so the sheet can grow past the default ~50% screen cap
      // we hit once the catalog reached 6 sounds + "More sounds…".
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      // Cap at 80% of the screen so the title still peeks above the
      // sheet, letting the user know what's on top before dragging.
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      builder: (_) => EditSoundSheet(
        currentSound: currentName,
        currentSoundUri: currentUri,
      ),
    );
  }

  @override
  ConsumerState<EditSoundSheet> createState() => _EditSoundSheetState();
}

class _EditSoundSheetState extends ConsumerState<EditSoundSheet> {
  late String _selectedName;
  late String? _selectedUri;

  @override
  void initState() {
    super.initState();
    _selectedName = widget.currentSound;
    _selectedUri = widget.currentSoundUri;
  }

  @override
  void dispose() {
    try {
      ref.read(soundPlayerProvider).stop();
    } catch (_) {/* fine */}
    super.dispose();
  }

  void _onTapBundled(SoundEntry sound) {
    setState(() {
      _selectedName = sound.name;
      _selectedUri = null;
    });
    ref.read(soundPlayerProvider).preview(sound.assetPath);
  }

  Future<void> _openSystemPicker() async {
    final picker = RingtonePicker();
    final pickedUri = await picker.pick(currentUri: _selectedUri);
    if (pickedUri == null) return;
    final title = await picker.titleFor(pickedUri) ?? 'System sound';
    if (!mounted) return;
    setState(() {
      _selectedName = title;
      _selectedUri = pickedUri;
    });
    // Preview is automatic in the system picker; we don't re-play here.
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Center(
              child: Text(
                'Alert sound',
                style: GoogleFonts.architectsDaughter(
                  fontSize: 20,
                  color: AppColors.ink,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Center(
              child: Text(
                'tap to preview',
                style: GoogleFonts.patrickHand(
                  fontSize: 12,
                  color: AppColors.inkMuted,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // The sound list scrolls if it overflows so Cancel / Save
            // always stay visible at the bottom. Without Flexible +
            // SingleChildScrollView, longer catalogs push the buttons
            // off-screen on shorter devices.
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Bundled sounds
                    for (final sound in SoundCatalog.all)
                      _SoundRow(
                        sound: sound,
                        selected: _selectedUri == null &&
                            sound.name == _selectedName,
                        onTap: () => _onTapBundled(sound),
                      ),

                    // System / device ringtone picker entry.
                    _SystemSoundRow(
                      selected: _selectedUri != null,
                      title: _selectedUri != null
                          ? _selectedName
                          : 'More sounds…',
                      onTap: _openSystemPicker,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Cancel + Save buttons
            Row(
              children: [
                Expanded(
                  child: _SheetButton(
                    label: 'cancel',
                    primary: false,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SheetButton(
                    label: 'save',
                    primary: true,
                    onTap: () => Navigator.of(context).pop(
                      SoundPick(name: _selectedName, uri: _selectedUri),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SoundRow extends StatelessWidget {
  final SoundEntry sound;
  final bool selected;
  final VoidCallback onTap;
  const _SoundRow({
    required this.sound,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.terracotta.withValues(alpha: 0.18)
              : AppColors.paperLight,
          border: Border.all(color: AppColors.ink, width: 2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.12),
              offset: const Offset(2, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            // Selection indicator (filled if selected)
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: selected ? AppColors.terracotta : Colors.transparent,
                border: Border.all(color: AppColors.ink, width: 1.5),
                shape: BoxShape.circle,
              ),
              child: selected
                  ? const Center(
                      child: Icon(Icons.check, size: 10, color: AppColors.ink),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                sound.name,
                style: GoogleFonts.patrickHand(
                  fontSize: 16,
                  color: AppColors.ink,
                ),
              ),
            ),
            // Small play indicator
            Text(
              '▶',
              style: GoogleFonts.caveat(
                fontSize: 16,
                color: AppColors.inkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tappable row that opens the native Android ringtone picker.
/// Shows "More sounds…" when nothing system-picked, or the picked
/// title (e.g. "Spaceline") when one is currently selected.
class _SystemSoundRow extends StatelessWidget {
  final bool selected;
  final String title;
  final VoidCallback onTap;
  const _SystemSoundRow({
    required this.selected,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.terracotta.withValues(alpha: 0.18)
              : AppColors.paperLight,
          border: Border.all(color: AppColors.ink, width: 2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.12),
              offset: const Offset(2, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: selected ? AppColors.terracotta : Colors.transparent,
                border: Border.all(color: AppColors.ink, width: 1.5),
                shape: BoxShape.circle,
              ),
              child: selected
                  ? const Center(
                      child: Icon(Icons.check, size: 10, color: AppColors.ink),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.patrickHand(
                  fontSize: 16,
                  color: AppColors.ink,
                ),
              ),
            ),
            Text(
              '⋯',
              style: GoogleFonts.caveat(
                fontSize: 18,
                color: AppColors.inkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  final String label;
  final bool primary;
  final VoidCallback onTap;
  const _SheetButton({
    required this.label,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: primary ? AppColors.terracotta : Colors.transparent,
          border: Border.all(color: AppColors.ink, width: 2),
          borderRadius: BorderRadius.circular(10),
          boxShadow: primary
              ? const [
                  BoxShadow(
                    color: AppColors.ink,
                    offset: Offset(2, 2),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.caveat(
              fontSize: 16,
              color: AppColors.ink,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
