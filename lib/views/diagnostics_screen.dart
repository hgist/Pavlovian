// Hidden diagnostics screen — long-press the version number in the
// Settings header to open it.
//
// Surfaces everything we need to debug release-mode notification
// problems WITHOUT plugging in to ADB or rebuilding:
//
//   • The persisted AppSettings JSON (master switches, slots, sounds)
//   • Result of canScheduleExactAlarms() right now
//   • The plugin's pending-notification list (or the exception it threw)
//   • The next 21 fire times our scheduling logic would compute
//   • The ring-buffer log of every scheduleAll / fireTest event
//
// One-tap "Copy" button puts the whole snapshot on the clipboard so
// the user can paste it into a chat/email instead of typing.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/weekday.dart';
import '../services/log_service.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../viewmodels/settings_provider.dart';

class DiagnosticsScreen extends ConsumerStatefulWidget {
  const DiagnosticsScreen({super.key});

  @override
  ConsumerState<DiagnosticsScreen> createState() => _DiagnosticsState();
}

class _DiagnosticsState extends ConsumerState<DiagnosticsScreen> {
  String? _snapshot;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _busy = true);
    final s = await _collect();
    if (!mounted) return;
    setState(() {
      _snapshot = s;
      _busy = false;
    });
  }

  Future<String> _collect() async {
    final buf = StringBuffer();
    final settings = ref.read(settingsProvider).value;
    final svc = ref.read(notificationServiceProvider);
    final log = ref.read(logServiceProvider);

    buf.writeln('═══ Pavlovian Diagnostics ═══');
    buf.writeln('Captured: ${DateTime.now()}');
    buf.writeln();

    // --- Persisted settings ---
    buf.writeln('── Persisted settings ──');
    if (settings == null) {
      buf.writeln('(settings still loading)');
    } else {
      buf.writeln(const JsonEncoder.withIndent('  ').convert(settings.toJson()));
    }
    buf.writeln();

    // --- Exact alarm permission ---
    buf.writeln('── Permissions ──');
    final exactOk = await svc.canScheduleExactAlarms();
    buf.writeln('canScheduleExactAlarms: $exactOk');
    buf.writeln();

    // --- Pending notifications from the OS ---
    buf.writeln('── Plugin pending list ──');
    try {
      final pending = await svc.pendingCount();
      buf.writeln('pendingNotificationRequests count: $pending');
    } catch (e) {
      buf.writeln('pendingNotificationRequests THREW: $e');
    }
    buf.writeln();

    // --- What our scheduling logic would compute ---
    buf.writeln('── Computed next fire times ──');
    if (settings == null) {
      buf.writeln('(skipped — no settings)');
    } else if (!settings.globalEnabled) {
      buf.writeln('(skipped — globalEnabled is OFF)');
    } else {
      try {
        for (final slot in settings.slots) {
          if (!slot.enabled) {
            buf.writeln('slot ${slot.id} "${slot.label}" DISABLED — skip');
            continue;
          }
          for (final day in Weekday.values) {
            if (!settings.isDayEnabled(day)) continue;
            final fire = _nextInstanceOf(
              _dartWeekday(day),
              slot.time.hour,
              slot.time.minute,
            );
            buf.writeln(
                '  slot ${slot.id}/${day.label.padRight(3)} → $fire');
          }
        }
      } catch (e) {
        buf.writeln('next-fire computation THREW: $e');
      }
    }
    buf.writeln();

    // --- Recent log entries ---
    buf.writeln('── Log (latest at bottom) ──');
    final lines = await log.readAll();
    if (lines.isEmpty) {
      buf.writeln('(log empty)');
    } else {
      for (final l in lines) {
        buf.writeln(l);
      }
    }
    return buf.toString();
  }

  /// Mirror of NotificationService._nextInstanceOf so the diagnostics
  /// view can show what scheduling would compute without invoking it.
  tz.TZDateTime _nextInstanceOf(int dartWeekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    while (scheduled.weekday != dartWeekday || !scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  int _dartWeekday(Weekday d) {
    switch (d) {
      case Weekday.mon:
        return DateTime.monday;
      case Weekday.tue:
        return DateTime.tuesday;
      case Weekday.wed:
        return DateTime.wednesday;
      case Weekday.thu:
        return DateTime.thursday;
      case Weekday.fri:
        return DateTime.friday;
      case Weekday.sat:
        return DateTime.saturday;
      case Weekday.sun:
        return DateTime.sunday;
    }
  }

  Future<void> _copyToClipboard() async {
    final s = _snapshot;
    if (s == null) return;
    await Clipboard.setData(ClipboardData(text: s));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.diagnostics_copy_snackbar),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _clearLog() async {
    await ref.read(logServiceProvider).clear();
    await _refresh();
  }

  Future<void> _forceReschedule() async {
    final settings = ref.read(settingsProvider).value;
    if (settings == null) return;
    await ref.read(notificationServiceProvider).scheduleAll(settings);
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        foregroundColor: AppColors.ink,
        title: Text(
          l10n.diagnostics_screen_title,
          style: GoogleFonts.architectsDaughter(
            fontSize: 20,
            color: AppColors.ink,
          ),
        ),
        actions: [
          IconButton(
            tooltip: l10n.diagnostics_refresh_tooltip,
            icon: const Icon(Icons.refresh),
            onPressed: _busy ? null : _refresh,
          ),
          IconButton(
            tooltip: l10n.diagnostics_copy_tooltip,
            icon: const Icon(Icons.copy),
            onPressed: _snapshot == null ? null : _copyToClipboard,
          ),
        ],
      ),
      body: _busy
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
              child: SelectableText(
                _snapshot ?? '',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  color: AppColors.ink,
                  height: 1.35,
                ),
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _busy ? null : _forceReschedule,
                  child: const Text('Re-run scheduleAll'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: _busy ? null : _clearLog,
                  child: const Text('Clear log'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

