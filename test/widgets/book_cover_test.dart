import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor/models/book_catalog.dart';
import 'package:noor/widgets/book_cover.dart';

void main() {
  testWidgets('loads the official cover URL from the book catalog',
      (tester) async {
    final book = BookItem(
      id: 'sample-book',
      title: 'A Practical Guide',
      author: 'A. Author',
      language: 'en',
      categoryId: 'spirituality',
      description: 'A sample description.',
      tags: [],
      archiveIdentifier: 'sample-book',
      archiveUrl: Uri.parse('https://archive.org/details/sample-book'),
      coverUrl: Uri.parse('https://archive.org/cover/sample-book'),
      volumes: [],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 180,
            height: 240,
            child: BookCover(book: book),
          ),
        ),
      ),
    );

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<NetworkImage>());
    expect((image.image as NetworkImage).url, book.coverUrl.toString());
  });

  testWidgets('uses the volume cover URL when one is provided', (tester) async {
    final book = BookItem(
      id: 'sample-book',
      title: 'A Practical Guide',
      author: 'A. Author',
      language: 'en',
      categoryId: 'spirituality',
      description: 'A sample description.',
      tags: [],
      archiveIdentifier: 'sample-book',
      archiveUrl: Uri.parse('https://archive.org/details/sample-book'),
      coverUrl: Uri.parse('https://archive.org/cover/sample-book'),
      volumes: [],
    );
    final volumeCoverUrl = Uri.parse(
      'https://raw.githubusercontent.com/Mrsultan7890/noor/main/'
      'data/covers/sample-book-volume-2.webp',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 180,
            height: 240,
            child: BookCover(book: book, coverUrl: volumeCoverUrl),
          ),
        ),
      ),
    );

    final image = tester.widget<Image>(find.byType(Image));
    expect((image.image as NetworkImage).url, volumeCoverUrl.toString());
  });
}
