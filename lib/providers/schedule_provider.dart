import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/schedule_model.dart';

class ScheduleProvider extends ChangeNotifier {
  List<Schedule> _schedules = [];
  
  List<Schedule> get schedules => _schedules;
  
  ScheduleProvider() {
    _loadSchedules();
  }
  
  Future<void> _loadSchedules() async {
    final box = await Hive.openBox<Schedule>('schedules');
    _schedules = box.values.toList();
    notifyListeners();
  }
  
  Future<void> addSchedule(Schedule schedule) async {
    final box = await Hive.openBox<Schedule>('schedules');
    await box.add(schedule);
    _schedules.add(schedule);
    notifyListeners();
  }
  
  Future<void> deleteSchedule(int index) async {
    final box = await Hive.openBox<Schedule>('schedules');
    await box.deleteAt(index);
    _schedules.removeAt(index);
    notifyListeners();
  }
  
  Future<void> toggleComplete(int index) async {
    _schedules[index].isCompleted = !_schedules[index].isCompleted;
    if (_schedules[index].isCompleted) {
      _schedules[index].completionCount++;
    }
    final box = await Hive.openBox<Schedule>('schedules');
    await box.putAt(index, _schedules[index]);
    notifyListeners();
  }
  
  Future<void> updateSchedule(int index, Schedule schedule) async {
    final box = await Hive.openBox<Schedule>('schedules');
    await box.putAt(index, schedule);
    _schedules[index] = schedule;
    notifyListeners();
  }
  
  int get totalSchedules => _schedules.length;
  int get completedToday => _schedules.where((s) => s.isCompleted).length;
  int get totalCompletions => _schedules.fold(0, (sum, s) => sum + s.completionCount);
}
