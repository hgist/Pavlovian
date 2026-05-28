// tools/bump_version.dart
//
// Versioning scheme (see CLAUDE.md):
//   MAJOR.MINOR.PATCH+BUILD   where PATCH == BUILD always.
//     MAJOR  — major release / rewrite (manual)
//     MINOR  — "app evolvement": bump when a roadmap phase / big
//              feature set is completed
//     PATCH  — monotonic build counter, +1 every build, never resets
//     BUILD  — Android versionCode, kept equal to PATCH
//
// Modes (run from project root):
//   dart run tools/bump_version.dart              # = "build"
//   dart run tools/bump_version.dart build        # patch+1, build=patch
//   dart run tools/bump_version.dart minor        # minor+1 AND patch+1
//   dart run tools/bump_version.dart major        # major+1 AND patch+1
//   dart run tools/bump_version.dart set 1.4.1    # set exact X.Y.Z, build=patch
//
// On minor/major bump the patch/build keep counting (no reset) so the
// build number stays a true monotonic dev counter.

import 'dart:io';

final RegExp _versionLine =
    RegExp(r'^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$', multiLine: true);

void main(List<String> args) {
  final pubspec = File('pubspec.yaml');
  if (!pubspec.existsSync()) {
    stderr.writeln('x pubspec.yaml not found. Run from the project root.');
    exit(1);
  }

  final content = pubspec.readAsStringSync();
  final m = _versionLine.firstMatch(content);
  if (m == null) {
    stderr.writeln('x Could not find `version: X.Y.Z+N` in pubspec.yaml');
    exit(1);
  }

  var major = int.parse(m.group(1)!);
  var minor = int.parse(m.group(2)!);
  var patch = int.parse(m.group(3)!);

  final mode = args.isEmpty ? 'build' : args[0];

  switch (mode) {
    case 'build':
      patch += 1;
    case 'minor':
      minor += 1;
      patch += 1; // build counter keeps ticking — no reset
    case 'major':
      major += 1;
      patch += 1; // build counter keeps ticking — no reset
    case 'set':
      if (args.length < 2 || !args[1].contains('.')) {
        stderr.writeln('x Usage: set X.Y.Z');
        exit(1);
      }
      final parts = args[1].split('.');
      if (parts.length != 3) {
        stderr.writeln('x Expected X.Y.Z, got "${args[1]}"');
        exit(1);
      }
      major = int.parse(parts[0]);
      minor = int.parse(parts[1]);
      patch = int.parse(parts[2]);
    default:
      stderr.writeln('x Unknown mode "$mode". Use build | minor | major | set.');
      exit(1);
  }

  final build = patch; // PATCH == BUILD invariant
  final oldLine = m.group(0)!;
  final newLine = 'version: $major.$minor.$patch+$build';
  pubspec.writeAsStringSync(content.replaceFirst(oldLine, newLine));

  stdout.writeln('[ok] version: ${m.group(1)}.${m.group(2)}.${m.group(3)}+'
      '${m.group(4)}  ->  $major.$minor.$patch+$build   ($mode)');
}
