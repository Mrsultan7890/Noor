import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as tz;
import '../models/prayer_times_model.dart';
import 'prayer_times_service.dart';

class PrayerNotificationService {
  static const int _firstPrayerNotificationId = 10000;
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    timezone_data.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    
    await _notifications.initialize(settings);
  }

  static Future<void> schedulePrayerNotifications(PrayerTimes times) async {
    await cancelPrayerNotifications();

    final prayers = <({String name, String time})>[
      (name: 'Fajr', time: times.fajr),
      (name: 'Dhuhr', time: times.dhuhr),
      (name: 'Asr', time: times.asr),
      (name: 'Maghrib', time: times.maghrib),
      (name: 'Isha', time: times.isha),
    ];

    for (int i = 0; i < prayers.length; i++) {
      final prayer = prayers[i];
      final scheduledTime = PrayerTimesService.parseTimeToday(
        prayer.time,
      );
      
      if (scheduledTime.isAfter(DateTime.now())) {
        await _notifications.zonedSchedule(
          _firstPrayerNotificationId + i,
          '${prayer.name} Time',
          'It\'s time for ${prayer.name} prayer',
          tz.TZDateTime.from(scheduledTime, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'prayer_times',
              'Prayer Times',
              channelDescription: 'Notifications for daily prayer times',
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          payload: 'prayer:${prayer.name.toLowerCase()}',
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
  }

  static Future<void> cancelPrayerNotifications() async {
    for (var index = 0; index < 5; index++) {
      await _notifications.cancel(_firstPrayerNotificationId + index);
    }
  }
}
