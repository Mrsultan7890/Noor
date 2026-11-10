import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:noor/services/arabic_course_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('loads localized lessons and quiz configuration from the manifest',
      () async {
    final requestHosts = <String>[];
    final service = ArabicCourseService(
      client: _courseClient(requestHosts: requestHosts),
    );

    final content = await service.load(languageCode: 'ur');

    expect(content.levels, hasLength(2));
    expect(content.levels.map((level) => level.order), [1, 2]);
    expect(content.levels.first.lessons, hasLength(17));
    expect(content.levels.first.lessons.last.id, 'basic-lesson-17');
    expect(content.levels.first.title, 'بنیادی');
    expect(content.levels.first.lessons.first.title, 'سبق 1');
    expect(content.levels.first.lessons.first.quizQuestionCount, 2);
    expect(content.levels.first.lessons.first.chart['mark'], 'َ');
    expect(content.levels.first.lessons.first.items.first.meaning, 'معنی 0');
    expect(content.levels.first.quizPrompt, 'آواز سنیں اور متن منتخب کریں۔');
    expect(content.levels[1].lessons, hasLength(3));
    expect(content.levels[1].lessons.first.id, 'words-lesson-1');
    expect(content.levels[1].title, 'الفاظ اور آسان جملے');
    expect(content.isOffline, isFalse);
    expect(requestHosts, everyElement('cdn.jsdelivr.net'));
  });

  test('falls back to GitHub raw when jsDelivr is unavailable', () async {
    final requestHosts = <String>[];
    final service = ArabicCourseService(
      client: _courseClient(
        requestHosts: requestHosts,
        failCdn: true,
      ),
    );

    final content = await service.load();

    expect(content.levels, hasLength(2));
    expect(requestHosts, contains('cdn.jsdelivr.net'));
    expect(requestHosts, contains('raw.githubusercontent.com'));
  });

  test('falls back to GitHub raw after a CDN connection error', () async {
    final requestHosts = <String>[];
    final service = ArabicCourseService(
      client: MockClient((request) async {
        requestHosts.add(request.url.host);
        if (request.url.host == 'cdn.jsdelivr.net') {
          throw const SocketException('CDN unavailable');
        }
        return _courseResponse(request);
      }),
    );

    await service.load();

    expect(requestHosts.take(2), [
      'cdn.jsdelivr.net',
      'raw.githubusercontent.com',
    ]);
    expect(requestHosts.where((host) => host == 'cdn.jsdelivr.net').length, 6);
    expect(
      requestHosts.where((host) => host == 'raw.githubusercontent.com').length,
      6,
    );
  });

  test('caches audio files and falls back to GitHub raw', () async {
    final cacheDirectory = await Directory.systemTemp.createTemp(
      'arabic-course-audio-test-',
    );
    addTearDown(() => cacheDirectory.delete(recursive: true));
    final requestHosts = <String>[];
    final service = ArabicCourseService(
      client: MockClient((request) async {
        requestHosts.add(request.url.host);
        if (request.url.host == 'cdn.jsdelivr.net') {
          return http.Response('', 503);
        }
        return http.Response.bytes([1, 2, 3], 200);
      }),
      cacheDirectoryProvider: () async => cacheDirectory,
    );

    final firstFile = await service.audioFile('audio/test/lesson-1-0.mp3');
    final secondFile = await service.audioFile('audio/test/lesson-1-0.mp3');
    final reloadedService = ArabicCourseService(
      client: MockClient((request) async {
        requestHosts.add(request.url.host);
        return http.Response('', 503);
      }),
      cacheDirectoryProvider: () async => cacheDirectory,
    );
    final reloadedFile =
        await reloadedService.audioFile('audio/test/lesson-1-0.mp3');

    expect(firstFile.path, secondFile.path);
    expect(await secondFile.readAsBytes(), [1, 2, 3]);
    expect(reloadedFile.path, firstFile.path);
    expect(requestHosts, ['cdn.jsdelivr.net', 'raw.githubusercontent.com']);
  });

  test('uses the saved lesson data if the content host is unavailable',
      () async {
    final online = ArabicCourseService(client: _courseClient());
    await online.load();

    final offline = ArabicCourseService(
      client: MockClient((_) async => http.Response('', 503)),
    );
    final content = await offline.load();

    expect(content.levels.expand((level) => level.lessons), hasLength(20));
    expect(content.isOffline, isTrue);
  });

  test('keeps previously cached Basic lessons available offline', () async {
    final lessons = List.generate(17, _lesson);
    SharedPreferences.setMockInitialValues({
      'arabic_basic_course_4a461f940c740fc22f99c605c59a1713db3d0500':
          jsonEncode({
        'lessonTexts': [
          jsonEncode(_unit(lessons.take(5).toList())),
          jsonEncode(_unit(lessons.skip(5).toList())),
        ],
        'quizText': jsonEncode({
          'courseId': 'arabic',
          'levelId': 'basic',
          'questionType': 'listen_and_choose',
          'prompts': {'en': 'Listen and choose.', 'ur': 'آواز سنیں۔'},
          'lessons': [
            for (var index = 0; index < 17; index++)
              {
                'lessonId': 'basic-lesson-${index + 1}',
                'questionCount': 2,
              }
          ],
        }),
      }),
    });

    final offline = ArabicCourseService(
      client: MockClient((_) async => http.Response('', 503)),
    );
    final content = await offline.load();

    expect(content.levels, hasLength(1));
    expect(content.levels.single.lessons, hasLength(17));
    expect(content.isOffline, isTrue);
  });

  test('spends hearts on mistakes and awards a lesson once', () async {
    final progressService = ArabicCourseProgressService();

    final initial = await progressService.load();
    expect(initial.hearts, ArabicCourseProgress.dailyHeartLimit);

    final afterMistake = await progressService.useHeart();
    expect(afterMistake.hearts, 4);
    final syncPayload = await ArabicCourseProgressService().toSyncJson();
    final spendIds = (syncPayload['heart_spend_ids'] as List).cast<String>();
    expect(spendIds, hasLength(1));
    final syncedProgress = await progressService.mergeServerProgress(
      {
        'completed_lesson_ids': <String>[],
        'hearts': 4,
        'heart_date': syncPayload['heart_date'],
      },
      syncedHeartSpendIds: spendIds.toSet(),
    );
    expect(syncedProgress.pendingHeartSpendIds, isEmpty);

    final firstCompletion =
        await progressService.completeLesson('basic-alphabet-01');
    expect(firstCompletion.points, 20);
    expect(firstCompletion.completedLessonIds, contains('basic-alphabet-01'));

    final repeatedCompletion =
        await progressService.completeLesson('basic-alphabet-01');
    expect(repeatedCompletion.points, 20);
    expect(repeatedCompletion.hearts, 4);
  });

  test('does not spend more than five hearts in a day', () async {
    final progressService = ArabicCourseProgressService();

    var progress = await progressService.load();
    for (var index = 0; index < ArabicCourseProgress.dailyHeartLimit; index++) {
      progress = await progressService.useHeart();
    }

    expect(progress.hearts, 0);
    expect((await progressService.useHeart()).hearts, 0);
  });

  test('refills hearts on a new day without losing lesson progress', () async {
    final yesterday = DateTime.now().toUtc().subtract(const Duration(days: 1));
    final date = '${yesterday.year.toString().padLeft(4, '0')}-'
        '${yesterday.month.toString().padLeft(2, '0')}-'
        '${yesterday.day.toString().padLeft(2, '0')}';
    SharedPreferences.setMockInitialValues({
      'arabic_basic_progress_v1': jsonEncode({
        'completedLessonIds': ['basic-lesson-1'],
        'points': 20,
        'hearts': 1,
        'heartDate': date,
      }),
    });

    final progress = await ArabicCourseProgressService().load();

    expect(progress.hearts, ArabicCourseProgress.dailyHeartLimit);
    expect(progress.points, 20);
    expect(progress.completedLessonIds, contains('basic-lesson-1'));
  });

  test('merges account progress without restoring spent hearts', () async {
    final today = DateTime.now().toUtc();
    final date = '${today.year.toString().padLeft(4, '0')}-'
        '${today.month.toString().padLeft(2, '0')}-'
        '${today.day.toString().padLeft(2, '0')}';
    SharedPreferences.setMockInitialValues({
      'arabic_basic_progress_v1': jsonEncode({
        'completedLessonIds': ['basic-alphabet-01'],
        'points': 20,
        'hearts': 2,
        'heartDate': date,
      }),
    });

    final service = ArabicCourseProgressService();
    final merged = await service.mergeServerProgress({
      'completed_lesson_ids': ['basic-alphabet-01', 'basic-alphabet-02'],
      'hearts': 4,
      'heart_date': date,
    });

    expect(merged.completedLessonIds, {
      'basic-alphabet-01',
      'basic-alphabet-02',
    });
    expect(merged.points, 40);
    expect(merged.hearts, 2);
  });
}

