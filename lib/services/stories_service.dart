import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../data/stories_data.dart';
import '../models/story_model.dart';
import 'utf8_json.dart';

class StoriesService {
  StoriesService({http.Client? client}) : _client = client;

  static const _cacheKey = 'published_stories_catalog_v1';
  static const _cacheTimeKey = 'published_stories_catalog_fetched_at_v1';
  static const _cacheMaxAge = Duration(hours: 24);
  static final _catalogUri = Uri.parse(
    'https://raw.githubusercontent.com/Mrsultan7890/noor/main/data/stories.json',
  );
  final http.Client? _client;

  Future<Map<String, dynamic>> getStories({bool forceRefresh = false}) async {
    final preferences = await SharedPreferences.getInstance();
    final cached = _readCachedStories(preferences, isOffline: false);
    final fetchedAt = preferences.getInt(_cacheTimeKey);
    if (!forceRefresh && cached != null && fetchedAt != null) {
      final cacheAge = DateTime.now().difference(
        DateTime.fromMillisecondsSinceEpoch(fetchedAt),
      );
      if (cacheAge >= Duration.zero && cacheAge < _cacheMaxAge) {
        return cached;
      }
    }

    try {
      final response =
          await (_client?.get(_catalogUri) ?? http.get(_catalogUri))
              .timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) {
        debugPrint(
          'GitHub story catalog returned HTTP ${response.statusCode}; '
          'using cached or bundled stories.',
        );
        return _offlineStories(preferences);
      }

      final catalog = decodeUtf8JsonResponse(response);
      if (catalog is! Map<String, dynamic> ||
          catalog['categories'] is! List ||
          catalog['stories'] is! List) {
        throw const FormatException(
            'GitHub story catalog has an invalid shape.');
      }

      final categories = parseCategories(catalog['categories'] as List);
      final stories = parseStories(catalog['stories'] as List);
      if (categories.isEmpty || stories.isEmpty) {
        throw const FormatException('GitHub story catalog cannot be empty.');
      }

      await preferences.setString(_cacheKey, json.encode(catalog));
      await preferences.setInt(
        _cacheTimeKey,
        DateTime.now().millisecondsSinceEpoch,
      );
      return _combineWithBundled(
        categories: categories,
        stories: stories,
        isOffline: false,
      );
    } on http.ClientException catch (error) {
      debugPrint('Could not fetch GitHub story catalog: $error');
      return _offlineStories(preferences);
    } on TimeoutException catch (error) {
      debugPrint('Timed out fetching GitHub story catalog: $error');
      return _offlineStories(preferences);
    } on FormatException catch (error) {
      debugPrint('GitHub story catalog is invalid: $error');
      return _offlineStories(preferences);
    } on TypeError catch (error) {
      debugPrint('GitHub story catalog has invalid fields: $error');
      return _offlineStories(preferences);
    }
  }

  Map<String, dynamic> _offlineStories(SharedPreferences preferences) {
    return _readCachedStories(preferences, isOffline: true) ??
        {
          ..._bundledCatalog(),
          'isOffline': true,
        };
  }

  Map<String, dynamic>? _readCachedStories(
    SharedPreferences preferences, {
    required bool isOffline,
  }) {
    final cached = preferences.getString(_cacheKey);
    if (cached == null) return null;
    try {
      final catalog = json.decode(cached);
      if (catalog is Map<String, dynamic> &&
          catalog['categories'] is List &&
          catalog['stories'] is List) {
        final categories = parseCategories(catalog['categories'] as List);
        final stories = parseStories(catalog['stories'] as List);
        if (categories.isNotEmpty && stories.isNotEmpty) {
          return _combineWithBundled(
            categories: categories,
            stories: stories,
            isOffline: isOffline,
          );
        }
      }
    } on FormatException catch (error) {
      debugPrint('Cached story catalog is invalid: $error');
    } on TypeError catch (error) {
      debugPrint('Cached story catalog has invalid fields: $error');
    }
    return null;
  }

  Map<String, dynamic> _combineWithBundled({
    required List<StoryCategory> categories,
    required List<IslamicStory> stories,
    required bool isOffline,
  }) {
    final mergedCategories = {
      for (final category in storyCategories) category.id: category,
      for (final category in categories) category.id: category,
    };
    final mergedStories = {
      for (final story in getAllStories()) story.id: story,
      for (final story in stories) story.id: story,
    };

    return {
      'categories': mergedCategories.values.map(_categoryToJson).toList(),
      'stories': mergedStories.values.map(_storyToJson).toList(),
      'isOffline': isOffline,
    };
  }

  Map<String, dynamic> _bundledCatalog() => {
        'categories': storyCategories.map(_categoryToJson).toList(),
        'stories': getAllStories().map(_storyToJson).toList(),
      };

  Map<String, dynamic> _categoryToJson(StoryCategory category) => {
        'id': category.id,
        'name': category.name,
        'nameUrdu': category.nameUrdu,
        'icon': category.icon,
        'color': category.color,
        'description': category.description,
      };

  Map<String, dynamic> _storyToJson(IslamicStory story) => {
        'id': story.id,
        'title': story.title,
        'titleUrdu': story.titleUrdu,
        'category': story.category,
        'content': story.content,
        'contentUrdu': story.contentUrdu,
        'lesson': story.lesson,
        'lessonUrdu': story.lessonUrdu,
        'tags': story.tags,
      };

  List<StoryCategory> parseCategories(List<dynamic> json) {
    return json.map((category) {
      if (category is! Map<String, dynamic>) {
        throw const FormatException('Invalid story category data.');
      }
      return StoryCategory(
        id: category['id'] as String,
        name: category['name'] as String,
        nameUrdu: category['nameUrdu'] as String,
        icon: category['icon'] as String,
        color: category['color'] as String,
        description: category['description'] as String,
      );
    }).toList();
  }

  List<IslamicStory> parseStories(List<dynamic> json) {
    return json.map((story) {
      if (story is! Map<String, dynamic>) {
        throw const FormatException('Invalid story data.');
      }
      return IslamicStory(
        id: story['id'] as String,
        title: story['title'] as String,
        titleUrdu: story['titleUrdu'] as String,
        category: story['category'] as String,
        content: story['content'] as String,
        contentUrdu: story['contentUrdu'] as String,
        lesson: story['lesson'] as String,
        lessonUrdu: story['lessonUrdu'] as String,
        tags: List<String>.from(story['tags'] as List),
      );
    }).toList();
  }
}
