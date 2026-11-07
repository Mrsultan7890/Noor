import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/prayer_times_model.dart';
import 'notification_service.dart';
import 'notification_time_zone.dart';
import 'prayer_times_service.dart';

class PrayerNotificationService {
  static const _latitudeKey = 'prayer_notification_latitude';
  static const _longitudeKey = 'prayer_notification_longitude';
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    await NotificationTimeZone.initialize();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    
    await _notifications.initialize(settings);
  }

  static Future<void> schedulePrayerNotifications(
    PrayerTimes times, {
    required double latitude,
    required double longitude,
  }) async {
    if (!await NotificationService().requestPermissions()) {
      throw StateError('Notification or exact-alarm permission was denied.');
    }

    final today = DateTime.now();
    final prayerTimesByDate = await PrayerTimesService().getPrayerTimesForRange(
      latitude: latitude,
      longitude: longitude,
      startDate: today,
      days: 10,
    );
    prayerTimesByDate[DateTime(today.year, today.month, today.day)] = times;

    await cancelPrayerNotifications();

    const prayerNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    for (final entry in prayerTimesByDate.entries) {
      final prayers = [
        entry.value.fajr,
        entry.value.dhuhr,
        entry.value.asr,
        entry.value.maghrib,
        entry.value.isha,
      ];
      for (var index = 0; index < prayers.length; index++) {
        final day = entry.key;
        final scheduledTime = PrayerTimesService.parseTimeToday(
          prayers[index],
          reference: day,
        );
        if (!scheduledTime.isAfter(DateTime.now())) continue;

        final prayerName = prayerNames[index];
        await _notifications.zonedSchedule(
          _notificationId(day, index),
          '$prayerName Time',
          'It\'s time for $prayerName prayer',
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
          payload:
              'prayer:${prayerName.toLowerCase()}:${day.year}-${day.month}-${day.day}',
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
  }

  static Future<void> saveLocation({
    required double latitude,
    required double longitude,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setDouble(_latitudeKey, latitude);
    await preferences.setDouble(_longitudeKey, longitude);
  }

  static Future<void> refreshFromSavedLocation() async {
    final preferences = await SharedPreferences.getInstance();
    if (!(preferences.getBool('prayer_notifications_enabled') ?? true)) {
      return;
    }

    final latitude = preferences.getDouble(_latitudeKey);
    final longitude = preferences.getDouble(_longitudeKey);
    if (latitude == null || longitude == null) return;

    final times = await PrayerTimesService().getPrayerTimes(
      latitude: latitude,
      longitude: longitude,
    );
    await schedulePrayerNotifications(
      times,
      latitude: latitude,
      longitude: longitude,
    );
  }

  static Future<void> cancelPrayerNotifications() async {
    final pending = await _notifications.pendingNotificationRequests();
    for (final notification in pending) {
      if (notification.payload?.startsWith('prayer:') ?? false) {
        await _notifications.cancel(notification.id);
      }
    }
  }

  static int _notificationId(DateTime day, int prayerIndex) =>
      10000 +
      day.year * 100000 +
      day.month * 1000 +
      day.day * 10 +
      prayerIndex;
}
