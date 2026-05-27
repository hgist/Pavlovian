// Thin wrapper around `audioplayers` for one-off preview playback.
//
// Single AudioPlayer instance held by a Riverpod Provider so the
// whole app shares it (state across screens, stop-before-replay
// behaviour, no double-playing).
//
// Used only for preview — Step 11+ will use notification channels
// for the actual scheduled-alarm sounds.

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SoundPlayer {
  final AudioPlayer _player = AudioPlayer();

  /// Play a bundled sound asset, stopping any in-flight playback first.
  /// [assetPath] is the Flutter asset path including the "assets/" prefix
  /// — we strip it because audioplayers' AssetSource expects the path
  /// *relative to the assets folder*.
  Future<void> preview(String assetPath) async {
    await _player.stop();
    final relative = assetPath.startsWith('assets/')
        ? assetPath.substring('assets/'.length)
        : assetPath;
    await _player.play(AssetSource(relative));
  }

  Future<void> stop() => _player.stop();

  void dispose() {
    _player.dispose();
  }
}

/// One shared SoundPlayer instance. Disposed when the ProviderScope is.
final soundPlayerProvider = Provider<SoundPlayer>((ref) {
  final p = SoundPlayer();
  ref.onDispose(p.dispose);
  return p;
});
