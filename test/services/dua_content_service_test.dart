import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:noor/services/dua_content_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const dua = {
    'id': 'morning-test',
    'title': 'Morning test dua',
    'title_ur': 'صبح کی دعا',
    'arabic': 'اللَّهُمَّ',
    'transliteration': 'Allahumma',
    'translation': 'O Allah.',
    'translation_ur': 'اے اللہ۔',
    'category': 'Morning',
    'source': 'Test reference',
    'repeat': '1 time',
  };

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('loads and caches the published dua catalog', () async {
    final service = DuaContentService(
      client: MockClient((request) async {
        expect(request.url.host, 'raw.githubusercontent.com');
        expect(request.url.path, '/Mrsultan7890/noor/main/data/duas.json');
        return http.Response(
          json.encode({
            'version': 'v1',
            'items': [dua]
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );

    final result = await service.load();

    expect(result.isOffline, isFalse);
    expect(result.items.single.id, 'morning-test');
    expect(result.items.single.toScreenMap()['titleUrdu'], 'صبح کی دعا');
  });

  test('uses the cached catalog when the network is unavailable', () async {
    final online = DuaContentService(
      client: MockClient(
        (_) async => http.Response.bytes(
          utf8.encode(
            json.encode({
              'version': 'v1',
              'items': [dua]
            }),
          ),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        ),
      ),
    );
    await online.load();

    final offline = DuaContentService(
      client: MockClient((_) async {
        throw http.ClientException('offline');
      }),
    );

    final result = await offline.load(forceRefresh: true);

    expect(result.isOffline, isTrue);
    expect(result.items.single.id, 'morning-test');
  });

  test('uses fresh cache until force refresh is requested', () async {
    var requestCount = 0;
    final service = DuaContentService(
      client: MockClient((_) async {
        requestCount++;
        return http.Response(
          json.encode({
            'version': 'v1',
            'items': [dua]
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );

    await service.load();
    await service.load();
    expect(requestCount, 1);

    await service.load(forceRefresh: true);
    expect(requestCount, 2);
  });
}
