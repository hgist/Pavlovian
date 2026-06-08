// Catalog of bundled notification sounds.
//
// Each entry maps a user-facing name (stored in BreakSlot.soundName)
// to the asset path used by audioplayers for preview, and to the
// Android raw-resource name used later for notification channels.
//
// "Chime" is the factory default — see kDefaultSoundName in app_settings.

class SoundEntry {
  /// User-facing display label, e.g. "Chime".
  final String name;

  /// Flutter asset path, e.g. "assets/sounds/chime.wav".
  final String assetPath;

  /// Filename without extension — used as the Android raw resource
  /// name later (Step 11) for notification channels. Must be all
  /// lowercase, no spaces.
  final String rawResource;

  const SoundEntry({
    required this.name,
    required this.assetPath,
    required this.rawResource,
  });
}

class SoundCatalog {
  /// All sounds bundled with the app. Order matters — this is the
  /// order shown in the picker.
  static const List<SoundEntry> all = [
    // Rooster is the factory-default start-of-break sound — listed
    // first so the picker pre-selects it visually for new users.
    // Attribution: Ribhav Agrawal @ pixabay.com (see Settings footer).
    SoundEntry(
      name: 'Rooster',
      assetPath: 'assets/sounds/rooster.mp3',
      rawResource: 'rooster',
    ),
    SoundEntry(
      name: 'Chime',
      assetPath: 'assets/sounds/chime.wav',
      rawResource: 'chime',
    ),
    SoundEntry(
      name: 'Bell',
      assetPath: 'assets/sounds/bell.wav',
      rawResource: 'bell',
    ),
    SoundEntry(
      name: 'Ping',
      assetPath: 'assets/sounds/ping.wav',
      rawResource: 'ping',
    ),
    SoundEntry(
      name: 'Soft',
      assetPath: 'assets/sounds/soft.wav',
      rawResource: 'soft',
    ),
    // Cuckoo is the factory-default end-of-break sound — placed last
    // in the picker but referenced by kDefaultEndSoundName so fresh
    // installs hear "cuckoo" when a break-duration timer expires.
    SoundEntry(
      name: 'Cuckoo',
      assetPath: 'assets/sounds/cuckoo.wav',
      rawResource: 'cuckoo',
    ),
  ];

  /// Find a sound by its user-facing name. Returns null if no match.
  static SoundEntry? findByName(String name) {
    for (final s in all) {
      if (s.name == name) return s;
    }
    return null;
  }
}
