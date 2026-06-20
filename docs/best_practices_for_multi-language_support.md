# Best Practices for Multi-Language Support in Android/Flutter Apps

## Overview
Multi-language (localization/i18n) support in Android and Flutter apps requires:
- Externalizing all user-facing strings
- Using locale-aware formatting for dates, times, and numbers
- Proper directory/file organization
- RTL (Right-to-Left) layout handling for languages like Arabic and Hebrew
- Comprehensive testing across languages

---

## 1. String Externalization

### Android Native
Store strings in XML resource files instead of hardcoding them:

```xml
<!-- res/values/strings.xml (English) -->
<resources>
  <string name="app_name">Pavlovian</string>
  <string name="break_time">Break Time</string>
  <string name="duration">Duration</string>
  <string name="alert_sound">Alert Sound</string>
</resources>
```

### Flutter (Recommended for Pavlovian)
Use ARB (Application Resource Bundle) files:

```json
// lib/l10n/app_en.arb (English)
{
  "app_name": "Pavlovian",
  "break_time": "Break Time",
  "duration": "Duration",
  "alert_sound": "Alert Sound",
  "morning_break": "Morning Break",
  "lunch_break": "Lunch Break",
  "afternoon_break": "Afternoon Break"
}
```

**Key Rules:**
- Never hardcode user-visible strings in Dart/Java code
- Use descriptive keys (e.g., `morning_break` not `slot_1`)
- Include context in keys for clarity (e.g., `settings_test_notification` vs. just `test`)

---

## 2. Directory Structure for Flutter (Pavlovian)

```
lib/
  l10n/
    app_en.arb          # English (source language)
    app_es.arb          # Spanish
    app_fr.arb          # French
    app_de.arb          # German
    app_ja.arb          # Japanese
    app_ar.arb          # Arabic (RTL)
```

**Generated files** (auto-created by Flutter):
```
lib/generated/
  l10n.dart             # Generated localization class
  app_localizations.dart
  app_localizations_en.dart
  app_localizations_es.dart
  ... (one per language)
```

---

## 3. Flutter Setup (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

flutter:
  generate: true
```

Create `l10n.yaml` in project root:
```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
preferred-supported-locales:
  - en
  - es
  - fr
  - de
  - ja
  - ar
```

---

## 4. Using Localized Strings in Widgets

```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Text(l10n.breakTime);  // Returns localized string
  }
}
```

**For Riverpod/ConsumerWidget:**
```dart
class SettingsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    
    return Text(l10n.settingsTitle);
  }
}
```

---

## 5. Locale-Aware Formatting

### Date/Time Formatting
```dart
import 'package:intl/intl.dart';

final locale = Localizations.localeOf(context).toString();
final formatter = DateFormat('EEEE, MMMM d, y', locale);
final formattedDate = formatter.format(DateTime.now());
```

### Number Formatting
```dart
final formatter = NumberFormat.decimalPattern(locale);
final formattedNumber = formatter.format(42.5);
```

### Time Formatting (for break times)
```dart
final time = BreakTime(10, 30);
final locale = Localizations.localeOf(context).toString();
final formatter = DateFormat('HH:mm', locale);
final formatted = formatter.format(DateTime(2024, 1, 1, time.hour, time.minute));
```

**Never do:**
```dart
// ❌ WRONG — hardcoded formatting
final time = "${breakSlot.hour}:${breakSlot.minute}";
```

---

## 6. RTL (Right-to-Left) Layout Support

### For Arabic, Hebrew, Persian, Urdu, etc.:

**Use `start`/`end` instead of `left`/`right`:**

```dart
// ✅ CORRECT
Padding(
  padding: EdgeInsets.only(start: 16, end: 16),
  child: Text(l10n.label),
)

// ❌ WRONG
Padding(
  padding: EdgeInsets.only(left: 16, right: 16),
  child: Text(l10n.label),
)
```

**In MaterialApp, enable RTL support:**

```dart
MaterialApp(
  title: l10n.appName,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: deviceLocale,
  builder: (context, child) {
    return Directionality(
      textDirection: _getTextDirection(context),
      child: child!,
    );
  },
  home: const MainScreen(),
)

TextDirection _getTextDirection(BuildContext context) {
  final locale = Localizations.localeOf(context);
  const rtlLocales = ['ar', 'he', 'fa', 'ur'];
  return rtlLocales.contains(locale.languageCode)
      ? TextDirection.rtl
      : TextDirection.ltr;
}
```

**Common RTL-safe properties:**
- `Padding(start:, end:)` instead of `left:, right:`
- `Align(alignment: Alignment.centerStart)` instead of `centerLeft`
- `Column` / `Row` respect directionality automatically
- Test all screens with RTL locales

---

## 7. Plurals and Quantities

### Example: "1 break" vs. "2 breaks"

**In ARB file:**
```json
{
  "slot_count": {
    "message": "{count, plural, =0{No breaks} =1{1 break} other{# breaks}}",
    "placeholders": {
      "count": {
        "type": "int"
      }
    }
  }
}
```

**In Dart:**
```dart
final l10n = AppLocalizations.of(context)!;
final message = l10n.slotCount(3);  // "3 breaks"
```

---

## 8. Testing Localization

### Device Testing
```bash
# Test English
flutter run

