import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/hadith_model.dart';

class HadithService {
  static const String baseUrl = 'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1';

  Future<List<Hadith>> getHadiths(String book, int page) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/editions/ara-$book.json'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final hadiths = data['hadiths'] as List;
        
        final start = (page - 1) * 10;
        final end = start + 10;
        final pageHadiths = hadiths.sublist(
          start < hadiths.length ? start : 0,
          end < hadiths.length ? end : hadiths.length,
        );
        
        return pageHadiths.map((h) => Hadith(
          book: data['metadata']['name'] ?? book,
          hadithNumber: h['hadithnumber']?.toString() ?? '1',
          arabicText: h['text'] ?? '',
          englishText: h['text'] ?? '',
          narrator: '',
        )).toList();
      } else {
        throw Exception('Failed to load hadiths');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Hadith> getRandomHadith() async {
    try {
      final hadiths = await getHadiths('abudawud', 1);
      return hadiths.first;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
