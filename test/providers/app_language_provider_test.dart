import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor/providers/app_language_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('loads the persisted language and uses its app direction', () async {
    SharedPreferences.setMockInitialValues({'selected_language': 'Urdu'});

    final provider = await AppLanguageProvider.load();

    expect(provider.languageName, 'Urdu');
    expect(provider.textDirection, TextDirection.rtl);
    expect(provider.translate('Home'), 'ہوم');
  });

  test('changing language also updates Quran translation edition', () async {
    final provider = await AppLanguageProvider.load();

    await provider.setLanguage('French');

    final preferences = await SharedPreferences.getInstance();
    expect(provider.languageCode, 'fr');
    expect(provider.textDirection, TextDirection.ltr);
    expect(preferences.getString('selected_language'), 'French');
    expect(preferences.getString('quran_edition'), 'fr.hamidullah');
    expect(provider.translate('Home'), 'Accueil');
  });

  test('unknown strings remain available in English', () async {
    final provider = await AppLanguageProvider.load();
    await provider.setLanguage('Arabic');

    expect(provider.translate('A new untranslated label'),
        'A new untranslated label');
  });

  test('each non-English onboarding language has a translated home label',
      () async {
    final provider = await AppLanguageProvider.load();

    for (final language in AppLanguageProvider.languages.skip(1)) {
      await provider.setLanguage(language.name);
      expect(provider.translate('Home'), isNot('Home'), reason: language.name);
    }
  });
}
