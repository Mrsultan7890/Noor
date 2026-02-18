import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/schedule_provider.dart';
import 'schedule_builder_screen.dart';
import 'package:intl/intl.dart';

class ScheduleListScreen extends StatelessWidget {
  const ScheduleListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Schedule - میرا شیڈول'),
      ),
      body: Consumer<ScheduleProvider>(
        builder: (context, provider, child) {
          if (provider.schedules.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.schedule,
                    size: 100,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No schedules yet',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first Islamic routine',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            itemCount: provider.schedules.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final schedule = provider.schedules[index];
              final timeFormat = DateFormat('hh:mm a');
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getColorForType(schedule.type),
                    child: Icon(
                      _getIconForType(schedule.type),
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    schedule.title,
                    style: TextStyle(
                      decoration: schedule.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(schedule.description),
                      const SizedBox(height: 4),
                      Text(
                        timeFormat.format(schedule.time),
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: schedule.isCompleted,
                        onChanged: (value) {
                          provider.toggleComplete(index);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          provider.deleteSchedule(index);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ScheduleBuilderScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Schedule'),
      ),
    );
  }
  
  Color _getColorForType(String type) {
    switch (type) {
      case 'quran':
        return Colors.green;
      case 'tasbih':
        return Colors.teal;
      case 'dua':
        return Colors.pink;
      case 'hadith':
        return Colors.brown;
      default:
        return Colors.blue;
    }
  }
  
  IconData _getIconForType(String type) {
    switch (type) {
      case 'quran':
        return Icons.menu_book;
      case 'tasbih':
        return Icons.circle_outlined;
      case 'dua':
        return Icons.favorite;
      case 'hadith':
        return Icons.book;
      default:
        return Icons.event;
    }
  }
}
