import 'package:flutter_test/flutter_test.dart';
import 'package:noor/services/notification_time_zone.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as tz;

void main() {
  test('normalizes the legacy Calcutta timezone name', () {
    timezone_data.initializeTimeZones();

    final timeZoneName =
        NotificationTimeZone.canonicalizeTimeZoneName('Asia/Calcutta');

    expect(timeZoneName, 'Asia/Kolkata');
    expect(tz.getLocation(timeZoneName).name, 'Asia/Kolkata');
  });

  test('preserves other timezone names', () {
    expect(
      NotificationTimeZone.canonicalizeTimeZoneName('Europe/London'),
      'Europe/London',
    );
  });
}
