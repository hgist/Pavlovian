// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get app_name => 'Pavlovian';

  @override
  String get app_tagline => 'recordatorios de tiempo de descanso';

  @override
  String get app_byline => 'por HST';

  @override
  String get timers_screen_title => 'Temporizadores';

  @override
  String get global_all_on => 'TODO ENCENDIDO';

  @override
  String get global_all_off => 'TODO APAGADO';

  @override
  String get subtitle_all_timers_off => 'todos los temporizadores apagados';

  @override
  String get subtitle_active_count => 'activo';

  @override
  String get subtitle_paused_for => 'pausado para';

  @override
  String get legend_annotation => '↓ se ejecuta cada día habilitado';

  @override
  String get day_master_card_label => ' temporizadores';

  @override
  String get day_master_card_pauses =>
      'pausa todos los temporizadores solo para hoy';

  @override
  String get day_master_card_paused => '✕ pausado para hoy';

  @override
  String get slot_status_running => '⏱ ';

  @override
  String get slot_status_left => ' restantes';

  @override
  String get slot_status_enabled => 'cada día habilitado';

  @override
  String get slot_status_disabled => 'apagado — toda la semana';

  @override
  String get button_start => '▶ iniciar';

  @override
  String get button_clear => '■ limpiar';

  @override
  String get settings_screen_title => 'Configuración';

  @override
  String get section_break_slots => '① Espacios de descanso';

  @override
  String get section_working_days => '② Días de trabajo';

  @override
  String get section_notifications => '③ Notificaciones';

  @override
  String get section_reset => '④ Reiniciar';

  @override
  String get slot_header_edit => 'editar etiqueta ›';

  @override
  String get slot_field_break_time => 'Hora de descanso';

  @override
  String get slot_field_duration => 'Duración';

  @override
  String get slot_field_alert_sound => 'Sonido de alerta';

  @override
  String get duration_suffix => ' min';

  @override
  String delete_dialog_title(Object label) {
    return '¿Eliminar \"$label\"?';
  }

  @override
  String get delete_dialog_content =>
      'Este descanso y sus alarmas serán eliminados.';

  @override
  String get delete_button => 'eliminar';

  @override
  String get cancel_button => 'cancelar';

  @override
  String get working_days_description =>
      'Los temporizadores se ejecutan solo en días marcados.';

  @override
  String get working_days_help_text =>
      'toca un día para alternarlo entre activado/desactivado';

  @override
  String get test_notification_label => 'Notificación de prueba';

  @override
  String get test_notification_description =>
      'dispara una alerta de muestra con el sonido del slot 1';

  @override
  String get test_button => '▶ probar';

  @override
  String get alert_sound_label => 'Sonido de alerta';

  @override
  String get end_of_break_sound_label => 'Sonido de fin de descanso';

  @override
  String get vibrate_label => 'Vibrar en alerta';

  @override
  String get flash_led_label => 'Parpadear LED en alerta';

  @override
  String get reset_title => 'Reiniciar a valores predeterminados';

  @override
  String get reset_description => 'restaura tiempos, duraciones y sonidos';

  @override
  String get reset_annotation => '↑ muestra un diálogo de confirmación primero';

  @override
  String get reset_dialog_title => '¿Reiniciar todas las configuraciones?';

  @override
  String get reset_dialog_content =>
      'Todos los tiempos, duraciones, etiquetas e interruptores vuelven a los valores predeterminados. Tu sonido de prueba seleccionado se mantiene (los sonidos de slot coinciden con él).';

  @override
  String get reset_button => 'reiniciar';

  @override
  String get add_break_button => '+ Agregar un descanso';

  @override
  String get settings_reset_snackbar =>
      'Configuración reiniciada a valores predeterminados.';

  @override
  String get slot_label_default_1 => 'Descanso matutino';

  @override
  String get slot_label_default_2 => 'Descanso del almuerzo';

  @override
  String get slot_label_default_3 => 'Descanso vespertino';

  @override
  String get splash_loading_text => 'cargando…';

  @override
  String get splash_working_days_badge => 'todos los días · configurable';

  @override
  String get drawer_settings_item => 'Configuración';

  @override
  String get drawer_rooster_credit =>
      'sonido de gallo atribuido a\nRibhav Agrawal @ pixabay.com';

  @override
  String get drawer_cuckoo_credit =>
      'sonido de cuco atribuido a\nMonkay @ freesound.org';

  @override
  String get edit_label_dialog_title => 'Renombrar slot';

  @override
  String get edit_label_dialog_hint => 'ej. Descanso matutino';

  @override
  String get edit_label_save_button => 'guardar';

  @override
  String get edit_duration_sheet_title => 'Duración del descanso';

  @override
  String get edit_duration_sheet_subtitle => 'Pasos de 5 minutos';

  @override
  String get edit_duration_min_suffix => ' min';

  @override
  String get edit_duration_save_button => 'guardar';

  @override
  String get edit_sound_sheet_title => 'Sonido de alerta';

  @override
  String get edit_sound_sheet_subtitle => 'toca para previsualizar';

  @override
  String get edit_sound_more_sounds => 'Más sonidos…';

  @override
  String get edit_sound_save_button => 'guardar';

  @override
  String get notification_channel_description => 'Recordatorio de descanso';

  @override
  String notification_channel_description_full(Object slotLabel) {
    return 'Recordatorio de descanso para \"$slotLabel\"';
  }

  @override
  String get test_notification_title => 'Alerta de prueba de temporizadores';

  @override
  String test_notification_body(
    Object led,
    Object soundName,
    Object vibration,
  ) {
    return 'Probando alerta — $soundName$vibration$led.';
  }

  @override
  String get test_notification_vibration => ', vibración activada';

  @override
  String get test_notification_led => ', LED activado';

  @override
  String break_time_notification_title(Object slotId) {
    return 'Pavlovian — slot $slotId';
  }

  @override
  String break_time_notification_body(Object duration, Object slotLabel) {
    return 'Hora de descanso — es $slotLabel. ¡Disfruta tus $duration minutos.';
  }

  @override
  String break_end_notification_title(Object slotId) {
    return 'Pavlovian — slot $slotId';
  }

  @override
  String break_end_notification_body(Object duration) {
    return 'Descanso terminado — tu descanso de $duration minutos ha finalizado. Es hora de volver.';
  }

  @override
  String get notification_action_button => '▶ Iniciar cuenta regresiva';

  @override
  String get diagnostics_screen_title => 'Diagnósticos';

  @override
  String get diagnostics_refresh_tooltip => 'Actualizar';

  @override
  String get diagnostics_copy_tooltip => 'Copiar';

  @override
  String get diagnostics_copy_snackbar =>
      'Diagnósticos copiados al portapapeles';

  @override
  String get diagnostics_reschedule_button => 'Re-ejecutar scheduleAll';

  @override
  String get diagnostics_clear_log_button => 'Limpiar registro';

  @override
  String get diagnostics_header => '═══ Diagnósticos de Pavlovian ═══';

  @override
  String get diagnostics_captured_prefix => 'Capturado: ';

  @override
  String get diagnostics_settings_section => '── Configuración persistente ──';

  @override
  String get diagnostics_settings_loading => '(configuración aún cargando)';

  @override
  String get diagnostics_permissions_section => '── Permisos ──';

  @override
  String get diagnostics_permissions_label => 'canScheduleExactAlarms: ';

  @override
  String get diagnostics_pending_section =>
      '── Lista de pendientes del complemento ──';

  @override
  String get diagnostics_pending_label =>
      'recuento de pendingNotificationRequests: ';

  @override
  String get diagnostics_pending_error => 'pendingNotificationRequests LANZÓ: ';

  @override
  String get diagnostics_fire_times_section =>
      '── Horas de disparo calculadas ──';

  @override
  String get diagnostics_fire_times_skipped => '(omitido — sin configuración)';

  @override
  String get diagnostics_fire_times_skipped_disabled =>
      '(omitido — globalEnabled está APAGADO)';

  @override
  String get diagnostics_slot_disabled => ' DESHABILITADO — omitir';

  @override
  String get diagnostics_log_section => '── Registro (último al final) ──';

  @override
  String get diagnostics_log_empty => '(registro vacío)';

  @override
  String get error_screen_prefix => 'No se pudo cargar la configuración:\n';

  @override
  String get day_sun_short => 'Dom';

  @override
  String get day_mon_short => 'Lun';

  @override
  String get day_tue_short => 'Mar';

  @override
  String get day_wed_short => 'Mié';

  @override
  String get day_thu_short => 'Jue';

  @override
  String get day_fri_short => 'Vie';

  @override
  String get day_sat_short => 'Sáb';

  @override
  String get day_sun_full => 'Domingo';

  @override
  String get day_mon_full => 'Lunes';

  @override
  String get day_tue_full => 'Martes';

  @override
  String get day_wed_full => 'Miércoles';

  @override
  String get day_thu_full => 'Jueves';

  @override
  String get day_fri_full => 'Viernes';

  @override
  String get day_sat_full => 'Sábado';

  @override
  String get section_break_slots_title => '① Espacios de descanso';

  @override
  String get section_working_days_title => '② Días de trabajo';

  @override
  String get section_notifications_title => '③ Notificaciones';

  @override
  String get section_language_title => '④ Idioma';

  @override
  String get section_reset_title => '⑤ Reiniciar';
}
