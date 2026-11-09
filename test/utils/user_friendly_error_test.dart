import 'package:flutter_test/flutter_test.dart';
import 'package:noor/utils/user_friendly_error.dart';

void main() {
  group('UserFriendlyError', () {
    test('turns location permission failures into an actionable message', () {
      expect(
        UserFriendlyError.prayerTimes(
          Exception('Location permission was denied.'),
        ),
        contains('Allow location access'),
      );
    });

    test('does not expose raw technical details for unknown failures', () {
      const developerError = 'SocketException: internal-host-123 failed';
      expect(
        UserFriendlyError.prayerTimes(Exception(developerError)),
        isNot(contains('internal-host-123')),
      );
    });

    test('maps invalid credentials to a clear sign-in message', () {
      expect(
        UserFriendlyError.account(
          Exception('Invalid email or password'),
          action: 'sign you in',
        ),
        contains('Email or password is incorrect'),
      );
    });

    test('does not expose technical account errors to users', () {
      expect(
        UserFriendlyError.account(
          Exception('HttpException: internal-host-123 failed'),
          action: 'load your profile',
        ),
        isNot(contains('internal-host-123')),
      );
    });

    test('explains when a schedule saved but its reminder failed', () {
      expect(
        UserFriendlyError.schedule(
          StateError('notification failure'),
          alreadySaved: true,
        ),
        contains('Your schedule was saved'),
      );
    });
  });
}
