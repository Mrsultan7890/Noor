import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'notification_time_zone.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static Future<void>? _initialization;
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();

  Future<void> init() => _initialization ??= _initialize();

  Future<void> _initialize() async {
    try {
      await NotificationTimeZone.initialize();
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings();
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      await _notifications.initialize(initSettings);
    } catch (_) {
      _initialization = null;
      rethrow;
    }
  }

  Future<bool> requestPermissions() async {
    await init();
    var notificationsAllowed = true;
    var exactAlarmsAllowed = true;

    final android = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      final notificationsEnabled = await android.areNotificationsEnabled();
      if (notificationsEnabled == false) {
        notificationsAllowed =
            await android.requestNotificationsPermission() ?? false;
      }
      if (notificationsAllowed) {
        final canScheduleExact = await android.canScheduleExactNotifications();
        if (canScheduleExact == false) {
          exactAlarmsAllowed =
              await android.requestExactAlarmsPermission() ?? false;
        }
      }
    }

    final ios = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      notificationsAllowed =
          await ios.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          true;
    }

    return notificationsAllowed && exactAlarmsAllowed;
  }

  Future<bool> canScheduleWithoutPrompting() async {
    await init();
    final android = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return true;

    final notificationsEnabled = await android.areNotificationsEnabled();
    final canScheduleExact = await android.canScheduleExactNotifications();
    return notificationsEnabled == true && canScheduleExact == true;
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    await init();
    await NotificationTimeZone.initialize();
    if (!await requestPermissions()) {
      throw StateError('Notification or exact-alarm permission was denied.');
    }

    const androidDetails = AndroidNotificationDetails(
      'noor_channel',
      'Noor Notifications',
      channelDescription: 'Islamic reminders and schedules',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const iosDetails = DarwinNotificationDetails();
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
  
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
  
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<void> scheduleScheduleAlarm({
    required int scheduleKey,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required bool recurring,
    required List<int> recurringDays,
  }) async {
    await init();
    await NotificationTimeZone.initialize();
    if (!await requestPermissions()) {
      throw StateError('Notification or exact-alarm permission was denied.');
    }
    await cancelScheduleAlarms(scheduleKey);

    if (recurring) {
      if (recurringDays.isEmpty ||
          recurringDays.any((day) => day < DateTime.monday || day > DateTime.sunday)) {
        throw ArgumentError.value(
          recurringDays,
          'recurringDays',
          'Recurring alarms require weekdays between 1 and 7.',
        );
      }

      for (final weekday in recurringDays.toSet()) {
        final nextOccurrence = _nextWeekdayOccurrence(
          scheduledTime,
          weekday,
        );
        await _schedule(
          _scheduleAlarmId(scheduleKey, weekday),
          title,
          body,
          nextOccurrence,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
      return;
    }

    final now = DateTime.now();
    var nextOccurrence = scheduledTime;
    if (!nextOccurrence.isAfter(now)) {
      nextOccurrence = DateTime(
        now.year,
        now.month,
        now.day + 1,
        scheduledTime.hour,
        scheduledTime.minute,
      );
    }
    await _schedule(
      _scheduleAlarmId(scheduleKey, 0),
      title,
      body,
      nextOccurrence,
    );
  }

  Future<void> cancelScheduleAlarms(int scheduleKey) async {
    for (var slot = 0; slot <= DateTime.daysPerWeek; slot++) {
      await cancelNotification(_scheduleAlarmId(scheduleKey, slot));
    }
  }

  Future<void> _schedule(
    int id,
    String title,
    String body,
    DateTime scheduledTime, {
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'noor_channel',
        'Noor Notifications',
        channelDescription: 'Islamic reminders and schedules',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: matchDateTimeComponents,
    );
  }

  DateTime _nextWeekdayOccurrence(DateTime scheduledTime, int weekday) {
    final now = DateTime.now();
    final daysAhead = (weekday - now.weekday) % DateTime.daysPerWeek;
    var occurrence = DateTime(
      now.year,
      now.month,
      now.day + daysAhead,
      scheduledTime.hour,
      scheduledTime.minute,
    );
    if (!occurrence.isAfter(now)) {
      occurrence = occurrence.add(const Duration(days: DateTime.daysPerWeek));
    }
    return occurrence;
  }

  int _scheduleAlarmId(int scheduleKey, int slot) =>
      200000 + scheduleKey * 8 + slot;
}
