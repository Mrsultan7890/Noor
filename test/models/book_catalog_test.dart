import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor/models/book_catalog.dart';

Future<Map<String, dynamic>> _loadCatalogJson() async {
  return json.decode(await rootBundle.loadString('data/books.json'))
      as Map<String, dynamic>;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('parses all books, categories, and volume links in the catalog',
      () async {
    final catalog = BookCatalog.fromJson(await _loadCatalogJson());

    expect(catalog.categories, hasLength(7));
    expect(catalog.books, hasLength(12));
    expect(
      catalog.books.fold<int>(0, (total, book) => total + book.volumes.length),
      21,
    );
    expect(
      catalog.books.every((book) => book.archiveUrl.host == 'archive.org'),
      isTrue,
    );
  });

  test('searches by book title, author, description, and category', () async {
    final catalog = BookCatalog.fromJson(await _loadCatalogJson());

    expect(catalog.search(query: 'MUFTI MUHAMMAD SHAFI'), hasLength(1));
    expect(catalog.search(query: 'self-purification'), hasLength(1));
    expect(
      catalog.search(categoryId: 'seerah-sahabah'),
      hasLength(2),
    );
    expect(catalog.search(query: 'no such book'), isEmpty);
  });

  test('rejects download links outside the matching Internet Archive item',
      () async {
    final json = await _loadCatalogJson();
    final books = (json['books'] as List)
        .map((book) => Map<String, dynamic>.from(book as Map))
        .toList();
    final firstBook = books.first;
    firstBook['volumes'] = [
      Map<String, dynamic>.from(firstBook['volumes'].first as Map)
        ..['downloadUrl'] = 'https://example.com/book.pdf',
    ];
    json['books'] = books;

    expect(
      () => BookCatalog.fromJson(json),
      throwsFormatException,
    );
  });
}
