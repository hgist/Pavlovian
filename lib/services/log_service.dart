// Tiny persistent ring-buffer logger used for in-app diagnostics.
//
// Writes lines to SharedPreferences (key `diag_log`) so they survive
// app restarts and are readable from the Diagnostics screen in release
// builds, where debugPrint output is invisible.
//
// Capacity is capped at [_maxLines] — oldest entries are dropped when
// the buffer is full. Lines are prefixed with a HH:MM:SS timestamp.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogService {
  static const _key = 'diag_log';
  static const _maxLines = 200;

  // In-memory mirror so reads don't await disk. Loaded once on first use.
  List<String> _buffer = [];
  bool _loaded = false;

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _buffer = prefs.getStringList(_key) ?? <String>[];
    _loaded = true;
  }

  String _stamp() {
    final n = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(n.hour)}:${two(n.minute)}:${two(n.second)}';
  }

  /// Append a line. Safe to call from any context — disk write is
  /// fire-and-forget but kept in order via the in-memory buffer.
  void log(String message) {
    final line = '${_stamp()}  $message';
    debugPrint(line); // still show in debug console when attached
    // ignore: discarded_futures
    _appendAsync(line);
  }

  Future<void> _appendAsync(String line) async {
    await _ensureLoaded();
    _buffer.add(line);
    if (_buffer.length > _maxLines) {
      _buffer = _buffer.sublist(_buffer.length - _maxLines);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, _buffer);
  }

  /// Return all stored lines (oldest first). Empty before first log.
  Future<List<String>> readAll() async {
    await _ensureLoaded();
    return List<String>.from(_buffer);
  }

  /// Wipe the log. Used by the "Clear log" button in Diagnostics.
  Future<void> clear() async {
    _buffer = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

/// Single shared instance.
final logServiceProvider = Provider<LogService>((_) => LogService());
