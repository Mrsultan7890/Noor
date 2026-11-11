import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:math' show max, min, Random;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/arabic_course_model.dart';

class ArabicCourseService {
  ArabicCourseService({
    http.Client? client,
    Future<Directory> Function()? cacheDirectoryProvider,
  })  : _client = client,
        _cacheDirectoryProvider =
            cacheDirectoryProvider ?? getApplicationSupportDirectory;

  static const contentRevision = '27a3277616bc1e6d0682ffca6b0a9d950736ed0f';
  static const _cacheKey = 'arabic_course_$contentRevision';
  static const _legacyCacheKey =
      'arabic_basic_course_4a461f940c740fc22f99c605c59a1713db3d0500';
  static const _owner = 'truthwayofislam';
  static const _repository = 'arabic-learning-content';

  final http.Client? _client;
  final Future<Directory> Function() _cacheDirectoryProvider;
  final Map<String, Future<File>> _pendingAudioDownloads = {};

  Uri _contentUri(String path, {required bool useGitHubRaw}) {
    if (path.startsWith('/') ||
        path.split('/').any((segment) => segment.isEmpty || segment == '..')) {
      throw FormatException('Invalid Arabic content path "$path".');
    }
    if (useGitHubRaw) {
      return Uri.https(
        'raw.githubusercontent.com',
        '/$_owner/$_repository/$contentRevision/$path',
      );
    }
    return Uri.https(
      'cdn.jsdelivr.net',
      '/gh/$_owner/$_repository@$contentRevision/$path',
    );
  }

