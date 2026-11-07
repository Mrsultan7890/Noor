import 'dart:math';

import 'package:http/http.dart' as http;
import '../models/hadith_model.dart';
import 'utf8_json.dart';

class HadithService {
  static const String baseUrl =
      'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1';
  static const int pageSize = 10;
  static const int _muslimFirstHadithNumber = 93;

  Future<List<Hadith>> getHadiths(String book, int page) async {
    if (page < 1) {
      throw ArgumentError.value(page, 'page', 'Must be greater than zero.');
    }

    final firstNumber = (page - 1) * pageSize +
        (book == 'muslim' ? _muslimFirstHadithNumber : 1);
    final hadiths = <Hadith>[];
    for (var index = 0; index < pageSize; index++) {
      final hadith = await _getHadith(book, firstNumber + index);
      if (hadith != null) hadiths.add(hadith);
    }
    return hadiths;
  }

  Future<Hadith?> _getHadith(String book, int number) async {
    final editions = await Future.wait([
      _getEditionHadith('ara', book, number),
      _getEditionHadith('eng', book, number),
      _getEditionHadith('urd', book, number),
    ]);

    String textAt(int index) {
      final hadiths = editions[index]?['hadiths'];
      if (hadiths is! List ||
          hadiths.isEmpty ||
          hadiths.first is! Map<String, dynamic>) {
        return '';
      }
      final text = (hadiths.first as Map<String, dynamic>)['text'];
      return text is String ? text : '';
    }

    final arabicText = textAt(0);
    final englishText = textAt(1);
    final urduText = textAt(2);
    if (arabicText.trim().isEmpty &&
        englishText.trim().isEmpty &&
        urduText.trim().isEmpty) {
      return null;
    }

    Map<String, dynamic>? metadata;
    for (final edition in editions) {
      final candidate = edition?['metadata'];
      if (candidate is Map<String, dynamic>) {
        metadata = candidate;
        break;
      }
    }

    return Hadith(
      book: metadata?['name'] is String ? metadata!['name'] as String : book,
      hadithNumber: number.toString(),
      arabicText: arabicText,
      englishText: englishText,
      urduText: urduText,
      narrator: '',
    );
  }

  Future<Map<String, dynamic>?> _getEditionHadith(
    String language,
    String book,
    int number,
  ) async {
    final edition = '$language-$book';
    Object? lastError;

    for (final suffix in ['json', 'min.json']) {
      final uri = Uri.parse('$baseUrl/editions/$edition/$number.$suffix');
      try {
        final response = await http
            .get(uri)
            .timeout(const Duration(seconds: 15));
        if (response.statusCode == 200) {
          final data = decodeUtf8JsonResponse(response);
          if (data is Map<String, dynamic> && data['hadiths'] is List) {
            return data;
          }
          throw const FormatException('Hadith API returned an invalid response.');
        }
        if (response.statusCode != 404) {
          lastError = 'HTTP ${response.statusCode}';
        }
      } catch (error) {
        lastError = error;
      }
    }

    if (lastError != null) {
      throw Exception('Failed to load $edition hadith $number: $lastError');
    }
    return null;
  }

  Future<Hadith> getRandomHadith() async {
    final page = Random().nextInt(10) + 1;
    final hadiths = await getHadiths('abudawud', page);
    if (hadiths.isEmpty) {
      throw StateError('No hadiths are available in Sunan Abu Dawud.');
    }
    return hadiths[Random().nextInt(hadiths.length)];
  }
}