MockClient _courseClient({
  List<String>? requestHosts,
  bool failCdn = false,
}) =>
    MockClient((request) async {
      requestHosts?.add(request.url.host);
      if (failCdn && request.url.host == 'cdn.jsdelivr.net') {
        return http.Response('', 503);
      }
      return _courseResponse(request);
    });

http.Response _courseResponse(http.Request request) {
  final file = request.url.path.split('/').last;
  final lessons = List.generate(17, _lesson);
  final json = switch (file) {
    'manifest.json' => {
        'courseId': 'arabic',
        'levels': [
          {
            'id': 'basic',
            'order': 1,
            'title': {
              'en': 'Basic',
              'ur': 'بنیادی',
              'id': 'Dasar',
              'tr': 'Temel',
              'fr': 'Bases',
            },
            'lessonFiles': ['arabic/alphabet.json', 'arabic/reading.json'],
            'quizFile': 'arabic/quizzes.json',
          },
          {
            'id': 'words',
            'order': 2,
            'title': {
              'en': 'Words & Simple Sentences',
              'ur': 'الفاظ اور آسان جملے',
              'id': 'Kata dan Kalimat Sederhana',
              'tr': 'Kelimeler ve Basit Cümleler',
              'fr': 'Mots et phrases simples',
            },
            'lessonFiles': ['arabic/words.json'],
            'quizFile': 'arabic/words-quizzes.json',
          },
        ],
      },
    'alphabet.json' => _unit(lessons.take(5).toList()),
    'reading.json' => _unit(lessons.skip(5).toList()),
    'words.json' => _unit(
        List.generate(3, (index) => _lesson(index, levelId: 'words')),
        levelId: 'words'),
    'quizzes.json' => {
        'courseId': 'arabic',
        'levelId': 'basic',
        'questionType': 'listen_and_choose',
        'prompts': {
          'en': 'Listen and choose the matching text.',
          'ur': 'آواز سنیں اور متن منتخب کریں۔',
        },
        'lessons': [
          for (var index = 0; index < 17; index++)
            {
              'lessonId': 'basic-lesson-${index + 1}',
              'questionCount': 2,
            }
        ],
      },
    'words-quizzes.json' => {
        'courseId': 'arabic',
        'levelId': 'words',
        'questionType': 'listen_and_choose',
        'prompts': {
          'en': 'Listen to the Arabic audio, then choose the matching text.',
          'ur': 'عربی آواز سنیں، پھر اس سے ملتا ہوا متن منتخب کریں۔',
        },
        'lessons': [
          for (var index = 0; index < 3; index++)
            {
              'lessonId': 'words-lesson-${index + 1}',
              'questionCount': 2,
            }
        ],
      },
    _ => throw StateError('Unexpected Arabic course request: $request'),
  };
  return http.Response.bytes(utf8.encode(jsonEncode(json)), 200);
}

