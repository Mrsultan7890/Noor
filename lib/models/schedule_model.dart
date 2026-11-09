import 'package:hive/hive.dart';

part 'schedule_model.g.dart';

@HiveType(typeId: 0)
class Schedule extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  DateTime time;

  @HiveField(3)
  bool isCompleted;

  @HiveField(4)
  String type; // 'quran', 'tasbih', 'dua', 'hadith', 'custom'

  @HiveField(5)
  bool isRecurring;

  @HiveField(6)
  List<int> recurringDays; // 1-7 for Mon-Sun

  @HiveField(7)
  bool hasAlarm;

  @HiveField(8)
  int completionCount;

  @HiveField(9)
  String? completionDate;

  @HiveField(10)
  String? lastCompletionDate;

  Schedule({
    required this.title,
    required this.description,
    required this.time,
    this.isCompleted = false,
    required this.type,
    this.isRecurring = false,
    this.recurringDays = const [],
    this.hasAlarm = true,
    this.completionCount = 0,
    this.completionDate,
    this.lastCompletionDate,
  });

  bool get isRecurringToday =>
      !isRecurring || recurringDays.contains(DateTime.now().weekday);

  bool get wasCompletedToday =>
      isCompleted && completionDate == _dateKey(DateTime.now());

  void resetRecurringCompletion(DateTime date) {
    if (isRecurring && completionDate != _dateKey(date)) {
      isCompleted = false;
      completionDate = null;
    }
  }

  void setCompleted(bool completed, {DateTime? date}) {
    final today = _dateKey(date ?? DateTime.now());
    if (!completed) {
      isCompleted = false;
      completionDate = null;
      return;
    }

    if (!isCompleted) {
      isCompleted = true;
      completionDate = today;
      if (lastCompletionDate != today) {
        completionCount++;
        lastCompletionDate = today;
      }
    }
  }

  static String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
