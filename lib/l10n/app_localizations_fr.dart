// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get app_name => 'Pavlovian';

  @override
  String get app_tagline => 'rappels de temps de pause';

  @override
  String get app_byline => 'par HST';

  @override
  String get timers_screen_title => 'Minuteurs';

  @override
  String get global_all_on => 'TOUS ACTIVÉS';

  @override
  String get global_all_off => 'TOUS DÉSACTIVÉS';

  @override
  String get subtitle_all_timers_off => 'tous les minuteurs désactivés';

  @override
  String get subtitle_active_count => 'actif';

  @override
  String get subtitle_paused_for => 'en pause pour';

  @override
  String get legend_annotation => '↓ s\'exécute chaque jour activé';

  @override
  String get day_master_card_label => ' minuteurs';

  @override
  String get day_master_card_pauses =>
      'met en pause tous les minuteurs juste pour aujourd\'hui';

  @override
  String get day_master_card_paused => '✕ en pause pour aujourd\'hui';

  @override
  String get slot_status_running => '⏱ ';

  @override
  String get slot_status_left => ' restant';

  @override
  String get slot_status_enabled => 'chaque jour activé';

  @override
  String get slot_status_disabled => 'désactivé — toute la semaine';

  @override
  String get button_start => '▶ démarrer';

  @override
  String get button_clear => '■ effacer';

  @override
  String get settings_screen_title => 'Paramètres';

  @override
  String get section_break_slots => '① Créneaux de pause';

  @override
  String get section_working_days => '② Jours de travail';

  @override
  String get section_notifications => '③ Notifications';

  @override
  String get section_reset => '④ Réinitialiser';

  @override
  String get slot_header_edit => 'modifier l\'étiquette ›';

  @override
  String get slot_field_break_time => 'Heure de la pause';

  @override
  String get slot_field_duration => 'Durée';

  @override
  String get slot_field_alert_sound => 'Son d\'alerte';

  @override
  String get duration_suffix => ' min';

  @override
  String delete_dialog_title(Object label) {
    return 'Supprimer \"$label\" ?';
  }

  @override
  String get delete_dialog_content =>
      'Cette pause et ses alarmes seront supprimées.';

  @override
  String get delete_button => 'supprimer';

  @override
  String get cancel_button => 'annuler';

  @override
  String get working_days_description =>
      'Les minuteurs s\'exécutent uniquement les jours cochés.';

  @override
  String get working_days_help_text =>
      'appuyez sur un jour pour le basculer activé/désactivé';

  @override
  String get test_notification_label => 'Notification de test';

  @override
  String get test_notification_description =>
      'déclenche une alerte d\'exemple avec le son de l\'emplacement 1';

  @override
  String get test_button => '▶ test';

  @override
  String get alert_sound_label => 'Son d\'alerte';

  @override
  String get end_of_break_sound_label => 'Son de fin de pause';

  @override
  String get notifications_enabled_label => 'Afficher les notifications';

  @override
  String get notifications_enabled_description =>
      'envoyer des alertes de pause dans la barre de notification';

  @override
  String get sound_enabled_label => 'Jouer un son lors d\'une alerte';

  @override
  String get sound_enabled_description =>
      'jouer de l\'audio quand une notification de pause se déclenche';

  @override
  String get both_alerts_off_warning =>
      'Les deux alertes sont désactivées — pour silence toutes les pauses, utilisez l\'interrupteur TOUT ÉTEINT sur l\'écran principal.';

  @override
  String get vibrate_label => 'Vibrer en cas d\'alerte';

  @override
  String get flash_led_label => 'Flasher le LED en cas d\'alerte';

  @override
  String get reset_title => 'Réinitialiser aux valeurs par défaut';

  @override
  String get reset_description => 'restaure les heures, durées et sons';

  @override
  String get reset_annotation =>
      '↑ affiche d\'abord un dialogue de confirmation';

  @override
  String get reset_dialog_title => 'Réinitialiser tous les paramètres ?';

  @override
  String get reset_dialog_content =>
      'Tous les heures, durées, étiquettes et interrupteurs reviennent aux valeurs par défaut. Votre son de test sélectionné est conservé (les sons d\'emplacement le correspondent).';

  @override
  String get reset_button => 'réinitialiser';

  @override
  String get add_break_button => '+ Ajouter une pause';

  @override
  String get settings_reset_snackbar =>
      'Paramètres réinitialisés aux valeurs par défaut.';

  @override
  String get slot_label_default_1 => 'Pause du matin';

  @override
  String get slot_label_default_2 => 'Pause déjeuner';

  @override
  String get slot_label_default_3 => 'Pause de l\'après-midi';

  @override
  String get splash_loading_text => 'chargement…';

  @override
  String get splash_working_days_badge => 'chaque jour · configurable';

  @override
  String get drawer_settings_item => 'Paramètres';

  @override
  String get drawer_rooster_credit =>
      'son de coq attribué à\nRibhav Agrawal @ pixabay.com';

  @override
  String get drawer_cuckoo_credit =>
      'son de coucou attribué à\nMonkay @ freesound.org';

  @override
  String get edit_label_dialog_title => 'Renommer l\'emplacement';

  @override
  String get edit_label_dialog_hint => 'ex. Pause du matin';

  @override
  String get edit_label_save_button => 'enregistrer';

  @override
  String get edit_duration_sheet_title => 'Durée de la pause';

  @override
  String get edit_duration_sheet_subtitle => 'Pas de 5 minutes';

  @override
  String get edit_duration_min_suffix => ' min';

  @override
  String get edit_duration_save_button => 'enregistrer';

  @override
  String get edit_sound_sheet_title => 'Son d\'alerte';

  @override
  String get edit_sound_sheet_subtitle => 'appuyez pour prévisualiser';

  @override
  String get edit_sound_more_sounds => 'Plus de sons…';

  @override
  String get edit_sound_save_button => 'enregistrer';

  @override
  String get notification_channel_description => 'Rappel de pause';

  @override
  String notification_channel_description_full(Object slotLabel) {
    return 'Rappel de pause pour \"$slotLabel\"';
  }

  @override
  String get test_notification_title => 'Alerte de test des minuteurs';

  @override
  String test_notification_body(
    Object led,
    Object soundName,
    Object vibration,
  ) {
    return 'Test d\'alerte — $soundName$vibration$led.';
  }

  @override
  String get test_notification_vibration => ', vibration activée';

  @override
  String get test_notification_led => ', LED activée';

  @override
  String break_time_notification_title(Object slotId) {
    return 'Pavlovian — emplacement $slotId';
  }

  @override
  String break_time_notification_body(Object duration, Object slotLabel) {
    return 'Heure de la pause — c\'est $slotLabel. Profitez de vos $duration minutes.';
  }

  @override
  String break_end_notification_title(Object slotId) {
    return 'Pavlovian — emplacement $slotId';
  }

  @override
  String break_end_notification_body(Object duration) {
    return 'Pause terminée — votre pause de $duration minutes est terminée. Il est temps de revenir.';
  }

  @override
  String get notification_action_button => '▶ Démarrer le compte à rebours';

  @override
  String get diagnostics_screen_title => 'Diagnostics';

  @override
  String get diagnostics_refresh_tooltip => 'Actualiser';

  @override
  String get diagnostics_copy_tooltip => 'Copier';

  @override
  String get diagnostics_copy_snackbar =>
      'Diagnostics copiés dans le presse-papiers';

  @override
  String get diagnostics_reschedule_button => 'Re-exécuter scheduleAll';

  @override
  String get diagnostics_clear_log_button => 'Effacer le journal';

  @override
  String get diagnostics_header => '═══ Diagnostics Pavlovian ═══';

  @override
  String get diagnostics_captured_prefix => 'Capturé : ';

  @override
  String get diagnostics_settings_section => '── Paramètres persistants ──';

  @override
  String get diagnostics_settings_loading =>
      '(paramètres en cours de chargement)';

  @override
  String get diagnostics_permissions_section => '── Autorisations ──';

  @override
  String get diagnostics_permissions_label => 'canScheduleExactAlarms: ';

  @override
  String get diagnostics_pending_section => '── Liste d\'attente du plugin ──';

  @override
  String get diagnostics_pending_label =>
      'décompte de pendingNotificationRequests: ';

  @override
  String get diagnostics_pending_error =>
      'pendingNotificationRequests A LEVÉ: ';

  @override
  String get diagnostics_fire_times_section =>
      '── Heures de déclenchement calculées ──';

  @override
  String get diagnostics_fire_times_skipped => '(ignoré — pas de paramètres)';

  @override
  String get diagnostics_fire_times_skipped_disabled =>
      '(ignoré — globalEnabled est DÉSACTIVÉ)';

  @override
  String get diagnostics_slot_disabled => ' DÉSACTIVÉ — ignorer';

  @override
  String get diagnostics_log_section => '── Journal (le plus récent en bas) ──';

  @override
  String get diagnostics_log_empty => '(journal vide)';

  @override
  String get error_screen_prefix => 'Impossible de charger les paramètres:\n';

  @override
  String get day_sun_short => 'Dim';

  @override
  String get day_mon_short => 'Lun';

  @override
  String get day_tue_short => 'Mar';

  @override
  String get day_wed_short => 'Mer';

  @override
  String get day_thu_short => 'Jeu';

  @override
  String get day_fri_short => 'Ven';

  @override
  String get day_sat_short => 'Sam';

  @override
  String get day_sun_full => 'Dimanche';

  @override
  String get day_mon_full => 'Lundi';

  @override
  String get day_tue_full => 'Mardi';

  @override
  String get day_wed_full => 'Mercredi';

  @override
  String get day_thu_full => 'Jeudi';

  @override
  String get day_fri_full => 'Vendredi';

  @override
  String get day_sat_full => 'Samedi';

  @override
  String get section_break_slots_title => '① Créneaux de pause';

  @override
  String get section_working_days_title => '② Jours de travail';

  @override
  String get section_notifications_title => '③ Notifications';

  @override
  String get section_language_title => '④ Langue';

  @override
  String get section_reset_title => '⑤ Réinitialiser';
}
