import 'package:flutter_test/flutter_test.dart';
import 'package:noor/models/schedule_model.dart';

void main() {
  group('Schedule completion', () {
    final today = DateTime.now();
    final tomorrow = DateTime(today.year, today.month, today.day + 1);

    Schedule recurringSchedule() => Schedule(
          title: 'Read Quran',
          description: '',
          time: today,
          type: 'quran',
          isRecurring: true,
          recurringDays: [today.weekday],
        );

    test('resets a recurring completion when the date changes', () {
      final schedule = recurringSchedule()..setCompleted(true, date: today);

      expect(schedule.isCompleted, isTrue);
      expect(schedule.completionCount, 1);

      schedule.resetRecurringCompletion(tomorrow);

      expect(schedule.isCompleted, isFalse);
      expect(schedule.completionDate, isNull);
      expect(schedule.completionCount, 1);
    });

    test('counts at most one completion per date', () {
      final schedule = recurringSchedule();

      schedule.setCompleted(true, date: today);
      schedule.setCompleted(false, date: today);
      schedule.setCompleted(true, date: today);

      expect(schedule.completionCount, 1);

      schedule.resetRecurringCompletion(tomorrow);
      schedule.setCompleted(true, date: tomorrow);

      expect(schedule.completionCount, 2);
    });

    test('clears legacy recurring completions without a date', () {
      final schedule = recurringSchedule()
        ..isCompleted = true
        ..completionCount = 3;

      schedule.resetRecurringCompletion(today);

      expect(schedule.isCompleted, isFalse);
      expect(schedule.completionCount, 3);
    });

    test('does not reset a one-time schedule completion', () {
      final schedule = Schedule(
        title: 'Read Quran',
        description: '',
        time: today,
        type: 'quran',
        isCompleted: true,
      );

      schedule.resetRecurringCompletion(tomorrow);

      expect(schedule.isCompleted, isTrue);
    });
  });
}
