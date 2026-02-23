import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quran_model.dart';

class QuranService {
  static const String baseUrl = 'https://api.alquran.cloud/v1';
  
  Future<List<Surah>> getSurahs() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/surah'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List surahs = data['data'];
        return surahs.map((surah) => Surah.fromJson(surah)).toList();
      } else {
        throw Exception('Failed to load Surahs');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  Future<List<Verse>> getVerses(int surahNumber) async {
    try {
      // Get user's selected language edition
      final prefs = await SharedPreferences.getInstance();
      final edition = prefs.getString('quran_edition') ?? 'ur.jalandhry';
      
      // Get Arabic text
      final arabicResponse = await http.get(
        Uri.parse('$baseUrl/surah/$surahNumber')
      );
      
      // Get translation in user's language
      final translationResponse = await http.get(
        Uri.parse('$baseUrl/surah/$surahNumber/$edition')
      );
      
      if (arabicResponse.statusCode == 200 && translationResponse.statusCode == 200) {
        final arabicData = json.decode(arabicResponse.body);
        final translationData = json.decode(translationResponse.body);
        
        final List arabicAyahs = arabicData['data']['ayahs'];
        final List translationAyahs = translationData['data']['ayahs'];
        
        List<Verse> verses = [];
        for (int i = 0; i < arabicAyahs.length; i++) {
          verses.add(Verse(
            number: arabicAyahs[i]['numberInSurah'],
            text: arabicAyahs[i]['text'],
            translation: translationAyahs[i]['text'],
            surahNumber: surahNumber,
          ));
        }
        
        return verses;
      } else {
        throw Exception('Failed to load verses');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
