import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/prayer_times_model.dart';
import 'utf8_json.dart';

class PrayerTimesService {
  Future<PrayerTimes> getPrayerTimes({
    required double latitude,
    required double longitude,
  }) async {
    final response = await http
        .get(
          Uri.https(
            'api.aladhan.com',
            '/v1/timings',
            {
              'latitude': '$latitude',
              'longitude': '$longitude',
              'method': '2',
              'school': '1',
            },
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

  Future<Map<DateTime, PrayerTimes>> getPrayerTimesForRange({
    required double latitude,
    required double longitude,
    required DateTime startDate,
    required int days,
  }) async {
    if (days < 1) {
      throw ArgumentError.value(days, 'days', 'Must be greater than zero.');
    }

    final requestedDates = List.generate(
      days,
      (index) => DateTime(
        startDate.year,
        startDate.month,
        startDate.day + index,
      ),
    );
    final months = requestedDates
        .map((date) => DateTime(date.year, date.month))
        .toSet()
        .toList();

    final monthResponses = await Future.wait(
      months.map((month) async {
        final response = await http
            .get(
              Uri.https(
                'api.aladhan.com',
                '/v1/calendar/${month.year}/${month.month}',
                {
                  'latitude': '$latitude',
                  'longitude': '$longitude',
                  'method': '2',
                  'school': '1',
                },
              ),
            )
            .timeout(const Duration(seconds: 15));
        if (response.statusCode != 200) {
          throw Exception(
            'Prayer-times calendar returned HTTP ${response.statusCode}.',
          );
        }
        final decoded = decodeUtf8JsonResponse(response);
        final entries = decoded['data'] as List<dynamic>;
        return entries.map((entry) => Map<String, dynamic>.from(entry as Map));
      }),
    );

    final requestedKeys = requestedDates.map(_dateKey).toSet();
    final results = <DateTime, PrayerTimes>{};
    for (final entry in monthResponses.expand((entries) => entries)) {
      final dateData =
          (entry['date'] as Map<String, dynamic>)['gregorian']
              as Map<String, dynamic>;
      final dateParts = (dateData['date'] as String)
          .split('-')
          .map(int.parse)
          .toList();
      final date = DateTime(dateParts[2], dateParts[1], dateParts[0]);
      if (requestedKeys.contains(_dateKey(date))) {
        results[date] = PrayerTimes.fromJson({'data': entry});
      }
    }

    if (results.length != requestedDates.length) {
      throw const FormatException(
        'Prayer-times calendar did not include all requested dates.',
      );
    }
    return results;
  }

  String _dateKey(DateTime date) => '${date.year}-${date.month}-${date.day}';

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
