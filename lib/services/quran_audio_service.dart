import 'package:http/http.dart' as http;
import 'utf8_json.dart';

class QuranAudioService {
  static const String _baseUrl = 'https://api.alquran.cloud/v1';
  static const Set<String> supportedReciters = {
    'ar.abdulbasitmurattal',
    'ar.abdullahbasfar',
    'ar.abdurrahmaansudais',
    'ar.alafasy',
    'ar.husary',
    'ar.minshawi',
  };

  Future<List<Uri>> getSurahAudioUrls(int surahNumber, String reciter) async {
    if (surahNumber < 1 || surahNumber > 114) {
      throw ArgumentError.value(surahNumber, 'surahNumber');
    }
    if (!supportedReciters.contains(reciter)) {
      throw ArgumentError.value(reciter, 'reciter', 'Unsupported reciter.');
    }

    final response = await http
        .get(Uri.parse('$_baseUrl/surah/$surahNumber/$reciter'))
        .timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw Exception(
        'Could not load recitation audio (HTTP ${response.statusCode}).',
      );
    }

    final payload = decodeUtf8JsonResponse(response);
    final data = payload['data'];
    final ayahs = data is Map<String, dynamic> ? data['ayahs'] : null;
    if (ayahs is! List || ayahs.isEmpty) {
      throw const FormatException('Recitation response contains no ayahs.');
    }

    return ayahs.map((ayah) {
      if (ayah is! Map<String, dynamic>) {
        throw const FormatException('Recitation response contains an invalid ayah.');
      }

      final alternatives = ayah['audioSecondary'];
      final audioUrl = alternatives is List && alternatives.isNotEmpty
          ? alternatives.first
          : ayah['audio'];
      if (audioUrl is! String) {
        throw const FormatException('Recitation response is missing an audio URL.');
      }

      final uri = Uri.tryParse(audioUrl);
      if (uri == null ||
          uri.scheme != 'https' ||
          uri.host != 'cdn.islamic.network') {
        throw const FormatException('Recitation response has an invalid audio URL.');
      }
      return uri;
    }).toList();
  }
}
