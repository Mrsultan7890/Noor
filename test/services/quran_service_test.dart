import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:noor/services/quran_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('loads all Mushaf pages from bundled Uthmani text without networking',
      () async {
    var requests = 0;
    final service = QuranService(
      client: MockClient((_) async {
        requests++;
        throw http.ClientException('offline');
      }),
    );

    final firstPage = await service.getPageAyahs(1);
    final lastPage = await service.getPageAyahs(604);
    final allPages = await Future.wait([
      for (var page = 1; page <= 604; page++) service.getPageAyahs(page),
    ]);

    expect(requests, 0);
    expect(allPages.expand((ayahs) => ayahs), hasLength(6236));
    expect(allPages.every((ayahs) => ayahs.isNotEmpty), isTrue);
    expect(firstPage.first.surahNumber, 1);
    expect(firstPage.first.verseNumber, 1);
    expect(
      firstPage.first.text,
      'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
    );
    expect(lastPage.last.surahNumber, 114);
    expect(lastPage.last.verseNumber, 6);
  });

  test('loads the surah list online', () async {
    final service = QuranService(
      client: MockClient((request) async {
        expect(request.url.path, '/v1/surah');
        return http.Response(
          jsonEncode({
            'data': [
              {
                'number': 1,
                'name': 'الفاتحة',
                'englishName': 'Al-Faatiha',
                'englishNameTranslation': 'The Opening',
                'numberOfAyahs': 7,
                'revelationType': 'Meccan',
              },
            ],
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );

    final surahs = await service.getSurahs();

    expect(surahs, hasLength(1));
    expect(surahs.first.name, 'الفاتحة');
    expect(surahs.first.numberOfAyahs, 7);
  });

  test('loads online Arabic verses and translations for surah reading',
      () async {
    final service = QuranService(
      client: MockClient((request) async {
        if (request.url.path == '/v1/surah/1') {
          return http.Response(
            jsonEncode({
              'data': {
                'ayahs': [
                  for (var index = 0; index < 7; index++)
                    {
                      'numberInSurah': index + 1,
                      'text': 'آن لائن عربی $index',
                    },
                ],
              },
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        expect(request.url.path, '/v1/surah/1/ur.jalandhry');
        return http.Response(
          jsonEncode({
            'data': {
              'ayahs': [
                for (var index = 0; index < 7; index++)
                  {'text': 'ترجمہ $index'},
              ],
            },
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );

    final verses = await service.getVerses(1);

    expect(verses, hasLength(7));
    expect(verses.first.text, 'آن لائن عربی 0');
    expect(verses.first.translation, 'ترجمہ 0');
  });

  test('rejects invalid Mushaf page numbers', () async {
    final service = QuranService();

    await expectLater(service.getPageAyahs(0), throwsRangeError);
    await expectLater(service.getPageAyahs(605), throwsRangeError);
  });
}
