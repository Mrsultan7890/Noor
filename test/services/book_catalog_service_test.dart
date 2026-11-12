import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:noor/services/book_catalog_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> _catalogJson() => rootBundle.loadString('data/books.json');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const catalogUri = 'https://example.test/books.json';

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('fetches and caches the GitHub catalog', () async {
    final responseJson = await _catalogJson();
    var requestCount = 0;
    final service = BookCatalogService(
      catalogUri: Uri.parse(catalogUri),
      client: MockClient((request) async {
        requestCount++;
        expect(request.url.toString(), catalogUri);
        return http.Response.bytes(utf8.encode(responseJson), 200);
      }),
    );

    final firstLoad = await service.load();
    final secondLoad = await service.load();

    expect(firstLoad.books, hasLength(12));
    expect(firstLoad.isOffline, isFalse);
    expect(secondLoad.isOffline, isFalse);
    expect(requestCount, 1);
  });

  test('uses the cached catalog when refresh fails', () async {
    final responseJson = await _catalogJson();
    final onlineService = BookCatalogService(
      catalogUri: Uri.parse(catalogUri),
      client: MockClient(
        (_) async => http.Response.bytes(utf8.encode(responseJson), 200),
      ),
    );
    await onlineService.load();

    final offlineService = BookCatalogService(
      catalogUri: Uri.parse(catalogUri),
      client: MockClient((_) async => http.Response('unavailable', 503)),
    );
    final catalog = await offlineService.load(forceRefresh: true);

    expect(catalog.books, hasLength(12));
    expect(catalog.isOffline, isTrue);
  });

  test('uses the bundled catalog when the network is unavailable', () async {
    final service = BookCatalogService(
      catalogUri: Uri.parse(catalogUri),
      client: MockClient((_) async => http.Response('unavailable', 503)),
    );

    final catalog = await service.load(forceRefresh: true);

    expect(catalog.books, hasLength(12));
    expect(catalog.isOffline, isTrue);
  });
}
