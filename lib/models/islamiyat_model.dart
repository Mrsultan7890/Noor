class IslamiyatCatalog {
  const IslamiyatCatalog({
    required this.articles,
    required this.isOffline,
  });

  final List<IslamiyatArticle> articles;
  final bool isOffline;
}

class IslamiyatArticle {
  const IslamiyatArticle({
    required this.id,
    required this.title,
    required this.question,
    required this.answer,
    required this.tags,
    required this.sources,
  });

  final String id;
  final Map<String, String> title;
  final Map<String, String> question;
  final Map<String, String> answer;
  final List<String> tags;
  final List<IslamiyatSource> sources;

  factory IslamiyatArticle.fromJson(Map<String, dynamic> json) {
    String requiredString(Object? value, String field) {
      if (value is! String || value.trim().isEmpty) {
        throw FormatException('Islamiyat article is missing "$field".');
      }
      return value.trim();
    }

    Map<String, String> localizedText(Object? value, String field) {
      if (value is String && value.trim().isNotEmpty) {
        return {'en': value.trim()};
      }
      if (value is! Map<String, dynamic> || value.isEmpty) {
        throw FormatException(
            'Islamiyat article "$field" must be localized text.');
      }
      final result = <String, String>{};
      for (final entry in value.entries) {
        if (entry.value is! String || (entry.value as String).trim().isEmpty) {
          throw FormatException(
            'Islamiyat article "$field" has invalid text for "${entry.key}".',
          );
        }
        result[entry.key] = (entry.value as String).trim();
      }
      return Map.unmodifiable(result);
    }

    final rawTags = json['tags'];
    if (rawTags is! List ||
        rawTags.any((tag) => tag is! String || tag.trim().isEmpty)) {
      throw const FormatException(
          'Islamiyat article tags must be text values.');
    }

    final rawSources = json['sources'];
    if (rawSources is! List || rawSources.isEmpty) {
      throw const FormatException(
        'Each Islamiyat article must include at least one source.',
      );
    }

    return IslamiyatArticle(
      id: requiredString(json['id'], 'id'),
      title: localizedText(json['title'], 'title'),
      question: localizedText(json['question'], 'question'),
      answer: localizedText(json['answer'], 'answer'),
      tags: List.unmodifiable(rawTags.cast<String>().map((tag) => tag.trim())),
      sources: List.unmodifiable(rawSources.map((source) {
        if (source is! Map<String, dynamic>) {
          throw const FormatException('Islamiyat source must be an object.');
        }
        return IslamiyatSource.fromJson(source);
      })),
    );
  }
}

class IslamiyatSource {
  const IslamiyatSource({
    required this.type,
    required this.title,
    required this.author,
    required this.reference,
    required this.quote,
    required this.url,
  });

  final String type;
  final String title;
  final String? author;
  final String reference;
  final String? quote;
  final Uri? url;

  factory IslamiyatSource.fromJson(Map<String, dynamic> json) {
    String requiredString(Object? value, String field) {
      if (value is! String || value.trim().isEmpty) {
        throw FormatException('Islamiyat source is missing "$field".');
      }
      return value.trim();
    }

    String? optionalString(Object? value, String field) {
      if (value == null) return null;
      if (value is! String) {
        throw FormatException('Islamiyat source "$field" must be text.');
      }
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }

    final rawUrl = optionalString(json['url'], 'url');
    final url = rawUrl == null ? null : Uri.tryParse(rawUrl);
    if (rawUrl != null &&
        (url == null ||
            !url.hasAuthority ||
            (url.scheme != 'https' && url.scheme != 'http'))) {
      throw const FormatException(
        'Islamiyat source URL must use HTTP or HTTPS.',
      );
    }

    return IslamiyatSource(
      type: requiredString(json['type'], 'type'),
      title: requiredString(json['title'], 'title'),
      author: optionalString(json['author'], 'author'),
      reference: requiredString(json['reference'], 'reference'),
      quote: optionalString(json['quote'], 'quote'),
      url: url,
    );
  }
}
