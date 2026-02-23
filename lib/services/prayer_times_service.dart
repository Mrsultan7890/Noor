import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import '../models/prayer_times_model.dart';

class PrayerTimesService {
  static const String _baseUrl = 'https://api.aladhan.com/v1';

  Future<PrayerTimes?> getPrayerTimes({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/timings?latitude=$latitude&longitude=$longitude&method=2'),
      );

      if (response.statusCode == 200) {
        return PrayerTimes.fromJson(json.decode(response.body));
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching prayer times: $e');
    }
    return null;
  }

  Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition();
    } catch (e) {
      if (kDebugMode) print('Error getting location: $e');
      return null;
    }
  }

  String getNextPrayer(PrayerTimes times) {
    final now = DateTime.now();
    final prayers = {
      'Fajr': _parseTime(times.fajr),
      'Dhuhr': _parseTime(times.dhuhr),
      'Asr': _parseTime(times.asr),
      'Maghrib': _parseTime(times.maghrib),
      'Isha': _parseTime(times.isha),
    };

    for (var entry in prayers.entries) {
      if (entry.value.isAfter(now)) {
        return entry.key;
      }
    }
    return 'Fajr';
  }

  Duration getTimeUntilNext(PrayerTimes times) {
    final now = DateTime.now();
    final nextPrayer = getNextPrayer(times);
    
    DateTime nextTime;
    switch (nextPrayer) {
      case 'Fajr':
        nextTime = _parseTime(times.fajr);
        if (nextTime.isBefore(now)) {
          nextTime = nextTime.add(const Duration(days: 1));
        }
        break;
      case 'Dhuhr':
        nextTime = _parseTime(times.dhuhr);
        break;
      case 'Asr':
        nextTime = _parseTime(times.asr);
        break;
      case 'Maghrib':
        nextTime = _parseTime(times.maghrib);
        break;
      case 'Isha':
        nextTime = _parseTime(times.isha);
        break;
      default:
        nextTime = now;
    }

    return nextTime.difference(now);
  }

  DateTime _parseTime(String time) {
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
