// Persistence layer for AppSettings.
//
// Wraps `shared_preferences` so the Notifier (and tests) don't touch
// SharedPreferences directly. Settings are stored as a single JSON
// string under one key, with a version field for future migrations.
//
// On corrupt data or missing key, returns AppSettings.defaults() — the
// app starts fresh rather than crashing.

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';

class SettingsRepository {
  /// Single SharedPreferences key for the whole settings blob.
  /// Bumping the suffix (`_v2` etc.) on a future schema change lets us
  /// ignore old data without breaking existing installs.
  static const _key = 'app_settings_v1';

  /// Load settings from disk, or return defaults if nothing stored yet
  /// (first launch) or if the stored JSON can't be parsed (corrupt).
  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return AppSettings.defaults();
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return AppSettings.fromJson(json);
    } catch (_) {
      // Anything wrong — bad JSON, missing field, type mismatch —
      // fall back to defaults rather than crashing.
      return AppSettings.defaults();
    }
  }

  /// Write settings as JSON to disk. Returns when the write completes.
  Future<void> save(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(settings.toJson()));
  }

  /// Wipe persisted settings — next load() returns defaults.
  /// Used by "Reset All to Defaults" in Step 9+.
  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  // ── Countdown persistence (Step 13) ────────────────────────────
  // Stores active end-of-break countdowns as {"slotId_dayIndex":
  // epochMillis} so the live MM:SS display survives an app restart
  // and stays in sync with the OS-scheduled "break over" notification.
  static const _countdownKey = 'countdowns_v2';

  Future<Map<String, DateTime>> loadCountdowns() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_countdownKey);
    if (raw == null) return {};
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return json.map((k, v) => MapEntry(
            k,
            DateTime.fromMillisecondsSinceEpoch(v as int),
          ));
    } catch (_) {
      return {};
    }
  }

  Future<void> saveCountdowns(Map<String, DateTime> countdowns) async {
    final prefs = await SharedPreferences.getInstance();
    final json = countdowns.map(
      (k, v) => MapEntry(k, v.millisecondsSinceEpoch),
    );
    await prefs.setString(_countdownKey, jsonEncode(json));
  }
}

/// Provider exposing a single SettingsRepository instance to the rest
/// of the app. Notifier and tests both read it via `ref.read(...)`.
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});
