import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/quran_model.dart';
import 'utf8_json.dart';

class QuranService {
  QuranService({http.Client? client}) : _client = client;

  static const String baseUrl = 'https://api.alquran.cloud/v1';
  static const String _assetPath = 'assets/data/quran-uthmani.json';

  static Future<Map<String, dynamic>>? _dataFuture;
  static Future<Map<int, List<QuranPageAyah>>>? _pagesFuture;

  final http.Client? _client;

  Future<http.Response> _get(Uri uri) {
    return (_client?.get(uri) ?? http.get(uri))
        .timeout(const Duration(seconds: 8));
  }

  Future<Map<String, dynamic>> _loadData() {
    return _dataFuture ??= rootBundle.loadString(_assetPath).then((text) {
      final decoded = json.decode(text);
      if (decoded is! Map<String, dynamic> ||
          decoded['source'] != 'Tanzil Project' ||
          decoded['textVersion'] != 'Uthmani 1.1' ||
          decoded['surahs'] is! List ||
          (decoded['surahs'] as List).length != 114) {
        throw const FormatException('The bundled Quran data is invalid.');
      }
      return decoded;
    });
  }

  Future<List<Surah>> getSurahs() async {
    final response = await _get(Uri.parse('$baseUrl/surah'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load Surahs (HTTP ${response.statusCode}).');
    }

    final decoded = decodeUtf8JsonResponse(response);
    final rawSurahs = decoded['data'];
    if (rawSurahs is! List) {
      throw const FormatException('The Quran service returned invalid surahs.');
    }
    return List.unmodifiable(rawSurahs.map((surah) {
      if (surah is! Map<String, dynamic>) {
        throw const FormatException(
          'The Quran service returned an invalid surah.',
        );
      }
      return Surah.fromJson(surah);
    }));
  }

  Future<List<Verse>> getVerses(int surahNumber) async {
    if (surahNumber < 1 || surahNumber > 114) {
      throw RangeError.range(surahNumber, 1, 114, 'surahNumber');
    }

    final preferences = await SharedPreferences.getInstance();
    final edition = preferences.getString('quran_edition') ?? 'ur.jalandhry';
    final responses = await Future.wait([
      _get(Uri.parse('$baseUrl/surah/$surahNumber')),
      _get(Uri.parse('$baseUrl/surah/$surahNumber/$edition')),
    ]);
    if (responses.any((response) => response.statusCode != 200)) {
      throw Exception(
        'Failed to load Quran verses (HTTP '
        '${responses.firstWhere((response) => response.statusCode != 200).statusCode}).',
      );
    }

    final arabicData = decodeUtf8JsonResponse(responses[0]);
    final translationData = decodeUtf8JsonResponse(responses[1]);
    final arabicPayload = arabicData['data'];
    final translationPayload = translationData['data'];
    if (arabicPayload is! Map<String, dynamic> ||
        translationPayload is! Map<String, dynamic>) {
      throw const FormatException(
        'The Quran service returned invalid verse data.',
      );
    }
    final arabicAyahs = arabicPayload['ayahs'];
    final translationAyahs = translationPayload['ayahs'];
    if (arabicAyahs is! List ||
        translationAyahs is! List ||
        arabicAyahs.length != translationAyahs.length) {
      throw const FormatException(
        'The Quran service returned incomplete verse data.',
      );
    }

    return List.unmodifiable([
      for (var index = 0; index < arabicAyahs.length; index++)
        if (arabicAyahs[index] is Map<String, dynamic> &&
            translationAyahs[index] is Map<String, dynamic> &&
            arabicAyahs[index]['numberInSurah'] is int &&
            arabicAyahs[index]['text'] is String &&
            translationAyahs[index]['text'] is String)
          Verse(
            number: arabicAyahs[index]['numberInSurah'] as int,
            text: arabicAyahs[index]['text'] as String,
            translation: translationAyahs[index]['text'] as String,
            surahNumber: surahNumber,
          )
        else
          throw const FormatException(
            'The Quran service returned an invalid verse.',
          ),
    ]);
  }

  Future<List<QuranPageAyah>> getPageAyahs(int pageNumber) async {
    if (pageNumber < 1 || pageNumber > 604) {
      throw RangeError.range(pageNumber, 1, 604, 'pageNumber');
    }
    final pages = await (_pagesFuture ??= _buildPages());
    return pages[pageNumber]!;
  }

  Future<Map<int, List<QuranPageAyah>>> _buildPages() async {
    final data = await _loadData();
    final result = <int, List<QuranPageAyah>>{
      for (var page = 1; page <= 604; page++) page: <QuranPageAyah>[],
    };
    final surahs = data['surahs'] as List;
    for (final rawSurah in surahs) {
      if (rawSurah is! Map<String, dynamic> || rawSurah['ayahs'] is! List) {
        throw const FormatException('The bundled Quran has invalid surahs.');
      }
      final surahNumber = _requiredInt(rawSurah['number'], 'surah number');
      final surahName = _requiredString(rawSurah['name'], 'surah name');
      final bismillah = rawSurah['bismillah'];
      if (bismillah != null && bismillah is! String) {
        throw const FormatException('The bundled Quran has invalid basmala.');
      }
      for (final rawAyah in rawSurah['ayahs'] as List) {
        if (rawAyah is! Map<String, dynamic>) {
          throw const FormatException('The bundled Quran has invalid ayahs.');
        }
        final page = _requiredInt(rawAyah['page'], 'page number');
        if (page < 1 || page > 604) {
          throw const FormatException('The bundled Quran has invalid pages.');
        }
        result[page]!.add(
          QuranPageAyah(
            surahNumber: surahNumber,
            surahName: surahName,
            verseNumber: _requiredInt(rawAyah['number'], 'ayah number'),
            text: _requiredString(rawAyah['text'], 'ayah text'),
            bismillah: bismillah as String?,
          ),
        );
      }
    }
    if (result.values.any((ayahs) => ayahs.isEmpty)) {
      throw const FormatException('The bundled Quran has an empty page.');
    }
    return {
      for (final entry in result.entries)
        entry.key: List.unmodifiable(entry.value),
    };
  }

  int _requiredInt(dynamic value, String label) {
    if (value is! int) {
      throw FormatException('The bundled Quran has an invalid $label.');
    }
    return value;
  }

  String _requiredString(dynamic value, String label) {
    if (value is! String || value.isEmpty) {
      throw FormatException('The bundled Quran has an invalid $label.');
    }
    return value;
  }
}

class QuranPageAyah {
  const QuranPageAyah({
    required this.surahNumber,
    required this.surahName,
    required this.verseNumber,
    required this.text,
    required this.bismillah,
  });

  final int surahNumber;
  final String surahName;
  final int verseNumber;
  final String text;
  final String? bismillah;
}
