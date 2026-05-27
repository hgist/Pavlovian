// Unit tests for the bundled sound catalog.

import 'package:flutter_test/flutter_test.dart';
import 'package:pavlovian/models/app_settings.dart';
import 'package:pavlovian/services/sound_catalog.dart';

void main() {
  group('SoundCatalog', () {
    test('lists all four bundled sounds in order', () {
      final names = SoundCatalog.all.map((s) => s.name).toList();
      expect(names, ['Chime', 'Bell', 'Ping', 'Soft']);
    });

    test('every entry has matching asset path and raw resource name', () {
      for (final s in SoundCatalog.all) {
        expect(s.assetPath, startsWith('assets/sounds/'));
        expect(s.assetPath, endsWith('${s.rawResource}.wav'));
        // Android raw resource names must be lowercase / no spaces
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
