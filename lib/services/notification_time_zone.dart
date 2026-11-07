import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationTimeZone {
  static Future<void>? _initialization;

  static String canonicalizeTimeZoneName(String timeZoneName) {
    return switch (timeZoneName) {
      'Asia/Calcutta' => 'Asia/Kolkata',
      _ => timeZoneName,
    };
  }

  static Future<void> initialize() async {
    try {
      await (_initialization ??= _initialize());
    } catch (_) {
      _initialization = null;
      rethrow;
    }
  }

  static Future<void> _initialize() async {
    timezone_data.initializeTimeZones();
    final deviceTimeZoneName = await FlutterTimezone.getLocalTimezone();
    final timeZoneName = canonicalizeTimeZoneName(deviceTimeZoneName);
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }
}
