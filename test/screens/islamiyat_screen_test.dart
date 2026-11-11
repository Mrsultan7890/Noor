import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:noor/providers/app_language_provider.dart';
import 'package:noor/screens/islamiyat/islamiyat_screen.dart';
import 'package:noor/services/islamiyat_content_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const articles = [
    {
      'id': 'first',
      'title': {'en': 'Faith and practice'},
      'question': {'en': 'How is this explained?'},
      'answer': {'en': 'The first answer.'},
      'tags': ['belief'],
      'sources': [
        {
          'type': 'Book',
          'title': 'A named source',
          'author': 'A named author',
          'reference': 'Chapter 1, page 3',
          'quote': 'A cited excerpt.',
          'url': 'https://example.org/source',
        }
      ],
    },
    {
      'id': 'second',
      'title': {'en': 'Another subject'},
      'question': {'en': 'A different question?'},
      'answer': {'en': 'Another answer.'},
      'tags': ['history'],
      'sources': [
        {
          'type': 'Organization',
          'title': 'Second source',
          'reference': 'Report 4',
        }
      ],
    },
  ];

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('searches articles and displays their citations', (tester) async {
    final language = await AppLanguageProvider.load();
    final service = IslamiyatContentService(
      client: MockClient((_) async => http.Response.bytes(
            utf8.encode(json.encode({'version': 1, 'items': articles})),
            200,
          )),
    );
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: language,
        child: MaterialApp(
          home: IslamiyatScreen(service: service),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Faith and practice'), findsOneWidget);
    expect(find.text('Another subject'), findsOneWidget);

    await tester.enterText(
      find.byType(TextField),
      'Chapter 1',
    );
    await tester.pumpAndSettle();
    expect(find.text('Faith and practice'), findsOneWidget);
    expect(find.text('Another subject'), findsNothing);

    await tester.enterText(find.byType(TextField), 'nothing matches');
    await tester.pumpAndSettle();
    expect(find.text('No matching content found.'), findsOneWidget);
  });

  testWidgets('article detail shows reference metadata', (tester) async {
    final language = await AppLanguageProvider.load();
    final service = IslamiyatContentService(
      client: MockClient((_) async => http.Response.bytes(
            utf8.encode(json.encode({'version': 1, 'items': articles})),
            200,
          )),
    );
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: language,
        child: MaterialApp(
          home: IslamiyatScreen(service: service),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Faith and practice'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.textContaining('A cited excerpt.'),
      240,
    );
    await tester.pumpAndSettle();

    expect(find.text('The first answer.'), findsOneWidget);
    expect(find.text('A named source'), findsOneWidget);
    expect(find.textContaining('Chapter 1, page 3'), findsOneWidget);
    expect(find.textContaining('A cited excerpt.'), findsOneWidget);
  });
}
