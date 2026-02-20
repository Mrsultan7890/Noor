import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/hadith_model.dart';

class HadithService {
  static const String baseUrl = 'https://random-hadith-generator.vercel.app';

  Future<List<Hadith>> getHadiths(String book, int page) async {
    try {
      final List<Hadith> hadiths = [];
      for (int i = 0; i < 10; i++) {
        final hadith = await getRandomHadith();
        hadiths.add(hadith);
      }
      return hadiths;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Hadith> getRandomHadith() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/bukhari/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Hadith(
          book: 'Sahih Bukhari',
          hadithNumber: data['data']['hadithNumber']?.toString() ?? '1',
          arabicText: data['data']['hadithArabic'] ?? '',
          englishText: data['data']['hadithEnglish'] ?? '',
          narrator: data['data']['hadithNarrator'] ?? '',
        );
      } else {
        throw Exception('Failed to load hadith');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
