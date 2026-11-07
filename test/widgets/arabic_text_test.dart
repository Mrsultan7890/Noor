import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor/providers/theme_provider.dart';
import 'package:noor/widgets/arabic_text.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('bilingual UI labels render Arabic runs with Amiri', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ArabicLabel('Learn - سیکھیں'),
        ),
      ),
    );

    final richText = tester.widget<RichText>(find.byType(RichText));
    final arabicSpan = richText.text.children!.last as TextSpan;
    expect(arabicSpan.text, 'سیکھیں');
    expect(arabicSpan.style?.fontFamily, 'Amiri');
  });

  testWidgets('Arabic text uses Amiri, RTL, and the saved font scale', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'arabicFontScale': 1.2});
    final themeProvider = ThemeProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: themeProvider,
        child: const MaterialApp(
          home: Scaffold(
            body: ArabicText(
              'بِسْمِ اللَّهِ',
              style: TextStyle(fontSize: 24),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final text = tester.widget<Text>(find.text('بِسْمِ اللَّهِ'));
    expect(text.textDirection, TextDirection.rtl);
    expect(text.style?.fontFamily, 'Amiri');
    expect(text.style?.fontSize, closeTo(28.8, 0.01));
  });
}
