import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor/models/prayer_times_model.dart';
import 'package:noor/services/prayer_times_service.dart';

void main() {
  group('PrayerTimesService', () {
    final service = PrayerTimesService();
    final times = PrayerTimes(
      fajr: '05:00 (PKT)',
      sunrise: '06:20',
      dhuhr: '12:00',
      asr: '15:30',
      maghrib: '18:30',
      isha: '20:00',
      date: '01 Jan 2026',
      hijriMonth: 7,
      hijriDay: 12,
    );

    test('parses API times with timezone suffixes', () {
      expect(
        PrayerTimesService.parseTimeToday(
          '05:30 (PKT)',
          reference: DateTime(2026, 1, 1, 1),
        ),
        DateTime(2026, 1, 1, 5, 30),
      );
      expect(service.formatPrayerTime('5:30 (PKT)'), '05:30');
    });

    test('rejects malformed or out-of-range times', () {
      expect(
        () => PrayerTimesService.parseTimeToday('not-a-time'),
        throwsFormatException,
      );
      expect(
        () => PrayerTimesService.parseTimeToday('25:70'),
        throwsFormatException,
      );
    });

    test('rejects an empty prayer-times date range', () async {
      await expectLater(
        service.getPrayerTimesForRange(
          latitude: 0,
          longitude: 0,
          startDate: DateTime(2026, 1, 1),
          days: 0,
        ),
        throwsArgumentError,
      );
    });

    test('uses Hanafi Asr calculation by default and persists the selection',
        () async {
      SharedPreferences.setMockInitialValues({});

      expect(await service.getAsrSchool(), AsrSchool.hanafi);
      expect(AsrSchool.hanafi.apiValue, 1);

      await service.setAsrSchool(AsrSchool.shafi);
      expect(await service.getAsrSchool(), AsrSchool.shafi);
      expect(AsrSchool.shafi.apiValue, 0);
    });

    test('finds the next prayer and its countdown', () {
      final now = DateTime(2026, 1, 1, 10);
      expect(service.getNextPrayer(times, reference: now), 'Dhuhr');
      expect(
        service.getTimeUntilNext(times, reference: now),
        const Duration(hours: 2),
      );
    });

    test('rolls the next prayer over to tomorrow Fajr', () {
      final now = DateTime(2026, 1, 1, 21);
      expect(service.getNextPrayer(times, reference: now), 'Fajr');
      expect(
        service.getTimeUntilNext(times, reference: now),
        const Duration(hours: 8),
      );
    });
  });
}
