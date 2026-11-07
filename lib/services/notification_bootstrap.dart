import 'daily_reminder_service.dart';
import 'notification_service.dart';
import 'prayer_notification_service.dart';

class NotificationBootstrap {
  static Future<void>? _initialization;

  static Future<void> initialize() {
    return _initialization ??= _initialize();
  }

  static Future<void> _initialize() async {
    try {
      await NotificationService().init();
      await DailyReminderService.init();
      await PrayerNotificationService.initialize();
    } catch (_) {
      _initialization = null;
      rethrow;
    }
  }
}
