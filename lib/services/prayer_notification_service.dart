import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/prayer_times_model.dart';

class PrayerNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    
    await _notifications.initialize(settings);
  }

  static Future<void> schedulePrayerNotifications(PrayerTimes times) async {
    await cancelAll();

    final prayers = [
      {'name': 'Fajr', 'time': times.fajr},
      {'name': 'Dhuhr', 'time': times.dhuhr},
      {'name': 'Asr', 'time': times.asr},
      {'name': 'Maghrib', 'time': times.maghrib},
      {'name': 'Isha', 'time': times.isha},
    ];

    for (int i = 0; i < prayers.length; i++) {
      final prayer = prayers[i];
      final scheduledTime = _parseTime(prayer['time'] as String);
      
      if (scheduledTime.isAfter(DateTime.now())) {
        await _notifications.zonedSchedule(
          i,
          '${prayer['name']} Time',
          'It\'s time for ${prayer['name']} prayer',
          tz.TZDateTime.from(scheduledTime, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'prayer_times',
              'Prayer Times',
              channelDescription: 'Notifications for daily prayer times',
              importance: Importance.high,
              priority: Priority.high,
              sound: RawResourceAndroidNotificationSound('adhan'),
            ),
            iOS: DarwinNotificationDetails(
              sound: 'adhan.mp3',
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
  }

  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  static DateTime _parseTime(String time) {
    final parts = time.split(':');
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }
}
