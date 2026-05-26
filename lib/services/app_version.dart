// App-version service.
//
// Reads the version + build number from the running APK metadata
// (`package_info_plus` looks at Android's package manager). Exposes
// them via a Riverpod provider so any widget can show the current
// version without hardcoding strings.
//
// Versioning convention (see CLAUDE.md):
//   pubspec.yaml uses `version: 1.0.X+X` — i.e. the semantic-version
//   patch and the Android versionCode are always equal. Bump them
//   together via `dart run tools/bump_version.dart`.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Simple immutable value holder for the app version.
class AppVersion {
  /// Semantic version, e.g. "1.0.3".
  final String version;

  /// Build / versionCode, e.g. "3".
  final String buildNumber;

  const AppVersion({required this.version, required this.buildNumber});

  /// Compact display, e.g. "v 1.0.3".
  String get display => 'v $version';

  /// With build number, e.g. "v 1.0.3 (build 3)".
  String get displayWithBuild => 'v $version (build $buildNumber)';
}

/// Provider — overridden in `main()` with the real value from
/// `loadAppVersion()`. The fallback below is only used by tests
/// that don't bother to override.
final appVersionProvider = Provider<AppVersion>((ref) {
  return const AppVersion(version: '0.0.0', buildNumber: '0');
});

/// Read the version from the platform package info. Called once
/// at app startup, before `runApp(...)`.
Future<AppVersion> loadAppVersion() async {
  final info = await PackageInfo.fromPlatform();
  return AppVersion(
    version: info.version,
    buildNumber: info.buildNumber,
  );
}
