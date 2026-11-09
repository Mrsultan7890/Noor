import 'package:flutter_test/flutter_test.dart';
import 'package:noor/models/user_model.dart';

void main() {
  Map<String, dynamic> profileWithLastActivity(String lastActivityDate) => {
        'id': 'user-1',
        'email': 'user@example.com',
        'username': 'NoorUser',
        'country': 'Pakistan',
        'level': 'Beginner',
        'points': 25,
        'streak_days': 4,
        'last_activity_date': lastActivityDate,
        'quran_progress': 0.0,
        'prayers_logged': 0,
        'lessons_completed': 0,
        'created_at': '2025-01-01T00:00:00Z',
        'updated_at': '2025-01-01T00:00:00Z',
      };

  test('keeps the active streak when activity was today or yesterday', () {
    final now = DateTime.now().toUtc();
    final today = DateTime.utc(now.year, now.month, now.day);

    for (final lastActivity in [
      today,
      today.subtract(const Duration(days: 1)),
    ]) {
      final user = User.fromJson(
        profileWithLastActivity(lastActivity.toIso8601String()),
      );
      expect(user.streakDays, 4);
    }
  });

  test('expires an inactive streak without changing earned points', () {
    final now = DateTime.now().toUtc();
    final today = DateTime.utc(now.year, now.month, now.day);
    final user = User.fromJson(
      profileWithLastActivity(
        today.subtract(const Duration(days: 2)).toIso8601String(),
      ),
    );

    expect(user.streakDays, 0);
    expect(user.points, 25);
  });
}
