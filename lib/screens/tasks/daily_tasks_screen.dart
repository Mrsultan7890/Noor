import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  Map<String, bool> _completedTasks = {};
  String _todayDate = '';

  @override
  void initState() {
    super.initState();
    _todayDate = DateTime.now().toString().split(' ')[0];
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString('tasks_date') ?? '';
    
    if (savedDate != _todayDate) {
      await prefs.clear();
      await prefs.setString('tasks_date', _todayDate);
    }
    
    setState(() {
      for (var category in _categories) {
        for (var task in category.tasks) {
          _completedTasks[task.id] = prefs.getBool(task.id) ?? false;
        }
      }
    });
  }

  Future<void> _toggleTask(String taskId, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(taskId, value);
    setState(() {
      _completedTasks[taskId] = value;
    });
  }

  int _getTotalPoints() {
    int total = 0;
    for (var category in _categories) {
      for (var task in category.tasks) {
        if (_completedTasks[task.id] == true) {
          total += task.points;
        }
      }
    }
    return total;
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
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              await prefs.setString('tasks_date', _todayDate);
              _loadTasks();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Theme.of(context).primaryColor, Colors.teal],
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
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
                final completed = category.tasks.where((t) => _completedTasks[t.id] == true).length;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ExpansionTile(
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: category.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(category.icon, color: category.color, size: 28),
                    ),
                    title: Text(
                      category.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('$completed / ${category.tasks.length} completed'),
                    children: category.tasks.map((task) {
                      final isCompleted = _completedTasks[task.id] ?? false;
                      return CheckboxListTile(
                        value: isCompleted,
                        onChanged: (value) => _toggleTask(task.id, value ?? false),
                        title: Text(
                          task.name,
                          style: TextStyle(
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        subtitle: Text('+${task.points} points'),
                        secondary: Icon(
                          isCompleted ? Icons.check_circle : Icons.circle_outlined,
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
