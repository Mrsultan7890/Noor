import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'utf8_json.dart';

class DuaCatalogItem {
  const DuaCatalogItem({
    required this.id,
    required this.title,
    required this.titleUrdu,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.translationUrdu,
    required this.category,
    required this.source,
    required this.repeat,
  });

  final String id;
  final String title;
  final String titleUrdu;
  final String arabic;
  final String transliteration;
  final String translation;
  final String translationUrdu;
  final String category;
  final String source;
  final String repeat;

  factory DuaCatalogItem.fromJson(Map<String, dynamic> json) {
    String requiredString(String key) {
      final value = json[key];
      if (value is! String || value.trim().isEmpty) {
        throw FormatException('Dua catalog item is missing "$key".');
      }
      return value;
    }

    String optionalString(String key) {
      final value = json[key];
      if (value == null) return '';
      if (value is! String) {
        throw FormatException('Dua catalog field "$key" must be text.');
      }
      return value;
    }

    return DuaCatalogItem(
      id: requiredString('id'),
      title: requiredString('title'),
      titleUrdu: optionalString('title_ur'),
      arabic: requiredString('arabic'),
      transliteration: requiredString('transliteration'),
      translation: requiredString('translation'),
      translationUrdu: optionalString('translation_ur'),
      category: requiredString('category'),
      source: requiredString('source'),
      repeat: optionalString('repeat'),
    );
  }

  Map<String, String> toScreenMap() => {
        'id': id,
        'title': title,
        'titleUrdu': titleUrdu.isEmpty ? title : titleUrdu,
        'arabic': arabic,
        'transliteration': transliteration,
        'translation': translation,
        'translationUrdu':
            translationUrdu.isEmpty ? translation : translationUrdu,
        'category': category,
        'source': source,
        if (repeat.isNotEmpty) 'repeat': repeat,
      };

  Map<String, String> toJson() => {
        'id': id,
        'title': title,
        'title_ur': titleUrdu,
        'arabic': arabic,
        'transliteration': transliteration,
        'translation': translation,
        'translation_ur': translationUrdu,
        'category': category,
        'source': source,
        'repeat': repeat,
      };
}

class DuaCatalogResult {
  const DuaCatalogResult({required this.items, required this.isOffline});

  final List<DuaCatalogItem> items;
  final bool isOffline;
}

class DuaContentService {
  DuaContentService({http.Client? client}) : _client = client;

  static const _cacheKey = 'published_dua_catalog_v1';
  static const _cacheTimeKey = 'published_dua_catalog_fetched_at_v1';
  static const _cacheMaxAge = Duration(hours: 24);
  static final _catalogUri = Uri.parse(
    'https://raw.githubusercontent.com/Mrsultan7890/noor/main/data/duas.json',
  );
  final http.Client? _client;

  Future<DuaCatalogResult> load({bool forceRefresh = false}) async {
    final preferences = await SharedPreferences.getInstance();
    final cached = _loadCache(preferences, isOffline: false);
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
              .timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) {
        return _offlineFallback(preferences);
      }

      final payload = decodeUtf8JsonResponse(response);
      if (payload is! Map<String, dynamic>) {
        throw const FormatException('Dua catalog response must be an object.');
      }
      final rawItems = payload['items'];
      if (rawItems is! List) {
        throw const FormatException('Dua catalog has no item list.');
      }
      final items = rawItems.map((item) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException('Dua catalog contains an invalid item.');
        }
        return DuaCatalogItem.fromJson(item);
      }).toList(growable: false);
      await preferences.setString(
        _cacheKey,
        json.encode(items.map((item) => item.toJson()).toList()),
      );
      await preferences.setInt(
        _cacheTimeKey,
        DateTime.now().millisecondsSinceEpoch,
      );
      return DuaCatalogResult(items: items, isOffline: false);
    } on FormatException {
      return _offlineFallback(preferences);
    } on http.ClientException {
      return _offlineFallback(preferences);
    } on TimeoutException {
      return _offlineFallback(preferences);
    }
  }

  DuaCatalogResult _offlineFallback(SharedPreferences preferences) =>
      _loadCache(preferences, isOffline: true) ??
      const DuaCatalogResult(items: [], isOffline: true);

  DuaCatalogResult? _loadCache(
    SharedPreferences preferences, {
    required bool isOffline,
  }) {
    final cached = preferences.getString(_cacheKey);
    if (cached == null) return null;

    try {
      final decoded = json.decode(cached);
      if (decoded is! List) {
        throw const FormatException('Cached dua catalog is invalid.');
      }
      final items = decoded.map((item) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException(
              'Cached dua catalog contains an invalid item.');
        }
        return DuaCatalogItem.fromJson(item);
      }).toList(growable: false);
      return DuaCatalogResult(items: items, isOffline: isOffline);
    } on FormatException catch (error) {
      debugPrint('Cached dua catalog is invalid: $error');
      return null;
    }
  }
}
