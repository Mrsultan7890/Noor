import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor/providers/app_language_provider.dart';
import 'package:noor/widgets/service_loading_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows an animated, feature-specific loading state',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final language = await AppLanguageProvider.load();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: language,
        child: const MaterialApp(
          home: Scaffold(
            body: ServiceLoadingView(
              serviceName: 'Quran',
              icon: Icons.menu_book_outlined,
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Loading Quran'), findsOneWidget);
    expect(find.text('Connecting to the service...'), findsOneWidget);
    expect(find.byIcon(Icons.menu_book_outlined), findsOneWidget);

    const localizedHeadings = {
      'Urdu': 'لوڈ ہو رہا ہے: قرآن',
      'Arabic': 'جارٍ تحميل: القرآن',
      'Indonesian': 'Memuat: Al-Qur’an',
      'Turkish': 'Yükleniyor: Kur’an',
      'French': 'Chargement : Coran',
    };
    for (final entry in localizedHeadings.entries) {
      await language.setLanguage(entry.key);
      await tester.pump();
      expect(find.text(entry.value), findsOneWidget);
      expect(
        find.text(
          switch (entry.key) {
            'Urdu' => 'سروس سے رابطہ کیا جا رہا ہے...',
            'Arabic' => 'جارٍ الاتصال بالخدمة...',
            'Indonesian' => 'Menghubungkan ke layanan...',
            'Turkish' => 'Hizmete bağlanılıyor...',
            'French' => 'Connexion au service...',
            _ => fail('Unexpected language ${entry.key}'),
          },
        ),
        findsOneWidget,
      );
    }

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
