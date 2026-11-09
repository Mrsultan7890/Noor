import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:noor/services/stories_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const category = {
    'id': 'seerat',
    'name': 'Seerah',
    'nameUrdu': 'سیرت',
    'icon': '🌙',
    'color': '0xFF2E7D32',
    'description': 'Stories from the Seerah',
  };
  const story = {
    'id': 'remote-story',
    'title': 'Remote story',
    'titleUrdu': 'نئی کہانی',
    'category': 'seerat',
    'content': 'English story',
    'contentUrdu': 'اردو کہانی',
    'lesson': 'A lesson',
    'lessonUrdu': 'سبق',
    'tags': ['test'],
  };

  Map<String, dynamic> catalog({
    List<Map<String, dynamic>> categories = const [category],
    List<Map<String, dynamic>> stories = const [story],
  }) =>
      {'categories': categories, 'stories': stories};

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('loads GitHub stories and preserves bundled content as fallback',
      () async {
    final service = StoriesService(
      client: MockClient((request) async {
        expect(request.url.host, 'raw.githubusercontent.com');
        expect(request.url.path, '/Mrsultan7890/noor/main/data/stories.json');
        return http.Response(
          json.encode(catalog()),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );

    final data = await service.getStories();
    final categories = service.parseCategories(data['categories'] as List);
    final stories = service.parseStories(data['stories'] as List);

    expect(data['isOffline'], isFalse);
    expect(categories, isNotEmpty);
    expect(stories.any((item) => item.id == 'remote-story'), isTrue);
    expect(stories.any((item) => item.id == 's1'), isTrue);
    expect(
        stories.every((item) => categories.any((c) => c.id == item.category)),
        isTrue);
  });

  test('uses the cached GitHub catalog when offline', () async {
    final online = StoriesService(
      client: MockClient(
        (_) async => http.Response(
          json.encode(catalog()),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        ),
      ),
    );
    await online.getStories();

    final offline = StoriesService(
      client: MockClient((_) async => throw http.ClientException('offline')),
    );

    final data = await offline.getStories(forceRefresh: true);
    final stories = offline.parseStories(data['stories'] as List);

    expect(data['isOffline'], isTrue);
    expect(stories.any((item) => item.id == 'remote-story'), isTrue);
    expect(stories.any((item) => item.id == 's1'), isTrue);
  });

  test('uses fresh cache until force refresh is requested', () async {
    var requestCount = 0;
    final service = StoriesService(
      client: MockClient((_) async {
        requestCount++;
        return http.Response(
          json.encode(catalog()),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );

    await service.getStories();
    await service.getStories();
    expect(requestCount, 1);

    await service.getStories(forceRefresh: true);
    expect(requestCount, 2);
  });

  test('falls back to bundled stories when GitHub and cache are unavailable',
      () async {
    final service = StoriesService(
      client: MockClient(
        (_) async => http.Response('unavailable', 503),
      ),
    );

    final data = await service.getStories();
    final categories = service.parseCategories(data['categories'] as List);
    final stories = service.parseStories(data['stories'] as List);

    expect(data['isOffline'], isTrue);
    expect(categories, isNotEmpty);
    expect(stories, isNotEmpty);
    expect(
        stories.every((story) => categories.any((c) => c.id == story.category)),
        isTrue);
  });

  test('rejects malformed story records explicitly', () {
    final service = StoriesService();

    expect(
      () => service.parseStories([null]),
      throwsA(isA<FormatException>()),
    );
  });
}
