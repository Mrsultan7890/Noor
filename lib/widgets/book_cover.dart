import 'package:flutter/material.dart';

import '../models/book_catalog.dart';

class BookCover extends StatelessWidget {
  const BookCover({
    super.key,
    required this.book,
    this.coverUrl,
  });

  final BookItem book;
  final Uri? coverUrl;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        (coverUrl ?? book.coverUrl).toString(),
        fit: BoxFit.cover,
        semanticLabel: book.title,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          final expectedBytes = progress.expectedTotalBytes;
          return DecoratedBox(
            decoration: BoxDecoration(color: colors.surfaceVariant),
            child: Center(
              child: CircularProgressIndicator(
                value: expectedBytes == null
                    ? null
                    : progress.cumulativeBytesLoaded / expectedBytes,
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint(
            'Could not load official book cover for ${book.id}: '
            '$error\n$stackTrace',
          );
          return DecoratedBox(
            decoration: BoxDecoration(color: colors.surfaceVariant),
            child: Center(
              child: Icon(
                Icons.menu_book_outlined,
                size: 54,
                color: colors.primary.withOpacity(0.65),
              ),
            ),
          );
        },
      ),
    );
  }
}
