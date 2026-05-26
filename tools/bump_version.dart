// tools/bump_version.dart
//
// Bumps the Pavlovian app version, keeping the SemVer patch (last
// part of X.Y.Z) and the Android versionCode (the number after the
// `+`) equal at all times.
//
// Usage (run from project root):
//   dart run tools/bump_version.dart            # patch += 1
//   dart run tools/bump_version.dart 7          # patch = 7
//   dart run tools/bump_version.dart 1.1.0      # full version, build = patch
//
// Examples of resulting pubspec.yaml `version:` line:
//   before                after `dart run tools/bump_version.dart`
//   ─────────────────     ──────────────────────────────────────────
//   1.0.0+1               1.0.1+1
//   1.0.5+5               1.0.6+6
//   1.0.0+1   (arg 7)     1.0.7+7
//   1.0.0+1   (arg 1.1.0) 1.1.0+0
//
// Run `flutter pub get` afterward (Flutter prints a hint if needed).

import 'dart:io';

final RegExp _versionLine =
    RegExp(r'^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$', multiLine: true);

void main(List<String> args) {
  final pubspec = File('pubspec.yaml');
  if (!pubspec.existsSync()) {
    stderr.writeln('✗ pubspec.yaml not found. Run from the project root.');
    exit(1);
  }

  final content = pubspec.readAsStringSync();
  final match = _versionLine.firstMatch(content);
  if (match == null) {
    stderr.writeln('✗ Could not find a `version: X.Y.Z+N` line in pubspec.yaml');
    exit(1);
  }

  final major = int.parse(match.group(1)!);
  final minor = int.parse(match.group(2)!);
  final patch = int.parse(match.group(3)!);

  final int newMajor;
  final int newMinor;
  final int newPatch;
  if (args.isEmpty) {
    // No arg → increment patch
    newMajor = major;
    newMinor = minor;
    newPatch = patch + 1;
  } else if (args[0].contains('.')) {
    // Arg looks like X.Y.Z — set absolute version
    final parts = args[0].split('.');
    if (parts.length != 3) {
      stderr.writeln('✗ Expected X.Y.Z, got "${args[0]}"');
      exit(1);
    }
    newMajor = int.parse(parts[0]);
    newMinor = int.parse(parts[1]);
    newPatch = int.parse(parts[2]);
  } else {
    // Arg is a single number → set patch only
    newMajor = major;
    newMinor = minor;
    newPatch = int.parse(args[0]);
  }

  // Build number ALWAYS equals patch — the rule of this convention.
  final newBuild = newPatch;

  final oldLine = match.group(0)!;
  final newLine = 'version: $newMajor.$newMinor.$newPatch+$newBuild';
  final newContent = content.replaceFirst(oldLine, newLine);

  pubspec.writeAsStringSync(newContent);

  stdout.writeln('✓ Version bumped');
  stdout.writeln('  before:  $major.$minor.$patch+${match.group(4)}');
  stdout.writeln('  after:   $newMajor.$newMinor.$newPatch+$newBuild');
  stdout.writeln('');
  stdout.writeln('Next:');
  stdout.writeln('  flutter pub get   # picks up the new version metadata');
  stdout.writeln('  flutter run       # to see the new "v $newMajor.$newMinor.$newPatch" in the splash');
}
