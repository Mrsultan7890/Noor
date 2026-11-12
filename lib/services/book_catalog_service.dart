import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/book_catalog.dart';
import 'utf8_json.dart';

class BookCatalogService {
  BookCatalogService({http.Client? client, Uri? catalogUri})
      : _client = client,
        _catalogUri = catalogUri ?? _defaultCatalogUri;

  static const _cacheKey = 'published_books_catalog_v1';
  static const _cacheTimeKey = 'published_books_catalog_fetched_at_v1';
  static const _cacheMaxAge = Duration(hours: 12);
  static final _defaultCatalogUri = Uri.parse(
    'https://raw.githubusercontent.com/Mrsultan7890/noor/main/data/books.json',
  );
  static const _bundledCatalogAsset = 'data/books.json';

  final http.Client? _client;
  final Uri _catalogUri;

  Future<BookCatalog> load({bool forceRefresh = false}) async {
    final preferences = await SharedPreferences.getInstance();
    final cached = _readCached(preferences, isOffline: false);
    final fetchedAt = preferences.getInt(_cacheTimeKey);
    if (!forceRefresh && cached != null && fetchedAt != null) {
      final cacheAge = DateTime.now().difference(
        DateTime.fromMillisecondsSinceEpoch(fetchedAt),
      );
      if (cacheAge >= Duration.zero && cacheAge < _cacheMaxAge) {
        return cached;
      }
    }

    try {
      final response =
          await (_client?.get(_catalogUri) ?? http.get(_catalogUri))
              .timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        throw http.ClientException(
          'Book catalog returned HTTP ${response.statusCode}.',
          _catalogUri,
        );
      }
      if (response.bodyBytes.isEmpty) {
        throw const FormatException('Book catalog is empty.');
      }

      final catalog = _decodeCatalog(decodeUtf8JsonResponse(response));
      final cacheSaved = await preferences.setString(
        _cacheKey,
        json.encode(_catalogToJson(catalog)),
      );
      if (!cacheSaved) {
        debugPrint('Could not cache the latest book catalog.');
      }
      await preferences.setInt(
        _cacheTimeKey,
        DateTime.now().millisecondsSinceEpoch,
      );
      return catalog;
    } on http.ClientException catch (error) {
      debugPrint('Could not fetch the GitHub book catalog: $error');
      return _loadFallback(preferences);
    } on TimeoutException catch (error) {
      debugPrint('Timed out fetching the GitHub book catalog: $error');
      return _loadFallback(preferences);
    } on IOException catch (error) {
      debugPrint('Could not read the GitHub book catalog: $error');
      return _loadFallback(preferences);
    } on FormatException catch (error) {
      debugPrint('The GitHub book catalog is invalid: $error');
      return _loadFallback(preferences);
    } on TypeError catch (error) {
      debugPrint('The GitHub book catalog has invalid fields: $error');
      return _loadFallback(preferences);
    }
  }

  Future<BookCatalog> _loadFallback(SharedPreferences preferences) async {
    final cached = _readCached(preferences, isOffline: true);
    if (cached != null) return cached;
    try {
      final bundledJson = await rootBundle.loadString(_bundledCatalogAsset);
      return _decodeCatalog(json.decode(bundledJson), isOffline: true);
    } on FormatException catch (error) {
      throw BookCatalogLoadException(
        'The bundled book catalog is invalid: $error',
      );
    } on TypeError catch (error) {
      throw BookCatalogLoadException(
        'The bundled book catalog has invalid fields: $error',
      );
    } on FlutterError catch (error) {
      throw BookCatalogLoadException(
        'The bundled book catalog could not be opened: $error',
      );
    }
  }

  BookCatalog? _readCached(
    SharedPreferences preferences, {
    required bool isOffline,
  }) {
    final cachedJson = preferences.getString(_cacheKey);
    if (cachedJson == null) return null;
    try {
      final catalog = _decodeCatalog(json.decode(cachedJson));
      return BookCatalog(
        categories: catalog.categories,
        books: catalog.books,
        isOffline: isOffline,
      );
    } on FormatException catch (error) {
      debugPrint('Cached book catalog is invalid: $error');
    } on TypeError catch (error) {
      debugPrint('Cached book catalog has invalid fields: $error');
    }
    return null;
  }

  BookCatalog _decodeCatalog(
    Object? decoded, {
    bool isOffline = false,
  }) {
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Book catalog must be a JSON object.');
    }
    return BookCatalog.fromJson(decoded, isOffline: isOffline);
  }

  Map<String, Object?> _catalogToJson(BookCatalog catalog) => {
        'version': 1,
        'categories': catalog.categories
            .map((category) => {
                  'id': category.id,
                  'name': category.name,
                  'description': category.description,
                })
            .toList(),
        'books': catalog.books
            .map((book) => {
                  'id': book.id,
                  'title': book.title,
                  'author': book.author,
                  'language': book.language,
                  'categoryId': book.categoryId,
                  'description': book.description,
                  'tags': book.tags,
                  'archiveIdentifier': book.archiveIdentifier,
                  'archiveUrl': book.archiveUrl.toString(),
                  'coverUrl': book.coverUrl.toString(),
                  'volumes': book.volumes
                      .map((volume) => {
                            'number': volume.number,
                            'title': volume.title,
                            'fileName': volume.fileName,
                            'downloadUrl': volume.downloadUrl.toString(),
                          })
                      .toList(),
                })
            .toList(),
      };
}

class BookCatalogLoadException implements Exception {
  const BookCatalogLoadException(this.message);

  final String message;

  @override
  String toString() => 'Unable to load books: $message';
}