  Future<http.Response> _fetchResponse(String path) async {
    Object? lastError;
    for (final useGitHubRaw in [false, true]) {
      final uri = _contentUri(path, useGitHubRaw: useGitHubRaw);
      try {
        final response = await (_client?.get(uri) ?? http.get(uri)).timeout(
          const Duration(seconds: 15),
        );
        if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
          return response;
        }
        lastError = http.ClientException(
          'Arabic content request failed '
          '(${response.statusCode == 200 ? 'empty response' : response.statusCode}).',
          uri,
        );
      } on http.ClientException catch (error) {
        lastError = error;
      } on TimeoutException catch (error) {
        lastError = error;
      } on IOException catch (error) {
        lastError = error;
      }
    }
    if (lastError is http.ClientException) throw lastError;
    if (lastError is TimeoutException) throw lastError;
    if (lastError is IOException) throw lastError;
    throw StateError('Arabic content could not be fetched.');
  }

  Future<String> _fetch(String path) async =>
      utf8.decode((await _fetchResponse(path)).bodyBytes);

  Future<File> audioFile(String path) async {
    if (!path.startsWith('audio/')) {
      throw FormatException('Invalid Arabic audio path "$path".');
    }
    _contentUri(path, useGitHubRaw: false);
    final pending = _pendingAudioDownloads[path];
    if (pending != null) return pending;

    final download = _cacheAudioFile(path);
    _pendingAudioDownloads[path] = download;
    try {
      return await download;
    } finally {
      _pendingAudioDownloads.remove(path);
    }
  }

  Future<File> _cacheAudioFile(String path) async {
    final cacheDirectory = await _cacheDirectoryProvider();
    final audioDirectory = Directory(
      '${cacheDirectory.path}/arabic_course/$contentRevision',
    );
    final file = File('${audioDirectory.path}/$path');
    if (await file.exists() && await file.length() > 0) return file;
    if (await file.exists()) await file.delete();

    await file.parent.create(recursive: true);
    final temporaryFile = File('${file.path}.tmp');
    if (await temporaryFile.exists()) await temporaryFile.delete();
    try {
      final response = await _fetchResponse(path);
      await temporaryFile.writeAsBytes(response.bodyBytes, flush: true);
      return await temporaryFile.rename(file.path);
    } catch (_) {
      if (await temporaryFile.exists()) await temporaryFile.delete();
      rethrow;
    }
  }

  Future<ArabicCourseContent> load({String languageCode = 'en'}) async {
    final preferences = await SharedPreferences.getInstance();
    try {
      final manifestText = await _fetch('manifest.json');
      final manifest = _decodeObject(manifestText, 'course manifest');
      if (manifest['courseId'] != 'arabic') {
        throw const FormatException('Unexpected Arabic course manifest.');
      }

      final levels = manifest['levels'];
      if (levels is! List) {
        throw const FormatException('Arabic manifest has no level list.');
      }
      if (levels.isEmpty) {
        throw const FormatException('Arabic manifest has no levels.');
      }
      final levelData = await Future.wait(levels.map((entry) async {
        if (entry is! Map<String, dynamic>) {
          throw const FormatException('Arabic manifest has an invalid level.');
        }
        final levelId = _requiredString(entry['id'], 'level id');
        final lessonPaths = _stringList(entry['lessonFiles'], 'lessonFiles');
        final quizPath = _requiredString(entry['quizFile'], 'quizFile');
        final lessonTexts = await Future.wait(lessonPaths.map(_fetch));
        return <String, dynamic>{
          'levelId': levelId,
          'lessonTexts': lessonTexts,
          'quizText': await _fetch(quizPath),
        };
      }));
      final content = _parseContent(
        manifestText: manifestText,
        levelData: levelData,
        languageCode: languageCode,
      );
      final cached = await preferences.setString(
        _cacheKey,
        json.encode({
          'manifestText': manifestText,
          'levels': levelData,
        }),
      );
      if (!cached) {
        throw StateError('Arabic lesson cache could not be saved.');
      }
      return content;
    } on http.ClientException catch (error) {
      return _loadCachedOrThrow(
        preferences,
        languageCode,
        error,
      );
    } on TimeoutException catch (error) {
      return _loadCachedOrThrow(
        preferences,
        languageCode,
        error,
      );
    } on FormatException catch (error) {
      return _loadCachedOrThrow(
        preferences,
        languageCode,
        error,
      );
    } on IOException catch (error) {
      return _loadCachedOrThrow(
        preferences,
        languageCode,
        error,
      );
    }
  }

  ArabicCourseContent _loadCachedOrThrow(
    SharedPreferences preferences,
    String languageCode,
    Object cause,
  ) {
    final rawCache = preferences.getString(_cacheKey);
    if (rawCache != null) {
      try {
        final cache = _decodeObject(rawCache, 'cached course');
        final manifestText =
            _requiredString(cache['manifestText'], 'manifestText');
        final levelData = _mapList(cache['levels'], 'cached levels');
        return _parseContent(
          manifestText: manifestText,
          levelData: levelData,
          languageCode: languageCode,
          isOffline: true,
        );
      } on FormatException catch (cacheError) {
        debugPrint('Cached Arabic course is invalid: $cacheError');
      }
    }
    final legacyCache = preferences.getString(_legacyCacheKey);
    if (legacyCache != null) {
      try {
        final cache = _decodeObject(legacyCache, 'cached Basic course');
        return _parseContent(
          manifestText: json.encode(_legacyManifest),
          levelData: [
            {
              'levelId': 'basic',
              'lessonTexts': _stringList(cache['lessonTexts'], 'lessonTexts'),
              'quizText': _requiredString(cache['quizText'], 'quizText'),
            },
          ],
          languageCode: languageCode,
          isOffline: true,
        );
      } on FormatException catch (cacheError) {
        debugPrint('Cached Arabic Basic course is invalid: $cacheError');
      }
    }
    throw ArabicCourseLoadException(
      'Arabic lessons could not be loaded. Check your connection and try again.',
      cause,
    );
  }

  static const _legacyManifest = {
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
      },
    ],
  };

  ArabicCourseContent _parseContent({
    required String manifestText,
    required List<Map<String, dynamic>> levelData,
    required String languageCode,
    bool isOffline = false,
  }) {
    final manifest = _decodeObject(manifestText, 'course manifest');
    if (manifest['courseId'] != 'arabic') {
      throw const FormatException('Unexpected Arabic course manifest.');
    }
    final rawLevels = manifest['levels'];
    if (rawLevels is! List || rawLevels.isEmpty) {
      throw const FormatException('Arabic manifest has no levels.');
    }
    final cachedLevels = <String, Map<String, dynamic>>{};
    for (final level in levelData) {
      final id = _requiredString(level['levelId'], 'cached level id');
      if (cachedLevels.containsKey(id)) {
        throw FormatException('Duplicate cached Arabic level "$id".');
      }
      cachedLevels[id] = level;
    }
    final levels = <ArabicCourseLevel>[];
    final levelIds = <String>{};
    for (final rawLevel in rawLevels) {
      if (rawLevel is! Map<String, dynamic>) {
        throw const FormatException('Arabic manifest has an invalid level.');
      }
      final id = _requiredString(rawLevel['id'], 'level id');
      if (!levelIds.add(id)) {
        throw FormatException('Duplicate Arabic level "$id".');
      }
      final cached = cachedLevels.remove(id);
      if (cached == null) {
        throw FormatException('Arabic level "$id" is missing cached content.');
      }
      final lessonTexts = _stringList(cached['lessonTexts'], 'lessonTexts');
      final quizText = _requiredString(cached['quizText'], 'quizText');
      levels.add(_parseLevel(
        metadata: rawLevel,
        lessonTexts: lessonTexts,
        quizText: quizText,
        languageCode: languageCode,
      ));
    }
    if (cachedLevels.isNotEmpty) {
      throw const FormatException('Cached Arabic content has unknown levels.');
    }
    levels.sort((a, b) => a.order.compareTo(b.order));
    if (levels.asMap().entries.any(
          (entry) => entry.value.order != entry.key + 1,
        )) {
      throw const FormatException('Arabic course level order is invalid.');
    }
    final lessonIds = levels.expand((level) => level.lessons.map((l) => l.id));
    if (lessonIds.toSet().length != lessonIds.length) {
      throw const FormatException('Arabic course has duplicate lesson IDs.');
    }
    return ArabicCourseContent(
      levels: List.unmodifiable(levels),
      isOffline: isOffline,
    );
  }

  ArabicCourseLevel _parseLevel({
    required Map<String, dynamic> metadata,
    required List<String> lessonTexts,
    required String quizText,
    required String languageCode,
  }) {
    final levelId = _requiredString(metadata['id'], 'level id');
    final quizFile = _decodeObject(quizText, 'quiz file');
    if (quizFile['courseId'] != 'arabic' || quizFile['levelId'] != levelId) {
      throw FormatException('Unexpected Arabic quiz file for "$levelId".');
    }
    if (quizFile['questionType'] != 'listen_and_choose') {
      throw const FormatException('Unsupported Arabic lesson quiz type.');
    }
    final prompt = _localized(
      quizFile['prompts'],
      languageCode,
      'quiz prompt',
    );
    final quizRows = quizFile['lessons'];
    if (quizRows is! List) {
      throw const FormatException('Arabic quiz file has no lesson list.');
    }
    final quizzes = <String, int>{};
    for (final row in quizRows) {
      if (row is! Map<String, dynamic>) {
        throw const FormatException('Arabic quiz file has an invalid lesson.');
      }
      final lessonId = _requiredString(row['lessonId'], 'lessonId');
      final count = row['questionCount'];
      if (count is! int || count < 2 || quizzes.containsKey(lessonId)) {
        throw FormatException('Arabic quiz "$lessonId" is invalid.');
      }
      quizzes[lessonId] = count;
    }

    final lessons = <ArabicCourseLesson>[];
    for (final text in lessonTexts) {
      final lessonFile = _decodeObject(text, 'lesson file');
      if (lessonFile['courseId'] != 'arabic' ||
          lessonFile['levelId'] != levelId) {
        throw FormatException('Unexpected Arabic lesson file for "$levelId".');
      }
      final rows = lessonFile['lessons'];
      if (rows is! List) {
        throw const FormatException('Arabic lesson file has no lesson list.');
      }
      for (final row in rows) {
        if (row is! Map<String, dynamic>) {
          throw const FormatException('Arabic lesson is not an object.');
        }
        final lessonId = _requiredString(row['id'], 'lesson id');
        final itemRows = row['items'];
        if (itemRows is! List || itemRows.length < 2) {
          throw FormatException('Arabic lesson "$lessonId" needs two items.');
        }
        final questionCount = quizzes.remove(lessonId);
        if (questionCount == null || questionCount > itemRows.length) {
          throw FormatException('Arabic lesson "$lessonId" has no valid quiz.');
        }
        final items = itemRows.map((item) {
          if (item is! Map<String, dynamic>) {
            throw FormatException(
                'Arabic lesson "$lessonId" has an invalid item.');
          }
          return _parseItem(item, languageCode);
        }).toList(growable: false);
        if (items.map((item) => item.id).toSet().length != items.length) {
          throw FormatException(
              'Arabic lesson "$lessonId" has duplicate items.');
        }
        final chart = <String, String>{};
        final rawChart = row['chart'];
        if (rawChart != null) {
          if (rawChart is! Map<String, dynamic>) {
            throw FormatException(
                'Arabic lesson "$lessonId" has an invalid chart.');
          }
          for (final entry in rawChart.entries) {
            chart[entry.key] = _requiredString(entry.value, 'chart field');
          }
        }
        lessons.add(
          ArabicCourseLesson(
            id: lessonId,
            order: _requiredInt(row['order'], 'lesson order'),
            title: _localized(row['title'], languageCode, 'lesson title'),
            objective:
                _localized(row['objective'], languageCode, 'lesson objective'),
            instruction: _localized(
              row['instruction'],
              languageCode,
              'lesson instruction',
            ),
            items: items,
            quizQuestionCount: questionCount,
            chart: Map.unmodifiable(chart),
          ),
        );
      }
    }
    if (lessons.isEmpty || quizzes.isNotEmpty) {
      throw FormatException(
        'Arabic lessons and quizzes do not match level "$levelId".',
      );
    }
    lessons.sort((a, b) => a.order.compareTo(b.order));
    if (lessons.map((lesson) => lesson.id).toSet().length != lessons.length ||
        lessons.asMap().entries.any(
              (entry) => entry.value.order != entry.key + 1,
            )) {
      throw FormatException('Arabic level "$levelId" lesson order is invalid.');
    }
    return ArabicCourseLevel(
      id: levelId,
      order: _requiredInt(metadata['order'], 'level order'),
      title: _localized(metadata['title'], languageCode, 'level title'),
      lessons: List.unmodifiable(lessons),
      quizPrompt: prompt,
    );
  }

  ArabicCourseItem _parseItem(
    Map<String, dynamic> json,
    String languageCode,
  ) {
    final audio = json['audio'];
    if (audio is! Map<String, dynamic>) {
      throw const FormatException('Arabic lesson item has no audio metadata.');
    }
    final audioPath = _requiredString(audio['path'], 'audio path');
    if (!audioPath.startsWith('audio/') ||
        audioPath.split('/').contains('..')) {
      throw FormatException('Invalid Arabic lesson audio path "$audioPath".');
    }
    final forms = <String, String>{};
    final rawForms = json['forms'];
    if (rawForms != null) {
      if (rawForms is! Map<String, dynamic>) {
        throw const FormatException('Arabic letter forms must be an object.');
      }
      for (final entry in rawForms.entries) {
        forms[entry.key] = _requiredString(entry.value, 'letter form');
      }
    }
    final example = json['example'];
    if (example != null && example is! Map<String, dynamic>) {
      throw const FormatException('Arabic example must be an object.');
    }
    final exampleMap = example as Map<String, dynamic>?;
    return ArabicCourseItem(
      id: _requiredString(json['id'], 'item id'),
      type: _requiredString(json['type'], 'item type'),
      arabic: _requiredString(json['arabic'], 'Arabic text'),
      transliteration:
          _requiredString(json['transliteration'], 'transliteration'),
      audioPath: audioPath,
      meaning: _localizedOptional(json['meaning'], languageCode),
      forms: Map.unmodifiable(forms),
      letterNameArabic: _optionalString(json['letterNameArabic']),
      exampleArabic: _optionalString(exampleMap?['arabic']),
      exampleTransliteration: _optionalString(exampleMap?['transliteration']),
      exampleMeaning: _localizedOptional(exampleMap?['meaning'], languageCode),
      note: _localizedOptional(json['note'], languageCode),
    );
  }

  Map<String, dynamic> _decodeObject(String text, String label) {
    final decoded = json.decode(text);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('Arabic $label must be a JSON object.');
    }
    return decoded;
  }

  String _localized(dynamic value, String languageCode, String label) {
    final result = _localizedOptional(value, languageCode);
    if (result == null || result.isEmpty) {
      throw FormatException('Arabic $label is missing.');
    }
    return result;
  }

  String? _localizedOptional(dynamic value, String languageCode) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Localized Arabic content has invalid type.');
    }
    final selected = value[languageCode];
    final fallback = value['en'];
    if (selected is String && selected.isNotEmpty) return selected;
    if (fallback is String && fallback.isNotEmpty) return fallback;
    return null;
  }

  String _requiredString(dynamic value, String label) {
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Arabic content is missing "$label".');
    }
    return value;
  }

  String? _optionalString(dynamic value) {
    if (value == null) return null;
    if (value is! String) {
      throw const FormatException('Optional Arabic text must be a string.');
    }
    return value;
  }

  int _requiredInt(dynamic value, String label) {
    if (value is! int) {
      throw FormatException('Arabic content has an invalid "$label".');
    }
    return value;
  }

  List<String> _stringList(dynamic value, String label) {
    if (value is! List || value.isEmpty) {
      throw FormatException('Arabic content has no "$label" list.');
    }
    return value.map((entry) => _requiredString(entry, label)).toList();
  }

  List<Map<String, dynamic>> _mapList(dynamic value, String label) {
    if (value is! List ||
        value.isEmpty ||
        value.any((entry) => entry is! Map<String, dynamic>)) {
      throw FormatException('Arabic content has no valid "$label" list.');
    }
    return value.cast<Map<String, dynamic>>();
  }
}

