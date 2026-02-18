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
  
  Schedule({
    required this.title,
    required this.description,
    required this.time,
    this.isCompleted = false,
    required this.type,
    this.isRecurring = false,
    this.recurringDays = const [],
  });
}
