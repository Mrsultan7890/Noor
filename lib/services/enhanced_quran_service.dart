import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/word_by_word_model.dart';

class EnhancedQuranService {
  static const String _baseUrl = 'https://api.alquran.cloud/v1';
  static const String _quranComUrl = 'https://api.quran.com/api/v4';
  
  // Get transliteration for a surah
  Future<List<String>> getTransliteration(int surahNumber) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/surah/$surahNumber/en.transliteration'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final ayahs = data['data']['ayahs'] as List;
        return ayahs.map((ayah) => ayah['text'] as String).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
  
  // Get word-by-word translation for a verse
  Future<VerseWithWords?> getWordByWord(int surahNumber, int verseNumber) async {
    try {
      final response = await http.get(
        Uri.parse('$_quranComUrl/verses/by_key/$surahNumber:$verseNumber?words=true&translations=131&fields=text_uthmani'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return VerseWithWords.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Get audio URL for a verse (Abdul Basit - Murattal)
  String getAudioUrl(int surahNumber, int verseNumber) {
    final surahPadded = surahNumber.toString().padLeft(3, '0');
    final versePadded = verseNumber.toString().padLeft(3, '0');
    return 'https://everyayah.com/data/Abdul_Basit_Murattal_192kbps/$surahPadded$versePadded.mp3';
  }
  
  // Get slow recitation audio URL (Muhammad Jibreel)
  String getSlowAudioUrl(int surahNumber, int verseNumber) {
    final surahPadded = surahNumber.toString().padLeft(3, '0');
    final versePadded = verseNumber.toString().padLeft(3, '0');
    return 'https://everyayah.com/data/Muhammad_Jibreel_128kbps/$surahPadded$versePadded.mp3';
  }
}
