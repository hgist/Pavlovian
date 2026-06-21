// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get app_name => 'Pavlovian';

  @override
  String get app_tagline => 'напоминания о перерывах';

  @override
  String get app_byline => 'от HST';

  @override
  String get timers_screen_title => 'Таймеры';

  @override
  String get global_all_on => 'ВСЕ ВКЛЮЧЕНО';

  @override
  String get global_all_off => 'ВСЕ ОТКЛЮЧЕНО';

  @override
  String get subtitle_all_timers_off => 'все таймеры отключены';

  @override
  String get subtitle_active_count => 'активный';

  @override
  String get subtitle_paused_for => 'пауза для';

  @override
  String get legend_annotation => '↓ запускается в каждый включенный день';

  @override
  String get day_master_card_label => ' таймеры';

  @override
  String get day_master_card_pauses =>
      'приостанавливает все таймеры только на сегодня';

  @override
  String get day_master_card_paused => '✕ пауза на сегодня';

  @override
  String get slot_status_running => '⏱ ';

  @override
  String get slot_status_left => ' осталось';

  @override
  String get slot_status_enabled => 'в каждый включенный день';

  @override
  String get slot_status_disabled => 'отключено — вся неделя';

  @override
  String get button_start => '▶ начать';

  @override
  String get button_clear => '■ очистить';

  @override
  String get settings_screen_title => 'Настройки';

  @override
  String get section_break_slots => '① Перерывы';

  @override
  String get section_working_days => '② Рабочие дни';

  @override
  String get section_notifications => '③ Уведомления';

  @override
  String get section_reset => '⑤ Сброс';

  @override
  String get slot_header_edit => 'изменить метку ›';

  @override
  String get slot_field_break_time => 'Время перерыва';

  @override
  String get slot_field_duration => 'Продолжительность';

  @override
  String get slot_field_alert_sound => 'Звук оповещения';

  @override
  String get duration_suffix => ' мин';

  @override
  String delete_dialog_title(Object label) {
    return 'Удалить \"$label\"?';
  }

  @override
  String get delete_dialog_content =>
      'Этот перерыв и его сигналы будут удалены.';

  @override
  String get delete_button => 'удалить';

  @override
  String get cancel_button => 'отмена';

  @override
  String get working_days_description =>
      'Таймеры работают только в отмеченные дни.';

  @override
  String get working_days_help_text =>
      'коснитесь дня, чтобы переключить его включение/отключение';

  @override
  String get test_notification_label => 'Тестовое уведомление';

  @override
  String get test_notification_description =>
      'запускает пример оповещения со звуком слота 1';

  @override
  String get test_button => '▶ тест';

  @override
  String get alert_sound_label => 'Звук оповещения';

  @override
  String get end_of_break_sound_label => 'Звук окончания перерыва';

  @override
  String get notifications_enabled_label => 'Показывать уведомления';

  @override
  String get notifications_enabled_description =>
      'отправлять оповещения о перерывах в панель уведомлений';

  @override
  String get sound_enabled_label => 'Воспроизводить звук при оповещении';

  @override
  String get sound_enabled_description =>
      'воспроизводить звук при срабатывании уведомления о перерыве';

  @override
  String get both_alerts_off_warning =>
      'Оба типа оповещений отключены — для отключения всех перерывов используйте переключатель ВСЁ ВЫКЛ на главном экране.';

  @override
  String get vibrate_label => 'Вибрация при оповещении';

  @override
  String get flash_led_label => 'Мигать светодиодом при оповещении';

  @override
  String get reset_title => 'Сбросить все к значениям по умолчанию';

  @override
  String get reset_description =>
      'восстанавливает времена, продолжительность и звуки';

  @override
  String get reset_annotation => '↑ сначала показывает диалог подтверждения';

  @override
  String get reset_dialog_title => 'Сбросить все настройки?';

  @override
  String get reset_dialog_content =>
      'Все времена, продолжительность, метки и переключатели вернут значения по умолчанию. Ваш выбранный тестовый звук сохранится (звуки слота совпадают с ним).';

  @override
  String get reset_button => 'сброс';

  @override
  String get add_break_button => '+ Добавить перерыв';

  @override
  String get settings_reset_snackbar =>
      'Настройки сброшены к значениям по умолчанию.';

  @override
  String get slot_label_default_1 => 'Утренний перерыв';

  @override
  String get slot_label_default_2 => 'Обеденный перерыв';

  @override
  String get slot_label_default_3 => 'Полдник';

  @override
  String get splash_loading_text => 'загрузка…';

  @override
  String get splash_working_days_badge => 'каждый день · настраиваемое';

  @override
  String get drawer_settings_item => 'Настройки';

  @override
  String get drawer_rooster_credit =>
      'звук петуха из\nRibhav Agrawal @ pixabay.com';

  @override
  String get drawer_cuckoo_credit => 'звук кукушки из\nMonkay @ freesound.org';

  @override
  String get edit_label_dialog_title => 'Переименовать слот';

  @override
  String get edit_label_dialog_hint => 'например, Утренний перерыв';

  @override
  String get edit_label_save_button => 'сохранить';

  @override
  String get edit_duration_sheet_title => 'Продолжительность перерыва';

  @override
  String get edit_duration_sheet_subtitle => 'Шаги по 5 минут';

  @override
  String get edit_duration_min_suffix => ' мин';

  @override
  String get edit_duration_save_button => 'сохранить';

  @override
  String get edit_sound_sheet_title => 'Звук оповещения';

  @override
  String get edit_sound_sheet_subtitle => 'коснитесь для предпросмотра';

  @override
  String get edit_sound_more_sounds => 'Еще звуки…';

  @override
  String get edit_sound_save_button => 'сохранить';

  @override
  String get notification_channel_description => 'Напоминание о перерыве';

  @override
  String notification_channel_description_full(Object slotLabel) {
    return 'Напоминание о перерыве для \"$slotLabel\"';
  }

  @override
  String get test_notification_title => 'Таймеры Тестовое оповещение';

  @override
  String test_notification_body(
    Object led,
    Object soundName,
    Object vibration,
  ) {
    return 'Тестовое оповещение — $soundName$vibration$led.';
  }

  @override
  String get test_notification_vibration => ', вибрация включена';

  @override
  String get test_notification_led => ', светодиод включен';

  @override
  String break_time_notification_title(Object slotId) {
    return 'Pavlovian — слот $slotId';
  }

  @override
  String break_time_notification_body(Object duration, Object slotLabel) {
    return 'Время перерыва — это $slotLabel. Наслаждайтесь своими $duration минутами.';
  }

  @override
  String break_end_notification_title(Object slotId) {
    return 'Pavlovian — слот $slotId';
  }

  @override
  String break_end_notification_body(Object duration) {
    return 'Перерыв окончен — ваш $duration-минутный перерыв завершился. Пора возвращаться.';
  }

  @override
  String get notification_action_button => '▶ Начать обратный отсчет';

  @override
  String get diagnostics_screen_title => 'Диагностика';

  @override
  String get diagnostics_refresh_tooltip => 'Обновить';

  @override
  String get diagnostics_copy_tooltip => 'Копировать';

  @override
  String get diagnostics_copy_snackbar =>
      'Диагностика скопирована в буфер обмена';

  @override
  String get diagnostics_reschedule_button => 'Переустановить расписание';

  @override
  String get diagnostics_clear_log_button => 'Очистить журнал';

  @override
  String get diagnostics_header => '═══ Диагностика Pavlovian ═══';

  @override
  String get diagnostics_captured_prefix => 'Захвачено: ';

  @override
  String get diagnostics_settings_section => '── Сохраненные настройки ──';

  @override
  String get diagnostics_settings_loading => '(настройки еще загружаются)';

  @override
  String get diagnostics_permissions_section => '── Разрешения ──';

  @override
  String get diagnostics_permissions_label => 'canScheduleExactAlarms: ';

  @override
  String get diagnostics_pending_section => '── Список ожидания плагина ──';

  @override
  String get diagnostics_pending_label =>
      'количество pendingNotificationRequests: ';

  @override
  String get diagnostics_pending_error =>
      'pendingNotificationRequests ВЫБРОСИЛ: ';

  @override
  String get diagnostics_fire_times_section =>
      '── Вычисленные времена срабатывания ──';

  @override
  String get diagnostics_fire_times_skipped => '(пропущено — нет настроек)';

  @override
  String get diagnostics_fire_times_skipped_disabled =>
      '(пропущено — globalEnabled выключено)';

  @override
  String get diagnostics_slot_disabled => ' ОТКЛЮЧЕНО — пропустить';

  @override
  String get diagnostics_log_section => '── Журнал (последний внизу) ──';

  @override
  String get diagnostics_log_empty => '(журнал пуст)';

  @override
  String get error_screen_prefix => 'Не удалось загрузить настройки:\n';

  @override
  String get day_sun_short => 'Вс';

  @override
  String get day_mon_short => 'Пн';

  @override
  String get day_tue_short => 'Вт';

  @override
  String get day_wed_short => 'Ср';

  @override
  String get day_thu_short => 'Чт';

  @override
  String get day_fri_short => 'Пт';

  @override
  String get day_sat_short => 'Сб';

  @override
  String get day_sun_full => 'Воскресенье';

  @override
  String get day_mon_full => 'Понедельник';

  @override
  String get day_tue_full => 'Вторник';

  @override
  String get day_wed_full => 'Среда';

  @override
  String get day_thu_full => 'Четверг';

  @override
  String get day_fri_full => 'Пятница';

  @override
  String get day_sat_full => 'Суббота';

  @override
  String get section_break_slots_title => '① Перерывы';

  @override
  String get section_working_days_title => '② Рабочие дни';

  @override
  String get section_notifications_title => '③ Уведомления';

  @override
  String get section_language_title => '④ Язык';

  @override
  String get section_reset_title => '⑤ Сброс';
}
