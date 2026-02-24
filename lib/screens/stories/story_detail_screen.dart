import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/story_model.dart';

class StoryDetailScreen extends StatefulWidget {
  final IslamicStory story;

  const StoryDetailScreen({super.key, required this.story});

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  bool _isRead = false;
  bool _showUrdu = true;

  @override
  void initState() {
    super.initState();
    _checkIfRead();
  }

  Future<void> _checkIfRead() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isRead = prefs.getBool('story_${widget.story.id}') ?? false;
    });
  }

  Future<void> _markAsRead() async {
    if (_isRead) return;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('story_${widget.story.id}', true);
    
    setState(() => _isRead = true);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Story completed! +15 points earned'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_showUrdu ? widget.story.titleUrdu : widget.story.title),
        actions: [
          IconButton(
            icon: Icon(_showUrdu ? Icons.translate : Icons.language),
            onPressed: () => setState(() => _showUrdu = !_showUrdu),
            tooltip: _showUrdu ? 'Show English' : 'Show Urdu',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isRead)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'Completed ✓',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            Text(
              _showUrdu ? widget.story.titleUrdu : widget.story.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _showUrdu ? widget.story.contentUrdu : widget.story.content,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.8,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                textAlign: _showUrdu ? TextAlign.right : TextAlign.left,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.lightbulb, color: Colors.amber),
                      SizedBox(width: 8),
                      Text(
                        'Lesson',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _showUrdu ? widget.story.lessonUrdu : widget.story.lesson,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: isDark ? Colors.white : Colors.black87,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: _showUrdu ? TextAlign.right : TextAlign.left,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (!_isRead)
              ElevatedButton.icon(
                onPressed: _markAsRead,
                icon: const Icon(Icons.check),
                label: const Text('Mark as Complete'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