class ArabicCourseLoadException implements Exception {
  const ArabicCourseLoadException(this.message, this.cause);

  final String message;
  final Object cause;

  @override
  String toString() => '$message ($cause)';
}

class ArabicCourseProgress {
  const ArabicCourseProgress({
    required this.completedLessonIds,
    required this.points,
    required this.hearts,
    this.pendingHeartSpendIds = const {},
  });

  static const dailyHeartLimit = 5;

  final Set<String> completedLessonIds;
  final int points;
  final int hearts;
  final Set<String> pendingHeartSpendIds;

  int get unlockedLessonCount => completedLessonIds.length + 1;

  Map<String, dynamic> toSyncJson(String heartDate) => {
        'completed_lesson_ids': completedLessonIds.toList()..sort(),
        'hearts': hearts,
        'heart_date': heartDate,
        'heart_spend_ids': pendingHeartSpendIds.toList()..sort(),
      };
}

class ArabicCourseProgressService {
  static const _progressKey = 'arabic_basic_progress_v1';

  String _today() {
    final now = DateTime.now().toUtc();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  Future<ArabicCourseProgress> load() async {
    final preferences = await SharedPreferences.getInstance();
    final today = _today();
    final rawProgress = preferences.getString(_progressKey);
    var completed = <String>{};
    var points = 0;
    var hearts = ArabicCourseProgress.dailyHeartLimit;
    var savedDate = today;
    var pendingHeartSpendIds = <String>{};
    if (rawProgress != null) {
      final decoded = json.decode(rawProgress);
      if (decoded is! Map<String, dynamic> ||
          decoded['completedLessonIds'] is! List ||
          decoded['points'] is! int ||
          decoded['hearts'] is! int ||
          decoded['heartDate'] is! String) {
        throw const FormatException(
            'Saved Arabic learning progress is invalid.');
      }
      final rawCompleted = decoded['completedLessonIds'] as List;
      if (rawCompleted.any((entry) => entry is! String)) {
        throw const FormatException('Saved Arabic lesson progress is invalid.');
      }
      completed = rawCompleted.cast<String>().toSet();
      points = decoded['points'] as int;
      hearts = decoded['hearts'] as int;
      savedDate = decoded['heartDate'] as String;
      final rawPending = decoded['pendingHeartSpendIds'] ?? const [];
      if (rawPending is! List ||
          rawPending.any((spendId) => spendId is! String || spendId.isEmpty) ||
          rawPending.length > ArabicCourseProgress.dailyHeartLimit) {
        throw const FormatException('Saved Arabic heart spends are invalid.');
      }
      pendingHeartSpendIds = rawPending.cast<String>().toSet();
    }
    if (savedDate != today) {
      hearts = ArabicCourseProgress.dailyHeartLimit;
      pendingHeartSpendIds = {};
    }
    if (hearts < 0 ||
        hearts > ArabicCourseProgress.dailyHeartLimit ||
        points < 0) {
      throw const FormatException(
          'Saved Arabic learning progress is out of range.');
    }
    if (rawProgress == null || savedDate != today) {
      await _save(
        preferences,
        completed: completed,
        points: points,
        hearts: hearts,
        heartDate: today,
        pendingHeartSpendIds: pendingHeartSpendIds,
      );
    }
    return ArabicCourseProgress(
      completedLessonIds: completed,
      points: points,
      hearts: hearts,
      pendingHeartSpendIds: pendingHeartSpendIds,
    );
  }

  Future<ArabicCourseProgress> useHeart() async {
    final progress = await load();
    if (progress.hearts == 0) return progress;
    final preferences = await SharedPreferences.getInstance();
    final hearts = progress.hearts - 1;
    final pendingHeartSpendIds = {
      ...progress.pendingHeartSpendIds,
      _newHeartSpendId(),
    };
    await _save(
      preferences,
      completed: progress.completedLessonIds,
      points: progress.points,
      hearts: hearts,
      heartDate: _today(),
      pendingHeartSpendIds: pendingHeartSpendIds,
    );
    return ArabicCourseProgress(
      completedLessonIds: progress.completedLessonIds,
      points: progress.points,
      hearts: hearts,
      pendingHeartSpendIds: pendingHeartSpendIds,
    );
  }

  Future<ArabicCourseProgress> completeLesson(String lessonId) async {
    final progress = await load();
    if (progress.completedLessonIds.contains(lessonId)) return progress;
    final preferences = await SharedPreferences.getInstance();
    final completed = {...progress.completedLessonIds, lessonId};
    final points = progress.points + 20;
    await _save(
      preferences,
      completed: completed,
      points: points,
      hearts: progress.hearts,
      heartDate: _today(),
      pendingHeartSpendIds: progress.pendingHeartSpendIds,
    );
    return ArabicCourseProgress(
      completedLessonIds: completed,
      points: points,
      hearts: progress.hearts,
      pendingHeartSpendIds: progress.pendingHeartSpendIds,
    );
  }

  String _newHeartSpendId() {
    final random = Random.secure();
    return '${DateTime.now().toUtc().microsecondsSinceEpoch}-'
        '${random.nextInt(1 << 32).toRadixString(16)}';
  }

  Future<ArabicCourseProgress> mergeServerProgress(
    Map<String, dynamic> serverProgress, {
    Set<String> syncedHeartSpendIds = const {},
  }) async {
    final rawCompleted = serverProgress['completed_lesson_ids'];
    final hearts = serverProgress['hearts'];
    final heartDate = serverProgress['heart_date'];
    if (rawCompleted is! List ||
        rawCompleted.any((lessonId) => lessonId is! String) ||
        hearts is! int ||
        hearts < 0 ||
        hearts > ArabicCourseProgress.dailyHeartLimit ||
        heartDate is! String) {
      throw const FormatException('Server Arabic course progress is invalid.');
    }

    final local = await load();
    final completed = {
      ...local.completedLessonIds,
      ...rawCompleted.cast<String>(),
    };
    final pendingHeartSpendIds = {
      ...local.pendingHeartSpendIds,
    }..removeAll(syncedHeartSpendIds);
    final progressPoints = completed.length * 20;
    final mergedHearts =
        heartDate == _today() ? min(local.hearts, hearts) : local.hearts;
    await _save(
      await SharedPreferences.getInstance(),
      completed: completed,
      points: max(local.points, progressPoints),
      hearts: mergedHearts,
      heartDate: _today(),
      pendingHeartSpendIds: pendingHeartSpendIds,
    );
    return ArabicCourseProgress(
      completedLessonIds: completed,
      points: max(local.points, progressPoints),
      hearts: mergedHearts,
      pendingHeartSpendIds: pendingHeartSpendIds,
    );
  }

  Future<Map<String, dynamic>> toSyncJson() async {
    final progress = await load();
    return progress.toSyncJson(_today());
  }

  Future<void> _save(
    SharedPreferences preferences, {
    required Set<String> completed,
    required int points,
    required int hearts,
    required String heartDate,
    Set<String> pendingHeartSpendIds = const {},
  }) async {
    final saved = await preferences.setString(
      _progressKey,
      json.encode({
        'completedLessonIds': completed.toList()..sort(),
        'points': points,
        'hearts': hearts,
        'heartDate': heartDate,
        'pendingHeartSpendIds': pendingHeartSpendIds.toList()..sort(),
      }),
    );
    if (!saved) {
      throw StateError('Arabic learning progress could not be saved.');
    }
  }
}
