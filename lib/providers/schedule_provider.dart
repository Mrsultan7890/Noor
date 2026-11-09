import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/schedule_model.dart';
import '../services/notification_service.dart';

class ScheduleProvider extends ChangeNotifier with WidgetsBindingObserver {
  List<Schedule> _schedules = [];
  late final Future<void> _loading;
  late final Timer _dayChangeTimer;
  bool _isLoading = true;
  Object? _loadError;
  DateTime _loadedDate = _dateOnly(DateTime.now());

  List<Schedule> get schedules => _schedules;
  Future<void> get initialized => _loading;
  bool get isLoading => _isLoading;
  Object? get loadError => _loadError;

  ScheduleProvider() {
    WidgetsBinding.instance.addObserver(this);
    _loading = loadSchedules();
    _dayChangeTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _refreshIfDayChanged(),
    );
  }

  Future<void> loadSchedules() async {
    _isLoading = true;
    _loadError = null;
    try {
      final box = await Hive.openBox<Schedule>('schedules');
      _schedules = box.values.toList();
      final today = DateTime.now();
      for (final schedule in _schedules) {
        schedule.resetRecurringCompletion(today);
        final key = schedule.key;
        if (key is int) {
          await box.put(key, schedule);
        }
      }
      _sortSchedules();
      _loadedDate = _dateOnly(today);
    } catch (error, stackTrace) {
      _loadError = error;
      debugPrint('Could not load schedules: $error\n$stackTrace');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSchedule(Schedule schedule) async {
    final box = await Hive.openBox<Schedule>('schedules');
    await box.add(schedule);
    _schedules.add(schedule);
    _sortSchedules();
    notifyListeners();
  }

  Future<void> deleteSchedule(int index) async {
    final box = await Hive.openBox<Schedule>('schedules');
    final schedule = _schedules[index];
    final key = schedule.key;
    if (key is! int) {
      throw StateError('Cannot find a stable key for the schedule.');
    }
    await NotificationService().cancelScheduleAlarms(key);
    await box.delete(key);
    _schedules.removeAt(index);
    notifyListeners();
  }

  Future<void> toggleComplete(int index) async {
    final schedule = _schedules[index];
    final key = schedule.key;
    if (key is! int) {
      throw StateError('Cannot find a stable key for the schedule.');
    }
    final box = await Hive.openBox<Schedule>('schedules');
    schedule.resetRecurringCompletion(DateTime.now());
    schedule.setCompleted(!schedule.isCompleted);
    await box.put(key, schedule);
    notifyListeners();
  }

  Future<void> updateSchedule(int index, Schedule schedule) async {
    final box = await Hive.openBox<Schedule>('schedules');
    final existing = _schedules[index];
    final key = existing.key;
    if (key is! int) {
      throw StateError('Cannot find a stable key for the schedule.');
    }
    existing.resetRecurringCompletion(DateTime.now());
    existing
      ..title = schedule.title
      ..description = schedule.description
      ..time = schedule.time
      ..type = schedule.type
      ..isRecurring = schedule.isRecurring
      ..recurringDays = schedule.recurringDays
      ..hasAlarm = schedule.hasAlarm;
    await box.put(key, existing);
    _sortSchedules();
    notifyListeners();
  }

  int get totalSchedules => _schedules.length;
  int get completedToday => _schedules.where((s) => s.wasCompletedToday).length;
  int get totalCompletions =>
      _schedules.fold(0, (sum, s) => sum + s.completionCount);

  void _sortSchedules() {
    _schedules.sort((a, b) {
      final aMinutes = a.time.hour * 60 + a.time.minute;
      final bMinutes = b.time.hour * 60 + b.time.minute;
      return aMinutes.compareTo(bMinutes);
    });
  }

  void _refreshIfDayChanged() {
    final today = _dateOnly(DateTime.now());
    if (today != _loadedDate) {
      unawaited(loadSchedules());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshIfDayChanged();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _dayChangeTimer.cancel();
    super.dispose();
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
