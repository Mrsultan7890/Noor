import 'package:flutter/material.dart';
import '../../models/story_model.dart';
import '../../data/stories_data.dart';
import 'story_detail_screen.dart';

class StoryListScreen extends StatelessWidget {
  final StoryCategory category;

  const StoryListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final stories = getStoriesByCategory(category.id);
    final color = Color(int.parse(category.color));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(category.nameUrdu),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: stories.length,
        itemBuilder: (context, index) {
          final story = stories[index];
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                story.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  story.titleUrdu,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: color),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StoryDetailScreen(story: story),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
