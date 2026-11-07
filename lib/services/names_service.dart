import 'package:http/http.dart' as http;
import 'utf8_json.dart';

class NamesService {
  static const String baseUrl = 'https://api.aladhan.com/v1';

  Future<List<Map<String, String>>> get99Names() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/asmaAlHusna'));

      if (response.statusCode == 200) {
        final data = decodeUtf8JsonResponse(response);
        final List names = data['data'];
        return names.map((n) => {
          'number': n['number'].toString(),
          'name': n['name'] as String,
          'transliteration': n['transliteration'] as String,
          'meaning': n['en']['meaning'] as String,
        }).toList();
      } else {
        throw Exception('Failed to load names');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
