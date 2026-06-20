import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
  ];

  /// No description provided for @app_name.
  ///
  /// In en, this message translates to:
  /// **'Pavlovian'**
  String get app_name;

  /// No description provided for @app_tagline.
  ///
  /// In en, this message translates to:
  /// **'break time reminders'**
  String get app_tagline;

  /// No description provided for @app_byline.
  ///
  /// In en, this message translates to:
  /// **'by HST'**
  String get app_byline;

  /// No description provided for @timers_screen_title.
  ///
  /// In en, this message translates to:
  /// **'Timers'**
  String get timers_screen_title;

  /// No description provided for @global_all_on.
  ///
  /// In en, this message translates to:
  /// **'ALL ON'**
  String get global_all_on;

  /// No description provided for @global_all_off.
  ///
  /// In en, this message translates to:
  /// **'ALL OFF'**
  String get global_all_off;

  /// No description provided for @subtitle_all_timers_off.
  ///
  /// In en, this message translates to:
  /// **'all timers off'**
  String get subtitle_all_timers_off;

  /// No description provided for @subtitle_active_count.
  ///
  /// In en, this message translates to:
  /// **'active'**
  String get subtitle_active_count;

  /// No description provided for @subtitle_paused_for.
  ///
  /// In en, this message translates to:
  /// **'paused for'**
  String get subtitle_paused_for;

  /// No description provided for @legend_annotation.
  ///
  /// In en, this message translates to:
  /// **'↓ runs on each enabled day'**
  String get legend_annotation;

  /// No description provided for @day_master_card_label.
  ///
  /// In en, this message translates to:
  /// **' timers'**
  String get day_master_card_label;

  /// No description provided for @day_master_card_pauses.
  ///
  /// In en, this message translates to:
  /// **'pauses every timer just for today'**
  String get day_master_card_pauses;

  /// No description provided for @day_master_card_paused.
  ///
  /// In en, this message translates to:
  /// **'✕ paused for today'**
  String get day_master_card_paused;

  /// No description provided for @slot_status_running.
  ///
  /// In en, this message translates to:
  /// **'⏱ '**
  String get slot_status_running;

  /// No description provided for @slot_status_left.
  ///
  /// In en, this message translates to:
  /// **' left'**
  String get slot_status_left;

  /// No description provided for @slot_status_enabled.
  ///
  /// In en, this message translates to:
  /// **'every enabled day'**
  String get slot_status_enabled;

  /// No description provided for @slot_status_disabled.
  ///
  /// In en, this message translates to:
  /// **'off — whole week'**
  String get slot_status_disabled;

  /// No description provided for @button_start.
  ///
  /// In en, this message translates to:
  /// **'▶ start'**
  String get button_start;

  /// No description provided for @button_clear.
  ///
  /// In en, this message translates to:
  /// **'■ clear'**
  String get button_clear;

  /// No description provided for @settings_screen_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_screen_title;

  /// No description provided for @section_break_slots.
  ///
  /// In en, this message translates to:
  /// **'① Break Slots'**
  String get section_break_slots;

  /// No description provided for @section_working_days.
  ///
  /// In en, this message translates to:
  /// **'② Working Days'**
  String get section_working_days;

  /// No description provided for @section_notifications.
  ///
  /// In en, this message translates to:
  /// **'③ Notifications'**
  String get section_notifications;

  /// No description provided for @section_reset.
  ///
  /// In en, this message translates to:
  /// **'④ Reset'**
  String get section_reset;

  /// No description provided for @slot_header_edit.
  ///
  /// In en, this message translates to:
  /// **'edit label ›'**
  String get slot_header_edit;

  /// No description provided for @slot_field_break_time.
  ///
  /// In en, this message translates to:
  /// **'Break time'**
  String get slot_field_break_time;

  /// No description provided for @slot_field_duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get slot_field_duration;

  /// No description provided for @slot_field_alert_sound.
  ///
  /// In en, this message translates to:
  /// **'Alert sound'**
  String get slot_field_alert_sound;

  /// No description provided for @duration_suffix.
  ///
  /// In en, this message translates to:
  /// **' min'**
  String get duration_suffix;

  /// No description provided for @delete_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{label}\"?'**
  String delete_dialog_title(Object label);

  /// No description provided for @delete_dialog_content.
  ///
  /// In en, this message translates to:
  /// **'This break and its alarms will be removed.'**
  String get delete_dialog_content;

  /// No description provided for @delete_button.
  ///
  /// In en, this message translates to:
  /// **'delete'**
  String get delete_button;

  /// No description provided for @cancel_button.
  ///
  /// In en, this message translates to:
  /// **'cancel'**
  String get cancel_button;

  /// No description provided for @working_days_description.
  ///
  /// In en, this message translates to:
  /// **'Timers fire on checked days only.'**
  String get working_days_description;

  /// No description provided for @working_days_help_text.
  ///
  /// In en, this message translates to:
  /// **'tap a day to toggle it on / off'**
  String get working_days_help_text;

  /// No description provided for @test_notification_label.
  ///
  /// In en, this message translates to:
  /// **'Test notification'**
  String get test_notification_label;

  /// No description provided for @test_notification_description.
  ///
  /// In en, this message translates to:
  /// **'fires a sample alert with slot 1\'s sound'**
  String get test_notification_description;

  /// No description provided for @test_button.
  ///
  /// In en, this message translates to:
  /// **'▶ test'**
  String get test_button;

  /// No description provided for @alert_sound_label.
  ///
  /// In en, this message translates to:
  /// **'Alert sound'**
  String get alert_sound_label;

  /// No description provided for @end_of_break_sound_label.
  ///
  /// In en, this message translates to:
  /// **'End-of-break sound'**
  String get end_of_break_sound_label;

  /// No description provided for @vibrate_label.
  ///
  /// In en, this message translates to:
  /// **'Vibrate on alert'**
  String get vibrate_label;

  /// No description provided for @flash_led_label.
  ///
  /// In en, this message translates to:
  /// **'Flash LED on alert'**
  String get flash_led_label;

  /// No description provided for @reset_title.
  ///
  /// In en, this message translates to:
  /// **'Reset All to Defaults'**
  String get reset_title;

  /// No description provided for @reset_description.
  ///
  /// In en, this message translates to:
  /// **'restores times, durations & sounds'**
  String get reset_description;

  /// No description provided for @reset_annotation.
  ///
  /// In en, this message translates to:
  /// **'↑ shows a confirm dialog first'**
  String get reset_annotation;

  /// No description provided for @reset_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Reset all settings?'**
  String get reset_dialog_title;

  /// No description provided for @reset_dialog_content.
  ///
  /// In en, this message translates to:
  /// **'All times, durations, labels and toggles return to defaults. Your selected test sound is kept (slot sounds match it).'**
  String get reset_dialog_content;

  /// No description provided for @reset_button.
  ///
  /// In en, this message translates to:
  /// **'reset'**
  String get reset_button;

  /// No description provided for @add_break_button.
  ///
  /// In en, this message translates to:
  /// **'+ Add a break'**
  String get add_break_button;

  /// No description provided for @settings_reset_snackbar.
  ///
  /// In en, this message translates to:
  /// **'Settings reset to defaults.'**
  String get settings_reset_snackbar;

  /// No description provided for @morning_break_default.
  ///
  /// In en, this message translates to:
  /// **'Morning Break'**
  String get morning_break_default;

  /// No description provided for @lunch_break_default.
  ///
  /// In en, this message translates to:
  /// **'Lunch Break'**
  String get lunch_break_default;

  /// No description provided for @afternoon_break_default.
  ///
  /// In en, this message translates to:
  /// **'Afternoon Break'**
  String get afternoon_break_default;

  /// No description provided for @splash_loading_text.
  ///
  /// In en, this message translates to:
  /// **'loading…'**
  String get splash_loading_text;

  /// No description provided for @splash_working_days_badge.
  ///
  /// In en, this message translates to:
  /// **'every day · configurable'**
  String get splash_working_days_badge;

  /// No description provided for @drawer_settings_item.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get drawer_settings_item;

  /// No description provided for @drawer_rooster_credit.
  ///
  /// In en, this message translates to:
  /// **'rooster sound attribute to\nRibhav Agrawal @ pixabay.com'**
  String get drawer_rooster_credit;

  /// No description provided for @drawer_cuckoo_credit.
  ///
  /// In en, this message translates to:
  /// **'cuckoo sound attribute to\nMonkay @ freesound.org'**
  String get drawer_cuckoo_credit;

  /// No description provided for @edit_label_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Rename slot'**
  String get edit_label_dialog_title;

  /// No description provided for @edit_label_dialog_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Morning Break'**
  String get edit_label_dialog_hint;

  /// No description provided for @edit_label_save_button.
  ///
  /// In en, this message translates to:
  /// **'save'**
  String get edit_label_save_button;

  /// No description provided for @edit_duration_sheet_title.
  ///
  /// In en, this message translates to:
  /// **'Break duration'**
  String get edit_duration_sheet_title;

  /// No description provided for @edit_duration_sheet_subtitle.
  ///
  /// In en, this message translates to:
  /// **'5-minute steps'**
  String get edit_duration_sheet_subtitle;

  /// No description provided for @edit_duration_min_suffix.
  ///
  /// In en, this message translates to:
  /// **' min'**
  String get edit_duration_min_suffix;

  /// No description provided for @edit_duration_save_button.
  ///
  /// In en, this message translates to:
  /// **'save'**
  String get edit_duration_save_button;

  /// No description provided for @edit_sound_sheet_title.
  ///
  /// In en, this message translates to:
  /// **'Alert sound'**
  String get edit_sound_sheet_title;

  /// No description provided for @edit_sound_sheet_subtitle.
  ///
  /// In en, this message translates to:
  /// **'tap to preview'**
  String get edit_sound_sheet_subtitle;

  /// No description provided for @edit_sound_more_sounds.
  ///
  /// In en, this message translates to:
  /// **'More sounds…'**
  String get edit_sound_more_sounds;

  /// No description provided for @edit_sound_save_button.
  ///
  /// In en, this message translates to:
  /// **'save'**
  String get edit_sound_save_button;

  /// No description provided for @notification_channel_description.
  ///
  /// In en, this message translates to:
  /// **'Break reminder'**
  String get notification_channel_description;

  /// No description provided for @notification_channel_description_full.
  ///
  /// In en, this message translates to:
  /// **'Break reminder for \"{slotLabel}\"'**
  String notification_channel_description_full(Object slotLabel);

  /// No description provided for @test_notification_title.
  ///
  /// In en, this message translates to:
  /// **'Timers Test Alert'**
  String get test_notification_title;

  /// No description provided for @test_notification_body.
  ///
  /// In en, this message translates to:
  /// **'Testing alert — {soundName}{vibration}{led}.'**
  String test_notification_body(Object led, Object soundName, Object vibration);

  /// No description provided for @test_notification_vibration.
  ///
  /// In en, this message translates to:
  /// **', vibration on'**
  String get test_notification_vibration;

  /// No description provided for @test_notification_led.
  ///
  /// In en, this message translates to:
  /// **', LED on'**
  String get test_notification_led;

  /// No description provided for @break_time_notification_title.
  ///
  /// In en, this message translates to:
  /// **'Pavlovian — slot {slotId}'**
  String break_time_notification_title(Object slotId);

  /// No description provided for @break_time_notification_body.
  ///
  /// In en, this message translates to:
  /// **'Break time — it\'s {slotLabel}. Enjoy your {duration} minutes.'**
  String break_time_notification_body(Object duration, Object slotLabel);

  /// No description provided for @break_end_notification_title.
  ///
  /// In en, this message translates to:
  /// **'Pavlovian — slot {slotId}'**
  String break_end_notification_title(Object slotId);

  /// No description provided for @break_end_notification_body.
  ///
  /// In en, this message translates to:
  /// **'Break over — your {duration}-minute break has ended. Time to head back.'**
  String break_end_notification_body(Object duration);

  /// No description provided for @notification_action_button.
  ///
  /// In en, this message translates to:
  /// **'▶ Start countdown'**
  String get notification_action_button;

  /// No description provided for @diagnostics_screen_title.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics'**
  String get diagnostics_screen_title;

  /// No description provided for @diagnostics_refresh_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get diagnostics_refresh_tooltip;

  /// No description provided for @diagnostics_copy_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get diagnostics_copy_tooltip;

  /// No description provided for @diagnostics_copy_snackbar.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics copied to clipboard'**
  String get diagnostics_copy_snackbar;

  /// No description provided for @diagnostics_reschedule_button.
  ///
  /// In en, this message translates to:
  /// **'Re-run scheduleAll'**
  String get diagnostics_reschedule_button;

  /// No description provided for @diagnostics_clear_log_button.
  ///
  /// In en, this message translates to:
  /// **'Clear log'**
  String get diagnostics_clear_log_button;

  /// No description provided for @diagnostics_header.
  ///
  /// In en, this message translates to:
  /// **'═══ Pavlovian Diagnostics ═══'**
  String get diagnostics_header;

  /// No description provided for @diagnostics_captured_prefix.
  ///
  /// In en, this message translates to:
  /// **'Captured: '**
  String get diagnostics_captured_prefix;

  /// No description provided for @diagnostics_settings_section.
  ///
  /// In en, this message translates to:
  /// **'── Persisted settings ──'**
  String get diagnostics_settings_section;

  /// No description provided for @diagnostics_settings_loading.
  ///
  /// In en, this message translates to:
  /// **'(settings still loading)'**
  String get diagnostics_settings_loading;

  /// No description provided for @diagnostics_permissions_section.
  ///
  /// In en, this message translates to:
  /// **'── Permissions ──'**
  String get diagnostics_permissions_section;

  /// No description provided for @diagnostics_permissions_label.
  ///
  /// In en, this message translates to:
  /// **'canScheduleExactAlarms: '**
  String get diagnostics_permissions_label;

  /// No description provided for @diagnostics_pending_section.
  ///
  /// In en, this message translates to:
  /// **'── Plugin pending list ──'**
  String get diagnostics_pending_section;

  /// No description provided for @diagnostics_pending_label.
  ///
  /// In en, this message translates to:
  /// **'pendingNotificationRequests count: '**
  String get diagnostics_pending_label;

  /// No description provided for @diagnostics_pending_error.
  ///
  /// In en, this message translates to:
  /// **'pendingNotificationRequests THREW: '**
  String get diagnostics_pending_error;

  /// No description provided for @diagnostics_fire_times_section.
  ///
  /// In en, this message translates to:
  /// **'── Computed next fire times ──'**
  String get diagnostics_fire_times_section;

  /// No description provided for @diagnostics_fire_times_skipped.
  ///
  /// In en, this message translates to:
  /// **'(skipped — no settings)'**
  String get diagnostics_fire_times_skipped;

  /// No description provided for @diagnostics_fire_times_skipped_disabled.
  ///
  /// In en, this message translates to:
  /// **'(skipped — globalEnabled is OFF)'**
  String get diagnostics_fire_times_skipped_disabled;

  /// No description provided for @diagnostics_slot_disabled.
  ///
  /// In en, this message translates to:
  /// **' DISABLED — skip'**
  String get diagnostics_slot_disabled;

  /// No description provided for @diagnostics_log_section.
  ///
  /// In en, this message translates to:
  /// **'── Log (latest at bottom) ──'**
  String get diagnostics_log_section;

  /// No description provided for @diagnostics_log_empty.
  ///
  /// In en, this message translates to:
  /// **'(log empty)'**
  String get diagnostics_log_empty;

  /// No description provided for @error_screen_prefix.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load settings:\n'**
  String get error_screen_prefix;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
