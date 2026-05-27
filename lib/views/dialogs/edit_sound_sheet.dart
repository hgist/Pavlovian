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

import '../../services/sound_catalog.dart';
import '../../services/sound_player.dart';
import '../../theme/app_theme.dart';

class EditSoundSheet extends ConsumerStatefulWidget {
  final String currentSound;
  const EditSoundSheet({super.key, required this.currentSound});

  static Future<String?> show(BuildContext context, String current) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.paper,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => EditSoundSheet(currentSound: current),
    );
  }

  @override
  ConsumerState<EditSoundSheet> createState() => _EditSoundSheetState();
}

class _EditSoundSheetState extends ConsumerState<EditSoundSheet> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentSound;
  }

  @override
  void dispose() {
    // Stop any in-flight preview when the sheet closes.
    // Using a try because the provider may already be disposing.
    try {
      ref.read(soundPlayerProvider).stop();
    } catch (_) {/* fine */}
    super.dispose();
  }

  void _onTapSound(SoundEntry sound) {
    setState(() => _selected = sound.name);
    ref.read(soundPlayerProvider).preview(sound.assetPath);
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

            // Sound list
            for (final sound in SoundCatalog.all)
              _SoundRow(
                sound: sound,
                selected: sound.name == _selected,
                onTap: () => _onTapSound(sound),
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
                    onTap: () => Navigator.of(context).pop(_selected),
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
