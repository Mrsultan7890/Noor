import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:noor/services/quran_audio_service.dart';

void main() {
  test('loads ayah text and audio URLs for the requested reciter', () async {
    final service = QuranAudioService(
      client: MockClient((request) async {
        expect(
          request.url.path,
          '/v1/surah/1/ar.alafasy',
        );
        return http.Response.bytes(
          utf8.encode(json.encode({
            'data': {
              'ayahs': [
                {
                  'numberInSurah': 1,
                  'text': 'بِسْمِ اللَّهِ',
                  'audio': 'https://cdn.islamic.network/audio/primary.mp3',
                  'audioSecondary': [
                    'https://cdn.islamic.network/audio/secondary.mp3'
                  ],
                },
                {
                  'numberInSurah': 2,
                  'text': 'الْحَمْدُ لِلَّهِ',
                  'audio': 'https://cdn.islamic.network/audio/second.mp3',
                },
              ],
            },
          })),
          200,
        );
      }),
    );

    final ayahs = await service.getSurahAyahs(1, 'ar.alafasy');

    expect(ayahs, hasLength(2));
    expect(ayahs.first.numberInSurah, 1);
    expect(ayahs.first.text, 'بِسْمِ اللَّهِ');
    expect(
      ayahs.first.audioUrl.path,
      '/audio/secondary.mp3',
    );
    expect(ayahs.last.audioUrl.path, '/audio/second.mp3');
    expect(() => ayahs.add(ayahs.first), throwsUnsupportedError);
  });

  test('rejects ayahs without readable text', () async {
    final service = QuranAudioService(
      client: MockClient((_) async => http.Response.bytes(
            utf8.encode(json.encode({
              'data': {
                'ayahs': [
                  {
                    'numberInSurah': 1,
                    'audio': 'https://cdn.islamic.network/audio/1.mp3',
                  }
                ],
              },
            })),
            200,
          )),
    );

    await expectLater(
      service.getSurahAyahs(1, 'ar.alafasy'),
      throwsFormatException,
    );
  });

  test('rejects invalid surah and unsupported reciter before requesting',
      () async {
    var requestCount = 0;
    final service = QuranAudioService(
      client: MockClient((_) async {
        requestCount++;
        return http.Response('{}', 200);
      }),
    );

    await expectLater(
      service.getSurahAyahs(0, 'ar.alafasy'),
      throwsArgumentError,
    );
    await expectLater(
      service.getSurahAyahs(1, 'unknown'),
      throwsArgumentError,
    );
    expect(requestCount, 0);
  });
}