Map<String, dynamic> _unit(
  List<Map<String, dynamic>> lessons, {
  String levelId = 'basic',
}) =>
    {
      'courseId': 'arabic',
      'levelId': levelId,
      'lessons': lessons,
    };

Map<String, dynamic> _lesson(int index, {String levelId = 'basic'}) {
  final order = index + 1;
  return {
    'id': '$levelId-lesson-$order',
    'order': order,
    'title': {'en': 'Lesson $order', 'ur': 'سبق $order'},
    'objective': {'en': 'Learn lesson $order.', 'ur': 'سبق $order سیکھیں۔'},
    'instruction': {'en': 'Read and listen.', 'ur': 'پڑھیں اور سنیں۔'},
    'chart': {'mark': 'َ', 'letters': 'ب ت'},
    'items': [
      for (var itemIndex = 0; itemIndex < 2; itemIndex++)
        {
          'id': '$levelId-lesson-$order-item-$itemIndex',
          'type': 'letter',
          'arabic': itemIndex == 0 ? 'بَ' : 'تَ',
          'transliteration': itemIndex == 0 ? 'ba' : 'ta',
          'audio': {'path': 'audio/test/lesson-$order-$itemIndex.mp3'},
          'meaning': {'en': 'Meaning $itemIndex', 'ur': 'معنی $itemIndex'},
          if (itemIndex == 0)
            'forms': {
              'isolated': 'ب',
              'initial': 'بـ',
            },
        }
    ],
  };
}
