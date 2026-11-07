import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/prayer_times_model.dart';
import 'utf8_json.dart';

class PrayerTimesService {
  static const String _baseUrl = 'https://api.aladhan.com/v1';

  Future<PrayerTimes> getPrayerTimes({
    required double latitude,
    required double longitude,
  }) async {
    final response = await http
        .get(
          Uri.parse(
            '$_baseUrl/timings?latitude=$latitude&longitude=$longitude&method=2',
          ),
        )
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception(
        'Prayer-times service returned HTTP ${response.statusCode}.',
      );
    }
    return PrayerTimes.fromJson(decodeUtf8JsonResponse(response));
  }

  Future<Position> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.unableToDetermine) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw Exception('Location permission was denied.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission is permanently denied. Enable it in app settings.',
      );
    }

    return Geolocator.getCurrentPosition().timeout(
      const Duration(seconds: 15),
    );
  }

  String getNextPrayer(PrayerTimes times, {DateTime? reference}) {
    final now = reference ?? DateTime.now();
    for (final prayer in _prayers(times)) {
      if (parseTimeToday(prayer.$2, reference: now).isAfter(now)) {
        return prayer.$1;
      }
    }
    return 'Fajr';
  }

  Duration getTimeUntilNext(PrayerTimes times, {DateTime? reference}) {
    final now = reference ?? DateTime.now();
    for (final prayer in _prayers(times)) {
      final prayerTime = parseTimeToday(prayer.$2, reference: now);
      if (prayerTime.isAfter(now)) {
        return prayerTime.difference(now);
      }
    }
    final tomorrowFajr = parseTimeToday(times.fajr, reference: now)
        .add(const Duration(days: 1));
    return tomorrowFajr.difference(now);
  }

  static DateTime parseTimeToday(String time, {DateTime? reference}) {
    final match = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(time.trim());
    if (match == null) {
      throw FormatException('Invalid prayer time: $time');
    }

    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    if (hour > 23 || minute > 59) {
      throw FormatException('Invalid prayer time: $time');
    }

    final now = reference ?? DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
  }

  Duration timeUntilNextOccurrence(String time, {DateTime? reference}) {
    final current = reference ?? DateTime.now();
    var next = parseTimeToday(time, reference: current);
    if (!next.isAfter(current)) {
      next = next.add(const Duration(days: 1));
    }
    return next.difference(current);
  }

  String formatPrayerTime(String time) {
    final match = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(time.trim());
    if (match == null) {
      throw FormatException('Invalid prayer time: $time');
    }
    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    if (hour > 23 || minute > 59) {
      throw FormatException('Invalid prayer time: $time');
    }
    return '${hour.toString().padLeft(2, '0')}:${match.group(2)}';
  }

  List<(String, String)> _prayers(PrayerTimes times) => [
        ('Fajr', times.fajr),
        ('Dhuhr', times.dhuhr),
        ('Asr', times.asr),
        ('Maghrib', times.maghrib),
        ('Isha', times.isha),
      ];

  Duration timeUntilNextPrayer(PrayerTimes times, String prayer) {
    final prayerTime = switch (prayer) {
      'Fajr' => times.fajr,
      'Dhuhr' => times.dhuhr,
      'Asr' => times.asr,
      'Maghrib' => times.maghrib,
      'Isha' => times.isha,
      _ => throw ArgumentError.value(prayer, 'prayer', 'Unknown prayer'),
    };
    return timeUntilNextOccurrence(prayerTime);
  }
}
