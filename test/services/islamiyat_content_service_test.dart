import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:noor/services/islamiyat_content_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const article = {
    'id': 'example',
    'title': {'en': 'Example topic', 'ur': 'مثالی موضوع'},
    'question': {'en': 'What is the question?', 'ur': 'سوال کیا ہے؟'},
    'answer': {'en': 'An answer.', 'ur': 'ایک جواب۔'},
    'tags': ['example', 'searchable'],
    'sources': [
      {
        'type': 'Book',
        'title': 'Example source',
        'author': 'Example author',
        'reference': 'Edition 1, page 2',
        'quote': 'A short quotation.',
        'url': 'https://example.org/reference',
      }
    ],
  };

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('fetches and caches the Islamiyat catalog from GitHub', () async {
    final service = IslamiyatContentService(
      client: MockClient((request) async {
        expect(request.url.host, 'raw.githubusercontent.com');
        expect(
          request.url.path,
          '/Mrsultan7890/noor/main/data/islamiyat.json',
        );
        return http.Response.bytes(
          utf8.encode(json.encode({
            'version': 1,
            'items': [article]
          })),
          200,
        );
      }),
    );

    final result = await service.load();

    expect(result.isOffline, isFalse);
    expect(result.articles.single.id, 'example');
    expect(result.articles.single.sources.single.url.toString(),
        'https://example.org/reference');
    expect(
      (await SharedPreferences.getInstance())
          .getString('published_islamiyat_catalog_v1'),
      isNotNull,
    );
  });

  test('fetches the latest catalog on each section opening', () async {
    var requestCount = 0;
    final service = IslamiyatContentService(
      client: MockClient((_) async {
        requestCount++;
        return http.Response.bytes(
          utf8.encode(json.encode({
            'version': 1,
            'items': [article]
          })),
          200,
        );
      }),
    );

    await service.load();
    await service.load();

    expect(requestCount, 2);
  });

  test('uses the last saved catalog when GitHub is unreachable', () async {
    final online = IslamiyatContentService(
      client: MockClient((_) async => http.Response.bytes(
            utf8.encode(json.encode({
              'version': 1,
              'items': [article]
            })),
            200,
          )),
    );
    await online.load();

    final offline = IslamiyatContentService(
      client: MockClient((_) async => throw http.ClientException('offline')),
    );
    final result = await offline.load();

    expect(result.isOffline, isTrue);
    expect(result.articles.single.id, 'example');
  });

  test('rejects articles without source references', () async {
    final invalidArticle = Map<String, Object?>.from(article)
      ..['sources'] = [
        {'type': 'Book', 'title': 'Unreferenced source'}
      ];
    final service = IslamiyatContentService(
      client: MockClient((_) async => http.Response.bytes(
            utf8.encode(json.encode({
              'version': 1,
              'items': [invalidArticle],
            })),
            200,
          )),
    );

    await expectLater(
      service.load(),
      throwsA(isA<IslamiyatContentLoadException>()),
    );
  });
}
