import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:timezone/timezone.dart' as tz;

class DailyReminderService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _notifications.initialize(settings);
  }

  static Future<void> scheduleDailyReminder() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('daily_reminder_enabled') ?? false;
    
    if (!enabled) return;

    final hour = prefs.getInt('daily_reminder_hour') ?? 9;
    final minute = prefs.getInt('daily_reminder_minute') ?? 0;

    await _notifications.zonedSchedule(
      999,
      'Daily Islamic Reminder',
      'Tap to read today\'s hadith or dua',
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Daily Reminder',
          channelDescription: 'Daily hadith and dua reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  static Future<void> showRandomReminder() async {
    final random = Random();
    final type = random.nextBool() ? 'hadith' : 'dua';

    if (type == 'hadith') {
      await _showRandomHadith();
    } else {
      await _showRandomDua();
    }
  }

  static Future<void> _showRandomHadith() async {
    try {
      final response = await http.get(Uri.parse('https://hadis-api-id.vercel.app/hadith/bukhari?page=1&limit=1'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List;
        if (items.isNotEmpty) {
          final hadith = items[0];
          await _notifications.show(
            Random().nextInt(1000),
            'Hadith of the Day',
            hadith['id']?.toString() ?? 'Read today\'s hadith',
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'daily_reminder',
                'Daily Reminder',
                channelDescription: 'Daily hadith and dua reminders',
                importance: Importance.high,
                priority: Priority.high,
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Fallback notification
      await _notifications.show(
        Random().nextInt(1000),
        'Islamic Reminder',
        'Remember Allah and read Quran today',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminder',
            'Daily Reminder',
            importance: Importance.high,
          ),
        ),
      );
    }
  }

  static Future<void> _showRandomDua() async {
    final duas = [
      'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً',
      'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ',
      'رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي',
      'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ',
      'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ سُبْحَانَ اللَّهِ الْعَظِيمِ',
    ];

    final randomDua = duas[Random().nextInt(duas.length)];
    
    await _notifications.show(
      Random().nextInt(1000),
      'Dua of the Day',
      randomDua,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Daily Reminder',
          channelDescription: 'Daily hadith and dua reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  static Future<void> enableReminder(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('daily_reminder_enabled', true);
    await prefs.setInt('daily_reminder_hour', hour);
    await prefs.setInt('daily_reminder_minute', minute);
    await scheduleDailyReminder();
  }

  static Future<void> disableReminder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('daily_reminder_enabled', false);
    await _notifications.cancel(999);
  }
}
