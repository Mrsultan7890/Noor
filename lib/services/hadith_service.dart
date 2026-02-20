import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/hadith_model.dart';

class HadithService {
  static const String baseUrl = 'https://hadis-api-id.vercel.app/hadith';

  Future<List<Hadith>> getHadiths(String book, int page) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$book?page=$page&limit=10'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List items = data['items'] ?? [];
        return items.map((h) => Hadith(
          book: book,
          hadithNumber: h['number']?.toString() ?? '1',
          arabicText: h['arab'] ?? '',
          englishText: h['id'] ?? '',
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
      final books = ['bukhari', 'muslim', 'abu-dawud'];
      final randomBook = books[DateTime.now().millisecond % books.length];
      final hadiths = await getHadiths(randomBook, 1);
      return hadiths.first;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
