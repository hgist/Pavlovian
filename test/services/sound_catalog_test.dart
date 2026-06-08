// Unit tests for the bundled sound catalog.

import 'package:flutter_test/flutter_test.dart';
import 'package:pavlovian/models/app_settings.dart';
import 'package:pavlovian/services/sound_catalog.dart';

void main() {
  group('SoundCatalog', () {
    test('lists all bundled sounds in order (Rooster first, Cuckoo last)',
        () {
      final names = SoundCatalog.all.map((s) => s.name).toList();
      expect(names, ['Rooster', 'Chime', 'Bell', 'Ping', 'Soft', 'Cuckoo']);
    });

    test('every entry has matching asset path and raw resource name', () {
      for (final s in SoundCatalog.all) {
        expect(s.assetPath, startsWith('assets/sounds/'));
        // Bundled formats vary — wav for the originals, mp3 for rooster.
        // Just assert the basename (sans extension) equals rawResource.
        final fileName = s.assetPath.split('/').last;
        final basename = fileName.contains('.')
            ? fileName.substring(0, fileName.lastIndexOf('.'))
            : fileName;
        expect(basename, s.rawResource);
        // Android raw resource names must be lowercase / no spaces.
        expect(s.rawResource, matches(RegExp(r'^[a-z][a-z0-9_]*$')));
      }
    });

    test('default sound name (kDefaultSoundName) is in the catalog', () {
      expect(SoundCatalog.findByName(kDefaultSoundName), isNotNull);
    });

    test('findByName returns null for unknown sounds', () {
      expect(SoundCatalog.findByName('Klaxon'), isNull);
    });
  });
}
