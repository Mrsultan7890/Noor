import 'package:flutter/material.dart';
import '../../services/stories_service.dart';
import '../../models/story_model.dart';
import 'story_list_screen.dart';

class StoriesHomeScreen extends StatefulWidget {
  const StoriesHomeScreen({super.key});

  @override
  State<StoriesHomeScreen> createState() => _StoriesHomeScreenState();
}

class _StoriesHomeScreenState extends State<StoriesHomeScreen> {
  final StoriesService _service = StoriesService();
  List<StoryCategory> _categories = [];
  List<IslamicStory> _stories = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStories();
  }

  Future<void> _loadStories() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _service.getStories();
      setState(() {
        _categories = _service.parseCategories(data['categories']);
        _stories = _service.parseStories(data['stories']);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load stories. Please check your connection.';
        _isLoading = false;
      });
    }
  }

  List<IslamicStory> _getStoriesByCategory(String categoryId) {
    return _stories.where((s) => s.category == categoryId).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Islamic Stories - اسلامی کہانیاں'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await _service.clearCache();
              _loadStories();
            },
            tooltip: 'Refresh stories',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadStories,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final color = Color(int.parse(category.color));
                    final stories = _getStoriesByCategory(category.id);
          
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StoryListScreen(
                      category: category,
                      stories: stories,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          category.icon,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            category.nameUrdu,
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${stories.length} Stories',
                            style: TextStyle(
                              fontSize: 14,
                              color: color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: color, size: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
