// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_name => 'Pavlovian';

  @override
  String get app_tagline => 'break time reminders';

  @override
  String get app_byline => 'by HST';

  @override
  String get timers_screen_title => 'Timers';

  @override
  String get global_all_on => 'ALL ON';

  @override
  String get global_all_off => 'ALL OFF';

  @override
  String get subtitle_all_timers_off => 'all timers off';

  @override
  String get subtitle_active_count => 'active';

  @override
  String get subtitle_paused_for => 'paused for';

  @override
  String get legend_annotation => '↓ runs on each enabled day';

  @override
  String get day_master_card_label => ' timers';

  @override
  String get day_master_card_pauses => 'pauses every timer just for today';

  @override
  String get day_master_card_paused => '✕ paused for today';

  @override
  String get slot_status_running => '⏱ ';

  @override
  String get slot_status_left => ' left';

  @override
  String get slot_status_enabled => 'every enabled day';

  @override
  String get slot_status_disabled => 'off — whole week';

  @override
  String get button_start => '▶ start';

  @override
  String get button_clear => '■ clear';

  @override
  String get settings_screen_title => 'Settings';

  @override
  String get section_break_slots => '① Break Slots';

  @override
  String get section_working_days => '② Working Days';

  @override
  String get section_notifications => '③ Notifications';

  @override
  String get section_reset => '④ Reset';

  @override
  String get slot_header_edit => 'edit label ›';

  @override
  String get slot_field_break_time => 'Break time';

  @override
  String get slot_field_duration => 'Duration';

  @override
  String get slot_field_alert_sound => 'Alert sound';

  @override
  String get duration_suffix => ' min';

  @override
  String delete_dialog_title(Object label) {
    return 'Delete \"$label\"?';
  }

  @override
  String get delete_dialog_content =>
      'This break and its alarms will be removed.';

  @override
  String get delete_button => 'delete';

  @override
  String get cancel_button => 'cancel';

  @override
  String get working_days_description => 'Timers fire on checked days only.';

  @override
  String get working_days_help_text => 'tap a day to toggle it on / off';

  @override
  String get test_notification_label => 'Test notification';

  @override
  String get test_notification_description =>
      'fires a sample alert with slot 1\'s sound';

  @override
  String get test_button => '▶ test';

  @override
  String get alert_sound_label => 'Alert sound';

  @override
  String get end_of_break_sound_label => 'End-of-break sound';

  @override
  String get notifications_enabled_label => 'Show notifications';

  @override
  String get notifications_enabled_description =>
      'send break alerts to the notification bar';

  @override
  String get sound_enabled_label => 'Play sound on alert';

  @override
  String get sound_enabled_description =>
      'play audio when a break notification fires';

  @override
  String get both_alerts_off_warning =>
      'Both alerts are off — to silence all breaks use the ALL OFF switch on the main screen instead.';

  @override
  String get vibrate_label => 'Vibrate on alert';

  @override
  String get flash_led_label => 'Flash LED on alert';

  @override
  String get reset_title => 'Reset All to Defaults';

  @override
  String get reset_description => 'restores times, durations & sounds';

  @override
  String get reset_annotation => '↑ shows a confirm dialog first';

  @override
  String get reset_dialog_title => 'Reset all settings?';

  @override
  String get reset_dialog_content =>
      'All times, durations, labels and toggles return to defaults. Your selected test sound is kept (slot sounds match it).';

  @override
  String get reset_button => 'reset';

  @override
  String get add_break_button => '+ Add a break';

  @override
  String get settings_reset_snackbar => 'Settings reset to defaults.';

  @override
  String get slot_label_default_1 => 'Morning Break';

  @override
  String get slot_label_default_2 => 'Lunch Break';

  @override
  String get slot_label_default_3 => 'Afternoon Break';

  @override
  String get splash_loading_text => 'loading…';

  @override
  String get splash_working_days_badge => 'every day · configurable';

  @override
  String get drawer_settings_item => 'Settings';

  @override
  String get drawer_rooster_credit =>
      'rooster sound attribute to\nRibhav Agrawal @ pixabay.com';

  @override
  String get drawer_cuckoo_credit =>
      'cuckoo sound attribute to\nMonkay @ freesound.org';

  @override
  String get edit_label_dialog_title => 'Rename slot';

  @override
  String get edit_label_dialog_hint => 'e.g. Morning Break';

  @override
  String get edit_label_save_button => 'save';

  @override
  String get edit_duration_sheet_title => 'Break duration';

  @override
  String get edit_duration_sheet_subtitle => '5-minute steps';

  @override
  String get edit_duration_min_suffix => ' min';

  @override
  String get edit_duration_save_button => 'save';

  @override
  String get edit_sound_sheet_title => 'Alert sound';

  @override
  String get edit_sound_sheet_subtitle => 'tap to preview';

  @override
  String get edit_sound_more_sounds => 'More sounds…';

  @override
  String get edit_sound_save_button => 'save';

  @override
  String get notification_channel_description => 'Break reminder';

  @override
  String notification_channel_description_full(Object slotLabel) {
    return 'Break reminder for \"$slotLabel\"';
  }

  @override
  String get test_notification_title => 'Timers Test Alert';

  @override
  String test_notification_body(
    Object led,
    Object soundName,
    Object vibration,
  ) {
    return 'Testing alert — $soundName$vibration$led.';
  }

  @override
  String get test_notification_vibration => ', vibration on';

  @override
  String get test_notification_led => ', LED on';

  @override
  String break_time_notification_title(Object slotId) {
    return 'Pavlovian — slot $slotId';
  }

  @override
  String break_time_notification_body(Object duration, Object slotLabel) {
    return 'Break time — it\'s $slotLabel. Enjoy your $duration minutes.';
  }

  @override
  String break_end_notification_title(Object slotId) {
    return 'Pavlovian — slot $slotId';
  }

  @override
  String break_end_notification_body(Object duration) {
    return 'Break over — your $duration-minute break has ended. Time to head back.';
  }

  @override
  String get notification_action_button => '▶ Start countdown';

  @override
  String get diagnostics_screen_title => 'Diagnostics';

  @override
  String get diagnostics_refresh_tooltip => 'Refresh';

  @override
  String get diagnostics_copy_tooltip => 'Copy';

  @override
  String get diagnostics_copy_snackbar => 'Diagnostics copied to clipboard';

  @override
  String get diagnostics_reschedule_button => 'Re-run scheduleAll';

  @override
  String get diagnostics_clear_log_button => 'Clear log';

  @override
  String get diagnostics_header => '═══ Pavlovian Diagnostics ═══';

  @override
  String get diagnostics_captured_prefix => 'Captured: ';

  @override
  String get diagnostics_settings_section => '── Persisted settings ──';

  @override
  String get diagnostics_settings_loading => '(settings still loading)';

  @override
  String get diagnostics_permissions_section => '── Permissions ──';

  @override
  String get diagnostics_permissions_label => 'canScheduleExactAlarms: ';

  @override
  String get diagnostics_pending_section => '── Plugin pending list ──';

  @override
  String get diagnostics_pending_label => 'pendingNotificationRequests count: ';

  @override
  String get diagnostics_pending_error => 'pendingNotificationRequests THREW: ';

  @override
  String get diagnostics_fire_times_section => '── Computed next fire times ──';

  @override
  String get diagnostics_fire_times_skipped => '(skipped — no settings)';

  @override
  String get diagnostics_fire_times_skipped_disabled =>
      '(skipped — globalEnabled is OFF)';

  @override
  String get diagnostics_slot_disabled => ' DISABLED — skip';

  @override
  String get diagnostics_log_section => '── Log (latest at bottom) ──';

  @override
  String get diagnostics_log_empty => '(log empty)';

  @override
  String get error_screen_prefix => 'Couldn\'t load settings:\n';

  @override
  String get day_sun_short => 'Sun';

  @override
  String get day_mon_short => 'Mon';

  @override
  String get day_tue_short => 'Tue';

  @override
  String get day_wed_short => 'Wed';

  @override
  String get day_thu_short => 'Thu';

  @override
  String get day_fri_short => 'Fri';

  @override
  String get day_sat_short => 'Sat';

  @override
  String get day_sun_full => 'Sunday';

  @override
  String get day_mon_full => 'Monday';

  @override
  String get day_tue_full => 'Tuesday';

  @override
  String get day_wed_full => 'Wednesday';

  @override
  String get day_thu_full => 'Thursday';

  @override
  String get day_fri_full => 'Friday';

  @override
  String get day_sat_full => 'Saturday';

  @override
  String get section_break_slots_title => '① Break Slots';

  @override
  String get section_working_days_title => '② Working Days';

  @override
  String get section_notifications_title => '③ Notifications';

  @override
  String get section_language_title => '④ Language';

  @override
  String get section_reset_title => '⑤ Reset';
}
