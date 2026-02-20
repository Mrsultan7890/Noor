import 'dart:convert';
import 'package:http/http.dart' as http;

class PrayerTimesService {
  static const String baseUrl = 'https://api.aladhan.com/v1';
  
  Future<Map<String, String>> getPrayerTimes(double latitude, double longitude) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/timings?latitude=$latitude&longitude=$longitude&method=2'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timings = data['data']['timings'];
        
        return {
          'Fajr': timings['Fajr'],
          'Dhuhr': timings['Dhuhr'],
          'Asr': timings['Asr'],
          'Maghrib': timings['Maghrib'],
          'Isha': timings['Isha'],
        };
      } else {
        throw Exception('Failed to load prayer times');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
