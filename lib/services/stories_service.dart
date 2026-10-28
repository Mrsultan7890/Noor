import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/story_model.dart';

class StoriesService {
  static const String githubUrl = 
      'https://raw.githubusercontent.com/YOUR_USERNAME/noor/main/data/stories.json';
  
  static const String cacheKey = 'cached_stories';
  static const String cacheTimeKey = 'stories_cache_time';
  static const Duration cacheExpiry = Duration(hours: 24);

  Future<Map<String, dynamic>> getStories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheTime = prefs.getString(cacheTimeKey);
      final cachedData = prefs.getString(cacheKey);
      
      if (cacheTime != null && cachedData != null) {
        final cacheDate = DateTime.parse(cacheTime);
        if (DateTime.now().difference(cacheDate) < cacheExpiry) {
          return json.decode(cachedData);
        }
      }
      
      final response = await http.get(Uri.parse(githubUrl)).timeout(
        const Duration(seconds: 10),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        await prefs.setString(cacheKey, json.encode(data));
        await prefs.setString(cacheTimeKey, DateTime.now().toIso8601String());
        return data;
      }
      
      if (cachedData != null) {
        return json.decode(cachedData);
      }
      
      throw Exception('Failed to load stories');
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(cacheKey);
      if (cachedData != null) {
        return json.decode(cachedData);
      }
      rethrow;
    }
  }

  List<StoryCategory> parseCategories(List<dynamic> json) {
    return json.map((cat) => StoryCategory(
      id: cat['id'],
      name: cat['name'],
      nameUrdu: cat['nameUrdu'],
      icon: cat['icon'],
      color: cat['color'],
      description: cat['description'],
    )).toList();
  }

  List<IslamicStory> parseStories(List<dynamic> json) {
    return json.map((story) => IslamicStory(
      id: story['id'],
      title: story['title'],
      titleUrdu: story['titleUrdu'],
      category: story['category'],
      content: story['content'],
      contentUrdu: story['contentUrdu'],
      lesson: story['lesson'],
      lessonUrdu: story['lessonUrdu'],
      tags: List<String>.from(story['tags']),
    )).toList();
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(cacheKey);
    await prefs.remove(cacheTimeKey);
  }
}
