// Wraps the Android-side MethodChannel that opens the native system
// ringtone picker so the user can pick e.g. Samsung's "Spaceline".
//
// The native code lives in
//   android/app/src/main/kotlin/.../MainActivity.kt
//
// Methods:
//   pick(currentUri)  → opens picker; returns the chosen URI or null
//                       if cancelled
//   titleFor(uri)     → returns the human-readable title for a URI
//                       (e.g. "Spaceline" for the Samsung default)

import 'package:flutter/services.dart';

class RingtonePicker {
  static const _channel = MethodChannel('com.hst.pavlovian/ringtone');

  /// Opens the native picker. [currentUri] is shown as pre-selected
  /// (so the user can hear what's already chosen).
  Future<String?> pick({String? currentUri}) async {
    try {
      return await _channel.invokeMethod<String>(
        'pickRingtone',
        {'currentUri': currentUri},
      );
    } catch (_) {
      return null;
    }
  }

  /// Look up the display title for a given URI. Returns null on failure.
  Future<String?> titleFor(String uri) async {
    try {
      return await _channel.invokeMethod<String>(
        'ringtoneTitle',
        {'uri': uri},
      );
    } catch (_) {
      return null;
    }
  }
}