# Test Spanish via locale override
flutter run --dart-define=locale=es_ES
```

### Emulator/Device Settings
1. Open Settings → Language & input → Language
2. Add and select different languages
3. Restart app to verify text changes
4. Check RTL layouts render correctly

### Key Test Cases
- [ ] All user-facing strings appear in the app's language
- [ ] Dates/times format correctly per locale
- [ ] Numbers format correctly (decimal separators, grouping)
- [ ] RTL languages display text and layouts reversed
- [ ] No text truncation or overflow in any language
- [ ] Notification text is localized
- [ ] Error messages are localized
- [ ] Settings screen shows correct language labels

---

## 9. String Length Considerations

Different languages have different word lengths:
- **English:** "Break Time" (10 chars)
- **German:** "Pausenzeit" (10 chars)
- **Spanish:** "Hora de Descanso" (16 chars)
- **Japanese:** "休憩時間" (4 chars)

**Mitigation:**
- Use flexible layouts (`Expanded`, `Flexible`)
- Set reasonable max widths for overflow prevention
- Test UI with longest expected strings
- Avoid single-line constraints

---

## 10. Plurals and Gender (Advanced)

### Gendered Strings (if needed)
```json
{
  "welcome_message": {
    "message": "Welcome {gender, select, male{sir} female{madam} other{friend}}!",
    "placeholders": {
      "gender": {
        "type": "String"
      }
    }
  }
}
```

---

## 11. Translation Management Workflow

### Recommended Tools
- **Google Play Console** (built-in, free)
- **Crowdin** (collaborative, manages multiple projects)
- **OneSky** (simple, supports ARB)
- **Lokalise** (modern UI, team features)

### Workflow
1. Maintain `app_en.arb` as the source of truth
2. Export to translation service
3. Translators work on their language files
4. Import completed translations back
5. Validate in-app with QA testers

---

## 12. Fallback Behavior

Flutter automatically falls back to English if a translation is missing:

```dart
supportedLocales: [
  Locale('en'),
  Locale('es'),
  Locale('fr'),
  // If user's device is set to Japanese (not in the list),
  // Flutter falls back to English
]
```

---

## 13. Common Pitfalls to Avoid

| ❌ Don't | ✅ Do |
|---------|-------|
| Hardcode strings | Use `AppLocalizations.of(context)!.key` |
| Use `left`/`right` in RTL apps | Use `start`/`end` |
| Assume all languages fit in one line | Use flexible/expanding layouts |
| Format dates/times manually | Use `DateFormat` from `intl` package |
| Skip RTL testing | Test with Arabic/Hebrew on real devices |
| Forget to generate localization files | Run `flutter gen-l10n` before building |
| Mix localization with business logic | Keep strings in `.arb` files only |

---

## 14. For Pavlovian Specifically

When adding multi-language to Pavlovian:

### Strings to Externalize
- Screen titles ("Timers", "Settings")
- Break slot labels ("Morning Break", "Lunch Break", "Afternoon Break")
- Notification text ("Test fired", "Test notification")
- Button labels ("► test", "← back", "edit label ›")
- Day names (Sun–Sat)
- Settings field labels ("Break time", "Duration", "Alert sound")
- Snackbar messages
- Dialog content
- Validation/error messages

### Initial Languages
Start with:
1. **English** (en) — base language
2. **Spanish** (es) — large global population
3. **German** (de) — significant European userbase
4. **Japanese** (ja) — workplace culture overlap
5. **Arabic** (ar) — RTL testing + large population

### Locale Selection in UI
Consider adding a language picker in Settings:
```dart
_SettingRow(
  label: 'Language',
  value: l10n.languageName,  // e.g., "English", "Español"
  onTap: () => _showLanguagePicker(context),
)
```

---

## 15. Step-by-Step Implementation for Pavlovian

1. **Create `lib/l10n/` directory**
2. **Extract all strings to `app_en.arb`**
3. **Update `pubspec.yaml`** with `flutter_localizations`
4. **Create `l10n.yaml`** in project root
5. **Run `flutter gen-l10n`** to generate localization code
6. **Update `main.dart`** to add `localizationsDelegates` and `supportedLocales`
7. **Replace all hardcoded strings** with `AppLocalizations.of(context)!.key`
8. **Create translation files** (`app_es.arb`, `app_fr.arb`, etc.)
9. **Test each locale** on device or emulator
10. **Test RTL** with Arabic (`app_ar.arb`)

---

## References
- [Flutter Internationalization Guide](https://flutter.dev/docs/development/accessibility-and-localization/internationalization)
- [ARB Format Specification](https://github.com/google/app-resource-bundle)
- [`intl` Package](https://pub.dev/packages/intl) — date/time/number formatting
- [Android Localization (Native)](https://developer.android.com/guide/topics/resources/localization)
