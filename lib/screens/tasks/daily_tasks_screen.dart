import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_theme.dart';

class DailyTasksScreen extends StatefulWidget {
  const DailyTasksScreen({super.key});

  @override
  State<DailyTasksScreen> createState() => _DailyTasksScreenState();
}

class _DailyTasksScreenState extends State<DailyTasksScreen> {
  final List<TaskCategory> _categories = [
    TaskCategory(
      name: 'Prayers',
      icon: Icons.self_improvement,
      color: Colors.blue,
      tasks: [
        Task(id: 'fajr', name: 'Fajr Prayer', points: 5),
        Task(id: 'dhuhr', name: 'Dhuhr Prayer', points: 5),
        Task(id: 'asr', name: 'Asr Prayer', points: 5),
        Task(id: 'maghrib', name: 'Maghrib Prayer', points: 5),
        Task(id: 'isha', name: 'Isha Prayer', points: 5),
      ],
    ),
    TaskCategory(
      name: 'Quran',
      icon: Icons.menu_book,
      color: Colors.green,
      tasks: [
        Task(id: 'quran_1page', name: 'Read 1 Page', points: 5),
        Task(id: 'quran_1juz', name: 'Read 1 Juz', points: 20),
        Task(id: 'quran_memorize', name: 'Memorize Ayah', points: 15),
      ],
    ),
    TaskCategory(
      name: 'Dhikr & Dua',
      icon: Icons.favorite,
      color: Colors.pink,
      tasks: [
        Task(id: 'morning_adhkar', name: 'Morning Adhkar', points: 10),
        Task(id: 'evening_adhkar', name: 'Evening Adhkar', points: 10),
        Task(id: 'tasbih_100', name: 'Tasbih 100x', points: 5),
      ],
    ),
    TaskCategory(
      name: 'Good Deeds',
      icon: Icons.volunteer_activism,
      color: Colors.orange,
      tasks: [
        Task(id: 'charity', name: 'Give Charity', points: 10),
        Task(id: 'help_someone', name: 'Help Someone', points: 10),
        Task(id: 'smile', name: 'Smile at Others', points: 2),
      ],
    ),
  ];

  final Map<String, bool> _completedTasks = {};
  final Map<String, int> _claimedPoints = {};
  String _todayDate = '';

  @override
  void initState() {
    super.initState();
    _todayDate = _dateKey(DateTime.now());
    _loadTasks();
  }

  String _dateKey(DateTime date) => '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString('tasks_date') ?? '';

    if (savedDate != _todayDate) {
      await prefs.setString('tasks_date', _todayDate);
    }

    final oldTaskKeys = _categories
        .expand((category) => category.tasks)
        .map((task) => task.id)
        .toList();
    final completedTasks = <String, bool>{};
    for (final taskId in oldTaskKeys) {
      final storedValue = prefs.getBool(_taskPreferenceKey(taskId));
      final legacyValue =
          savedDate == _todayDate ? prefs.getBool(taskId) : null;
      completedTasks[taskId] = storedValue ?? legacyValue ?? false;
      final task = _categories
          .expand((category) => category.tasks)
          .firstWhere((task) => task.id == taskId);
      final storedPoints = prefs.getInt(_rewardPreferenceKey(taskId));
      if (storedPoints != null) {
        _claimedPoints[taskId] = storedPoints;
      } else if (completedTasks[taskId] == true) {
        _claimedPoints[taskId] = task.points;
      }
      if (storedValue == null && legacyValue != null) {
        await prefs.setBool(_taskPreferenceKey(taskId), legacyValue);
      }
    }
    for (final taskKey in oldTaskKeys) {
      await prefs.remove(taskKey);
    }
    if (!mounted) return;
    setState(() {
      _completedTasks
        ..clear()
        ..addAll(completedTasks);
    });
  }

  String _taskPreferenceKey(String taskId) =>
      'daily_task_${_todayDate}_$taskId';

  String _rewardPreferenceKey(String taskId) =>
      'daily_task_reward_${_todayDate}_$taskId';

  Future<void> _resetTasks() async {
    final prefs = await SharedPreferences.getInstance();
    _todayDate = _dateKey(DateTime.now());
    await prefs.setString('tasks_date', _todayDate);
    for (final category in _categories) {
      for (final task in category.tasks) {
        await prefs.remove(_taskPreferenceKey(task.id));
        await prefs.remove(task.id);
      }
    }
    if (!mounted) return;
    setState(() {
      _completedTasks
        ..clear()
        ..addEntries(
          _categories
              .expand((category) => category.tasks)
              .map((task) => MapEntry(task.id, false)),
        );
    });
  }

  Future<void> _toggleTask(String taskId, bool value) async {
    if (value) {
      final task = _categories
          .expand((category) => category.tasks)
          .firstWhere((task) => task.id == taskId);
      final userProvider = context.read<UserProvider>();
      if (userProvider.isAuthenticated) {
        final pointsEarned = await userProvider.logActivity(
          activityType: 'daily_task_completed',
          points: task.points,
          metadata: {'task_id': task.id},
        );
        if (pointsEarned == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Could not sync this task: ${userProvider.error ?? 'Please try again.'}',
                ),
              ),
            );
          }
          return;
        }
        _claimedPoints[task.id] = pointsEarned;
      } else {
        _claimedPoints[task.id] = task.points;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_taskPreferenceKey(taskId), value);
    final claimedPoints = _claimedPoints[taskId];
    if (claimedPoints != null) {
      await prefs.setInt(_rewardPreferenceKey(taskId), claimedPoints);
    }
    if (!mounted) return;
    setState(() {
      _completedTasks[taskId] = value;
    });
    if (value && !context.read<UserProvider>().isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Task saved locally. Sign in to sync points to your profile.'),
        ),
      );
    }
  }

  int _getTotalPoints() {
    return _claimedPoints.entries
        .where((entry) => _completedTasks[entry.key] == true)
        .fold(0, (total, entry) => total + entry.value);
  }

  int _getCompletedCount() {
    return _completedTasks.values.where((v) => v == true).length;
  }

  int _getTotalCount() {
    int total = 0;
    for (var category in _categories) {
      total += category.tasks.length;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final completed = _getCompletedCount();
    final total = _getTotalCount();
    final points = _getTotalPoints();
    final progress = total > 0 ? completed / total : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetTasks,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppTheme
                    .palettes[context.watch<ThemeProvider>().selectedTheme]!
                    .gradientColors,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Today\'s Progress',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        Text(
                          '$completed / $total Tasks',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '$points pts',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final completed = category.tasks
                    .where((t) => _completedTasks[t.id] == true)
                    .length;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ExpansionTile(
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: category.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:
                          Icon(category.icon, color: category.color, size: 28),
                    ),
                    title: Text(
                      category.name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle:
                        Text('$completed / ${category.tasks.length} completed'),
                    children: category.tasks.map((task) {
                      final isCompleted = _completedTasks[task.id] ?? false;
                      return CheckboxListTile(
                        value: isCompleted,
                        onChanged: (value) =>
                            _toggleTask(task.id, value ?? false),
                        title: Text(
                          task.name,
                          style: TextStyle(
                            decoration:
                                isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        subtitle: Text('+${task.points} points'),
                        secondary: Icon(
                          isCompleted
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: isCompleted ? Colors.green : Colors.grey,
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TaskCategory {
  final String name;
  final IconData icon;
  final Color color;
  final List<Task> tasks;

  TaskCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.tasks,
  });
}

class Task {
  final String id;
  final String name;
  final int points;

  Task({required this.id, required this.name, required this.points});
}
