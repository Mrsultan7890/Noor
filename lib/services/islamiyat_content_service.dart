import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/islamiyat_model.dart';
import 'utf8_json.dart';

class IslamiyatContentService {
  IslamiyatContentService({http.Client? client}) : _client = client;

  static const _cacheKey = 'published_islamiyat_catalog_v1';
  static final _catalogUri = Uri.parse(
    'https://raw.githubusercontent.com/Mrsultan7890/noor/main/data/islamiyat.json',
  );

  final http.Client? _client;

  Future<IslamiyatCatalog> load() async {
    final preferences = await SharedPreferences.getInstance();
    try {
      final response =
          await (_client?.get(_catalogUri) ?? http.get(_catalogUri))
              .timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        throw http.ClientException(
          'Islamiyat catalog returned HTTP ${response.statusCode}.',
          _catalogUri,
        );
      }
      if (response.bodyBytes.isEmpty) {
        throw const FormatException('Islamiyat catalog is empty.');
      }

      final catalog = _parseCatalog(decodeUtf8JsonResponse(response));
      final saved = await preferences.setString(
        _cacheKey,
        json.encode({
          'version': 1,
          'items': catalog.articles.map(_articleToJson).toList(),
        }),
      );
      if (!saved) {
        debugPrint('Could not cache the latest Islamiyat catalog.');
      }
      return IslamiyatCatalog(articles: catalog.articles, isOffline: false);
    } on http.ClientException catch (error) {
      return _loadCachedOrThrow(preferences, error);
    } on TimeoutException catch (error) {
      return _loadCachedOrThrow(preferences, error);
    } on IOException catch (error) {
      return _loadCachedOrThrow(preferences, error);
    } on FormatException catch (error) {
      return _loadCachedOrThrow(preferences, error);
    } on TypeError catch (error) {
      return _loadCachedOrThrow(preferences, error);
    }
  }

  IslamiyatCatalog _loadCachedOrThrow(
    SharedPreferences preferences,
    Object cause,
  ) {
    final cached = preferences.getString(_cacheKey);
    if (cached != null) {
      try {
        final catalog = _parseCatalog(json.decode(cached));
        return IslamiyatCatalog(articles: catalog.articles, isOffline: true);
      } on FormatException catch (error) {
        debugPrint('Cached Islamiyat catalog is invalid: $error');
      } on TypeError catch (error) {
        debugPrint('Cached Islamiyat catalog has invalid fields: $error');
      }
    }
    throw IslamiyatContentLoadException(cause);
  }

  IslamiyatCatalog _parseCatalog(Object? decoded) {
    if (decoded is! Map<String, dynamic> ||
        decoded['version'] != 1 ||
        decoded['items'] is! List) {
      throw const FormatException('Islamiyat catalog has an invalid shape.');
    }

    final articles = (decoded['items'] as List).map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException(
          'Islamiyat catalog contains an invalid article.',
        );
      }
      return IslamiyatArticle.fromJson(item);
    }).toList(growable: false);

    final ids = articles.map((article) => article.id).toSet();
    if (ids.length != articles.length) {
      throw const FormatException(
        'Islamiyat catalog contains duplicate article IDs.',
      );
    }
    return IslamiyatCatalog(
      articles: List.unmodifiable(articles),
      isOffline: false,
    );
  }

  Map<String, Object?> _articleToJson(IslamiyatArticle article) => {
        'id': article.id,
        'title': article.title,
        'question': article.question,
        'answer': article.answer,
        'tags': article.tags,
        'sources': article.sources.map((source) {
          return {
            'type': source.type,
            'title': source.title,
            if (source.author != null) 'author': source.author,
            'reference': source.reference,
            if (source.quote != null) 'quote': source.quote,
            if (source.url != null) 'url': source.url.toString(),
          };
        }).toList(),
      };
}

class IslamiyatContentLoadException implements Exception {
  const IslamiyatContentLoadException(this.cause);

  final Object cause;

  @override
  String toString() => 'Unable to load Islamiyat content: $cause';
}
