class BookCatalog {
  const BookCatalog({
    required this.categories,
    required this.books,
    this.isOffline = false,
  });

  final List<BookCategory> categories;
  final List<BookItem> books;
  final bool isOffline;

  factory BookCatalog.fromJson(
    Map<String, dynamic> json, {
    bool isOffline = false,
  }) {
    if (json['version'] != 1 ||
        json['categories'] is! List ||
        json['books'] is! List) {
      throw const FormatException('Book catalog has an invalid shape.');
    }

    final categories = (json['categories'] as List)
        .map((item) => BookCategory.fromJson(_object(item, 'category')))
        .toList(growable: false);
    final books = (json['books'] as List)
        .map((item) => BookItem.fromJson(_object(item, 'book')))
        .toList(growable: false);
    if (categories.isEmpty || books.isEmpty) {
      throw const FormatException(
        'Book catalog must include categories and books.',
      );
    }

    final categoryIds = categories.map((category) => category.id).toSet();
    final bookIds = books.map((book) => book.id).toSet();
    if (categoryIds.length != categories.length ||
        bookIds.length != books.length) {
      throw const FormatException(
        'Book catalog contains duplicate category or book IDs.',
      );
    }
    if (books.any((book) => !categoryIds.contains(book.categoryId))) {
      throw const FormatException(
        'Book catalog references an unknown category.',
      );
    }

    return BookCatalog(
      categories: List.unmodifiable(categories),
      books: List.unmodifiable(books),
      isOffline: isOffline,
    );
  }

  List<BookItem> search({
    String query = '',
    String? categoryId,
  }) {
    final normalizedQuery = query.trim().toLowerCase();
    return books.where((book) {
      if (categoryId != null && book.categoryId != categoryId) return false;
      if (normalizedQuery.isEmpty) return true;
      final searchableText = [
        book.title,
        book.author,
        book.description,
        ...book.tags,
      ].join(' ').toLowerCase();
      return searchableText.contains(normalizedQuery);
    }).toList(growable: false);
  }
}

class BookCategory {
  const BookCategory({
    required this.id,
    required this.name,
    required this.description,
  });

  final String id;
  final String name;
  final String description;

  factory BookCategory.fromJson(Map<String, dynamic> json) => BookCategory(
        id: _requiredString(json['id'], 'category.id'),
        name: _requiredString(json['name'], 'category.name'),
        description:
            _requiredString(json['description'], 'category.description'),
      );
}

class BookItem {
  const BookItem({
    required this.id,
    required this.title,
    required this.author,
    required this.language,
    required this.categoryId,
    required this.description,
    required this.tags,
    required this.archiveIdentifier,
    required this.archiveUrl,
    required this.coverUrl,
    required this.volumes,
  });

  final String id;
  final String title;
  final String author;
  final String language;
  final String categoryId;
  final String description;
  final List<String> tags;
  final String archiveIdentifier;
  final Uri archiveUrl;
  final Uri coverUrl;
  final List<BookVolume> volumes;

  factory BookItem.fromJson(Map<String, dynamic> json) {
    final id = _requiredString(json['id'], 'book.id');
    final archiveIdentifier =
        _requiredString(json['archiveIdentifier'], 'book.archiveIdentifier');
    final volumesJson = json['volumes'];
    final tagsJson = json['tags'];
    if (volumesJson is! List ||
        volumesJson.isEmpty ||
        tagsJson is! List ||
        tagsJson.any((tag) => tag is! String || tag.trim().isEmpty)) {
      throw const FormatException(
        'Book volumes and tags must be non-empty lists.',
      );
    }

    final volumes = volumesJson
        .map((volume) => BookVolume.fromJson(_object(volume, 'volume')))
        .toList(growable: false);
    final volumeNumbers = volumes.map((volume) => volume.number).toSet();
    if (volumeNumbers.length != volumes.length) {
      throw const FormatException(
        'A book cannot contain duplicate volume numbers.',
      );
    }

    final archiveUrl =
        _archiveUri(json['archiveUrl'], '/details/$archiveIdentifier');
    final coverUrl = _archiveUri(
      json['coverUrl'],
      '/services/img/$archiveIdentifier',
    );
    for (final volume in volumes) {
      if (volume.downloadUrl.pathSegments.length < 3 ||
          volume.downloadUrl.pathSegments[0] != 'download' ||
          volume.downloadUrl.pathSegments[1] != archiveIdentifier ||
          volume.downloadUrl.pathSegments.last != volume.fileName) {
        throw const FormatException(
          'Book download links must point to a matching Internet Archive file.',
        );
      }
    }

    return BookItem(
      id: id,
      title: _requiredString(json['title'], 'book.title'),
      author: _requiredString(json['author'], 'book.author'),
      language: _requiredString(json['language'], 'book.language'),
      categoryId: _requiredString(json['categoryId'], 'book.categoryId'),
      description: _requiredString(json['description'], 'book.description'),
      tags: List.unmodifiable(tagsJson.cast<String>().map((tag) => tag.trim())),
      archiveIdentifier: archiveIdentifier,
      archiveUrl: archiveUrl,
      coverUrl: coverUrl,
      volumes: List.unmodifiable(volumes),
    );
  }
}

class BookVolume {
  const BookVolume({
    required this.number,
    required this.title,
    required this.fileName,
    required this.downloadUrl,
  });

  final int number;
  final String title;
  final String fileName;
  final Uri downloadUrl;

  factory BookVolume.fromJson(Map<String, dynamic> json) {
    final number = json['number'];
    if (number is! int || number < 1) {
      throw const FormatException('Book volume number must be positive.');
    }
    final fileName = _requiredString(json['fileName'], 'volume.fileName');
    if (!fileName.toLowerCase().endsWith('.pdf') ||
        fileName.contains('/') ||
        fileName.contains(r'\')) {
      throw const FormatException('Book volume must reference a PDF file.');
    }
    return BookVolume(
      number: number,
      title: _requiredString(json['title'], 'volume.title'),
      fileName: fileName,
      downloadUrl: _archiveUri(json['downloadUrl'], null),
    );
  }
}

Map<String, dynamic> _object(Object? value, String field) {
  if (value is! Map<String, dynamic>) {
    throw FormatException('Book catalog "$field" must be an object.');
  }
  return value;
}

String _requiredString(Object? value, String field) {
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Book catalog is missing "$field".');
  }
  return value.trim();
}

Uri _archiveUri(Object? value, String? expectedPath) {
  final rawUrl = _requiredString(value, 'URL');
  final uri = Uri.tryParse(rawUrl);
  if (uri == null ||
      uri.scheme != 'https' ||
      uri.host != 'archive.org' ||
      uri.userInfo.isNotEmpty ||
      uri.hasPort ||
      uri.hasQuery ||
      uri.hasFragment ||
      (expectedPath != null && uri.path != expectedPath)) {
    throw const FormatException(
      'Book links must use the expected HTTPS Internet Archive URL.',
    );
  }
  return uri;
}
