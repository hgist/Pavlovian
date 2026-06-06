// Settings screen — matches the A5-settings.html wireframe.
//
// STEP 8: layout only. Reads AppSettings from Riverpod so the
// numbers shown reflect current state, but no row is tappable yet
// (Step 9 will wire up time/duration/label editing; Step 10 the
// sound picker; Step 11+ the test-notification button; etc.).
//
// Structure:
//   ┌── header ─── ← Settings · v1.0.0 ──────────────── ⚙ ──┐
//   │   ① Break Slots                                       │
//   │      ┌──────┐                                         │
//   │      │ slot │ 1  Morning Break        edit label ›    │
//   │      │ card │   Break time   10:00              ›    │
//   │      └──────┘   Duration     20 min              ›    │
//   │                 Alert sound  Chime               ›    │
//   │      (… same for Lunch Break, Afternoon Break)        │
//   │   ② Working Days                                      │
//   │      ┌──────────────────────────────────────────┐    │
//   │      │  Sun  Mon  Tue  Wed  Thu  F̶r̶i̶  S̶a̶t̶         │    │
//   │      └──────────────────────────────────────────┘    │
//   │   ③ Notifications                                     │
//   │      Test notification …               ▶ test         │
//   │      Vibrate on alert                    [● ON]        │
//   │      Flash LED on alert                  [   OFF]      │
//   │   ④ Reset                                             │
//   │      ⚠  Reset All to Defaults                  ›     │
//   └────────────────────────────────────────────────────────┘

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/app_settings.dart';
import '../models/break_slot.dart';
import '../models/break_time.dart';
import '../models/weekday.dart';
import '../services/app_version.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../viewmodels/settings_provider.dart';
import 'components/menu_icons.dart';
import 'diagnostics_screen.dart';
import 'dialogs/edit_duration_sheet.dart';
import 'dialogs/edit_label_dialog.dart';
import 'dialogs/edit_sound_sheet.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // SplashGate guarantees settings are loaded before navigation —
    // so .value can never be null here in normal flow. Still using
    // `!` (force-unwrap) rather than `??` to surface a clear error
    // if our assumption is ever violated.
    final settings = ref.watch(settingsProvider).value!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const _Header(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  const _SectionHeader('① Break Slots'),
                  ...settings.slots.map((s) => _SlotCard(slot: s)),
                  const _AddBreakButton(),
                  const _SectionHeader('② Working Days'),
                  _WorkingDaysCard(settings: settings),
                  const _SectionHeader('③ Notifications'),
                  _NotificationsCard(settings: settings),
                  const _SectionHeader('④ Reset'),
                  const _ResetCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Header — back arrow + Settings title + version + gear icon
// ─────────────────────────────────────────────────────────────────
class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appVersion = ref.watch(appVersionProvider);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 18, 10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.inkHairline, width: 1.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Back arrow — pops the settings screen off the stack
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pop(),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Text(
                '←',
                style: GoogleFonts.caveat(
                  fontSize: 26,
                  color: AppColors.inkMuted,
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Title + version subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: GoogleFonts.architectsDaughter(
                    fontSize: 20,
                    color: AppColors.ink,
                    letterSpacing: 0.3,
                  ),
                ),
                // Long-press the version line to open Diagnostics —
                // hidden because end-users don't need it.
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onLongPress: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const DiagnosticsScreen(),
                    ),
                  ),
                  child: Text(
                    'Pavlovian v${appVersion.version}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      color: AppColors.inkMuted,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Decorative gear icon (matches A5 wireframe)
          const GearIcon(size: 22),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Section header — Caveat with dashed underline
// ─────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Transform.rotate(
            angle: -0.014, // ~ -0.8°
            child: Text(
              text,
              style: GoogleFonts.caveat(
                fontSize: 16,
                color: AppColors.warning,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 4),
          CustomPaint(
            size: const Size(double.infinity, 1.5),
            painter: _DashedLinePainter(),
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.inkHairline
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const dash = 6.0;
    const gap = 4.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dash, 0), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────
// ① Break-slot configuration card — now interactive (Step 9).
//
// Tapping any row opens the appropriate editor; the new value flows
// into SettingsNotifier and persists to disk via the Step 7 repo.
// ─────────────────────────────────────────────────────────────────
class _SlotCard extends ConsumerWidget {
  final BreakSlot slot;
  const _SlotCard({required this.slot});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(settingsProvider.notifier);

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      decoration: BoxDecoration(
        color: AppColors.paperLight,
        border: Border.all(color: AppColors.ink, width: 2),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.12),
            offset: const Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // Slot header row — tap "edit label" to rename,
          //                  long-press to delete (with confirm).
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _editLabel(context, notifier),
            onLongPress: () => _confirmDelete(context, notifier),
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
              decoration: BoxDecoration(
                color: AppColors.terracotta.withValues(alpha: 0.08),
                border: const Border(
                  bottom: BorderSide(color: AppColors.inkHairline, width: 1.5),
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  // Numbered badge
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.terracotta,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.ink, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        '${slot.id}',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          color: AppColors.ink,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      slot.label,
                      style: GoogleFonts.architectsDaughter(
                        fontSize: 15,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  Text(
                    'edit label ›',
                    style: GoogleFonts.caveat(
                      fontSize: 14,
                      color: AppColors.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Slot fields — 3 rows, each tappable
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 2, 12, 4),
            child: Column(
              children: [
                _SettingRow(
                  label: 'Break time',
                  value: slot.time.toDisplay(),
                  mono: true,
                  onTap: () => _editTime(context, notifier),
                ),
                _SettingRow(
                  label: 'Duration',
                  value: '${slot.durationMinutes} min',
                  mono: true,
                  onTap: () => _editDuration(context, notifier),
                ),
                _SettingRow(
                  label: 'Alert sound',
                  value: slot.soundName,
                  mono: false,
                  accent: true,
                  isLast: true,
                  onTap: () => _editSound(context, notifier),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Editor flows ───────────────────────────────────────────────

  Future<void> _editTime(BuildContext context, dynamic notifier) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: slot.time.hour, minute: slot.time.minute),
      initialEntryMode: TimePickerEntryMode.dial,
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked == null) return;
    // The notifier snaps to the nearest 5-min — UI doesn't have to.
    await notifier.setSlotTime(
      slot.id,
      BreakTime(picked.hour, picked.minute),
    );
  }

  Future<void> _editDuration(BuildContext context, dynamic notifier) async {
    final newMin =
        await EditDurationSheet.show(context, slot.durationMinutes);
    if (newMin == null) return;
    await notifier.setSlotDuration(slot.id, newMin);
  }

  Future<void> _editLabel(BuildContext context, dynamic notifier) async {
    final newLabel = await showEditLabelDialog(context, slot.label);
    if (newLabel == null) return;
    await notifier.setSlotLabel(slot.id, newLabel);
  }

  /// Long-press handler — confirms then deletes the slot.
  Future<void> _confirmDelete(
      BuildContext context, dynamic notifier) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.paperLight,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: AppColors.ink, width: 2),
        ),
        title: Text(
          'Delete "${slot.label}"?',
          style: GoogleFonts.architectsDaughter(
            fontSize: 18,
            color: AppColors.warning,
          ),
        ),
        content: Text(
          'This break and its alarms will be removed.',
          style: GoogleFonts.patrickHand(fontSize: 14, color: AppColors.ink),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'cancel',
              style: GoogleFonts.caveat(
                fontSize: 16,
                color: AppColors.inkMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'delete',
              style: GoogleFonts.caveat(
                fontSize: 16,
                color: AppColors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await notifier.removeSlot(slot.id);
    }
  }

  Future<void> _editSound(BuildContext context, dynamic notifier) async {
    final picked = await EditSoundSheet.show(
      context,
      slot.soundName,
      currentUri: slot.soundUri,
    );
    if (picked == null) return;
    await notifier.setSlotSound(
      slot.id,
      picked.name,
      newSoundUri: picked.uri,
    );
  }
}

/// One tappable setting row: label on left, value + chevron on right.
class _SettingRow extends StatelessWidget {
  final String label;
  final String value;
  final bool mono;
  final bool accent;
  final bool isLast;
  final VoidCallback? onTap;

  const _SettingRow({
    required this.label,
    required this.value,
    this.mono = false,
    this.accent = false,
    this.isLast = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final row = Container(
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: isLast
          ? null
          : const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0x14000000), // very faint hairline
                  width: 1,
                ),
              ),
            ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.patrickHand(
                fontSize: 14,
                color: AppColors.ink,
              ),
            ),
          ),
          Text(
            value,
            style: mono
                ? GoogleFonts.jetBrainsMono(
                    fontSize: 14,
                    color: accent ? AppColors.warning : AppColors.ink,
                    fontWeight: FontWeight.w500,
                  )
                : GoogleFonts.patrickHand(
                    fontSize: 14,
                    color: accent ? AppColors.warning : AppColors.ink,
                  ),
          ),
          const SizedBox(width: 4),
          Text(
            '›',
            style: GoogleFonts.caveat(
              fontSize: 18,
              color: AppColors.inkHairline,
            ),
          ),
        ],
      ),
    );

    // Wrap in a GestureDetector when the row has a tap handler.
    if (onTap == null) return row;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: row,
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// ② Working-days card
// ─────────────────────────────────────────────────────────────────
class _WorkingDaysCard extends StatelessWidget {
  final AppSettings settings;
  const _WorkingDaysCard({required this.settings});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.paperLight,
        border: Border.all(color: AppColors.ink, width: 2),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.12),
            offset: const Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Consumer(
        builder: (context, ref, _) {
          final notifier = ref.read(settingsProvider.notifier);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Timers fire on checked days only.',
                style: GoogleFonts.patrickHand(
                  fontSize: 12,
                  color: AppColors.inkMuted,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final day in Weekday.values)
                    _SettingsDayPill(
                      label: day.label,
                      enabled: settings.isDayEnabled(day),
                      onTap: () => notifier.toggleDay(day),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'tap a day to toggle it on / off',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  color: AppColors.inkMuted,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SettingsDayPill extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback? onTap;
  const _SettingsDayPill({
    required this.label,
    required this.enabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.terracotta.withValues(alpha: 0.15)
              : Colors.transparent,
          border: Border.all(color: AppColors.ink, width: 2),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: enabled
              ? GoogleFonts.patrickHand(
                  fontSize: 13,
                  color: AppColors.ink,
                )
              : GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  color: AppColors.inkHairline,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: AppColors.inkHairline,
                ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// ③ Notifications card — test button + vibrate + flash LED
// ─────────────────────────────────────────────────────────────────
class _NotificationsCard extends StatelessWidget {
  final AppSettings settings;
  const _NotificationsCard({required this.settings});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.paperLight,
        border: Border.all(color: AppColors.ink, width: 2),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.12),
            offset: const Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Consumer(
        builder: (context, ref, _) {
          final notifier = ref.read(settingsProvider.notifier);
          return Column(
            children: [
              _TestNotificationRow(),
              _SettingRow(
                label: 'Alert sound',
                value: settings.testSoundName,
                accent: true,
                onTap: () async {
                  final picked = await EditSoundSheet.show(
                    context,
                    settings.testSoundName,
                    currentUri: settings.testSoundUri,
                  );
                  if (picked != null) {
                    await notifier.setTestSound(
                      picked.name,
                      newSoundUri: picked.uri,
                    );
                  }
                },
              ),
              _SettingRow(
                label: 'End-of-break sound',
                value: settings.endSoundName,
                accent: true,
                onTap: () async {
                  final picked = await EditSoundSheet.show(
                    context,
                    settings.endSoundName,
                    currentUri: settings.endSoundUri,
                  );
                  if (picked != null) {
                    await notifier.setEndSound(
                      picked.name,
                      newSoundUri: picked.uri,
                    );
                  }
                },
              ),
              _ToggleRow(
                label: 'Vibrate on alert',
                on: settings.vibrate,
                isLast: false,
                onTap: notifier.toggleVibrate,
              ),
              _ToggleRow(
                label: 'Flash LED on alert',
                on: settings.flashLed,
                isLast: true,
                onTap: notifier.toggleFlashLed,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TestNotificationRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appSettings = ref.watch(settingsProvider).value!;

    Future<void> fireTest() async {
      final svc = ref.read(notificationServiceProvider);
      await svc.fireTest(
        appSettings.testSoundName,
        appSettings.vibrate,
        appSettings.flashLed,
        soundUri: appSettings.testSoundUri,
      );
      final count = await svc.pendingCount();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Test fired (${appSettings.testSoundName}) · $count scheduled',
            style: GoogleFonts.patrickHand(fontSize: 14),
          ),
          duration: const Duration(seconds: 3),
          backgroundColor: AppColors.ink,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0x14000000), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Test notification',
                  style: GoogleFonts.patrickHand(
                    fontSize: 14,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  'fires a sample alert with slot 1\'s sound',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: fireTest,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.ink, width: 1.5),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.ink.withValues(alpha: 0.2),
                    offset: const Offset(1, 1),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Text(
                '▶ test',
                style: GoogleFonts.caveat(
                  fontSize: 14,
                  color: AppColors.ink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool on;
  final bool isLast;
  final VoidCallback? onTap;
  const _ToggleRow({
    required this.label,
    required this.on,
    required this.isLast,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: isLast
          ? null
          : const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0x14000000), width: 1),
              ),
            ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.patrickHand(
                fontSize: 14,
                color: AppColors.ink,
              ),
            ),
          ),
          // Mini pill toggle
          Container(
            width: 38,
            height: 20,
            decoration: BoxDecoration(
              color: on ? AppColors.terracotta : Colors.transparent,
              border: Border.all(color: AppColors.ink, width: 1.5),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 1,
                  left: on ? 18 : 2,
                  child: Container(
                    width: 15,
                    height: 15,
                    decoration: const BoxDecoration(
                      color: AppColors.ink,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// ④ Reset danger card
// ─────────────────────────────────────────────────────────────────
class _ResetCard extends ConsumerWidget {
  const _ResetCard();

  Future<void> _confirmAndReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.paperLight,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: AppColors.ink, width: 2),
        ),
        title: Text(
          'Reset all settings?',
          style: GoogleFonts.architectsDaughter(
            fontSize: 18,
            color: AppColors.warning,
          ),
        ),
        content: Text(
          "All times, durations, labels and toggles return to defaults. "
              "Your selected test sound is kept (slot sounds match it).",
          style: GoogleFonts.patrickHand(fontSize: 14, color: AppColors.ink),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'cancel',
              style: GoogleFonts.caveat(
                fontSize: 16,
                color: AppColors.inkMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'reset',
              style: GoogleFonts.caveat(
                fontSize: 16,
                color: AppColors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(settingsProvider.notifier).resetToDefaults();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Settings reset to defaults.',
            style: GoogleFonts.patrickHand(fontSize: 14),
          ),
          backgroundColor: AppColors.ink,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _confirmAndReset(context, ref),
          child: Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 6),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.07),
            border: Border.all(color: AppColors.ink, width: 2),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.warning.withValues(alpha: 0.2),
                offset: const Offset(2, 2),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              // Warning triangle
              CustomPaint(
                size: const Size(22, 22),
                painter: _WarningTrianglePainter(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reset All to Defaults',
                      style: GoogleFonts.architectsDaughter(
                        fontSize: 15,
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'restores times, durations & sounds',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '›',
                style: GoogleFonts.caveat(
                  fontSize: 18,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
        ),
        ),
        // Tilted annotation
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 14, 0),
          child: Transform.rotate(
            angle: -0.017, // ~ -1°
            child: Text(
              '↑ shows a confirm dialog first',
              style: GoogleFonts.caveat(
                fontSize: 13,
                color: AppColors.inkHairline,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WarningTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 22);
    final stroke = Paint()
      ..color = AppColors.warning
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()
      ..color = AppColors.warning.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;
    final tri = Path()
      ..moveTo(11, 3)
      ..lineTo(20, 19)
      ..lineTo(2, 19)
      ..close();
    canvas.drawPath(tri, fill);
    canvas.drawPath(tri, stroke);
    // Exclamation mark
    canvas.drawLine(const Offset(11, 10), const Offset(11, 14),
        Paint()
          ..color = AppColors.warning
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round);
    canvas.drawCircle(const Offset(11, 17), 1.2,
        Paint()..color = AppColors.warning);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────
// + Add a break — appears after the last slot card.
// Creates a new slot with sensible defaults (sound = current
// testSoundName per the user's "defaults follow test sound" rule).
// ─────────────────────────────────────────────────────────────────
class _AddBreakButton extends ConsumerWidget {
  const _AddBreakButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => ref.read(settingsProvider.notifier).addSlot(),
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.terracotta.withValues(alpha: 0.10),
          border: Border.all(
              color: AppColors.ink, width: 2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            '+  Add a break',
            style: GoogleFonts.caveat(
              fontSize: 17,
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
