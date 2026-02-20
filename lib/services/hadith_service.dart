import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/hadith_model.dart';

class HadithService {
  static const String baseUrl = 'https://hadithapi.com/api';

  Future<List<Hadith>> getHadiths(String book, int page) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$book/chapters/1/hadiths?page=$page'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List hadiths = data['hadiths']['data'];
        return hadiths.map((h) => Hadith.fromJson(h)).toList();
      } else {
        throw Exception('Failed to load hadiths');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Hadith> getRandomHadith() async {
    try {
      final books = ['bukhari', 'muslim', 'abudawud'];
      final randomBook = books[DateTime.now().millisecond % books.length];
      final hadiths = await getHadiths(randomBook, 1);
      return hadiths.first;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
