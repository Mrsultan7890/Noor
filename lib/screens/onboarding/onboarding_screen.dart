import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../navigation/main_navigation_screen.dart';
import '../../providers/app_language_provider.dart';
import '../../utils/user_friendly_error.dart';
import '../../widgets/arabic_text.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0;
  String _selectedLanguage = 'English';
  String _selectedCountry = 'Pakistan';
  String _selectedLevel = 'Beginner'; // New

  List<Map<String, String>> get _languages => AppLanguageProvider.languages
      .map(
        (language) => {
          'code': language.code,
          'name': language.name,
          'native': language.nativeName,
          'quran': language.quranEdition,
        },
      )
      .toList(growable: false);

  final List<String> _countries = [
    'Pakistan',
    'Saudi Arabia',
    'UAE',
    'USA',
    'UK',
    'Canada',
    'Malaysia',
    'Indonesia',
    'Turkey',
    'Egypt',
    'India',
    'Bangladesh'
  ];

  Future<void> _completeOnboarding() async {
    final appLanguageProvider = context.read<AppLanguageProvider>();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);

    // Find selected language's Quran edition
    final selectedLang = _languages.firstWhere(
      (lang) => lang['name'] == _selectedLanguage,
      orElse: () => _languages[0],
    );

    await prefs.setString('selected_language', _selectedLanguage);
    await prefs.setString('quran_edition', selectedLang['quran']!);
    await prefs.setString('selected_country', _selectedCountry);
    await prefs.setString('user_level', _selectedLevel);
    await appLanguageProvider.setLanguage(_selectedLanguage);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      );
    }
  }

  Future<void> _selectLanguage(String name) async {
    try {
      await context.read<AppLanguageProvider>().setLanguage(name);
    } catch (error, stackTrace) {
      debugPrint(
          'Could not apply the onboarding language: $error\n$stackTrace');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(UserFriendlyError.settings(error))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final foreground = theme.colorScheme.onSurface;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Logo
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mosque,
                size: 50,
                color: theme.brightness == Brightness.dark
                    ? theme.colorScheme.onPrimary
                    : primary,
              ),
            ),

            const SizedBox(height: 20),

            ArabicLabel(
              'Noor - نور',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: foreground,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              context.tr('Islamic Companion'),
              style: TextStyle(
                fontSize: 16,
                color: foreground.withOpacity(0.75),
              ),
            ),

            const SizedBox(height: 60),

            // Content
            Expanded(
              child: Theme(
                data: theme.copyWith(
                  brightness: Brightness.light,
                  colorScheme: theme.colorScheme.copyWith(
                    brightness: Brightness.light,
                    surface: Colors.white,
                    onSurface: const Color(0xFF1E293B),
                    onPrimary: theme.colorScheme.onPrimary,
                  ),
                  textTheme: ThemeData.light().textTheme.apply(
                        bodyColor: const Color(0xFF1E293B),
                        displayColor: const Color(0xFF1E293B),
                      ),
                  cardTheme: ThemeData.light().cardTheme,
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: _currentStep == 0
                      ? _buildLanguageStep()
                      : _currentStep == 1
                          ? _buildLevelStep()
                          : _buildCountryStep(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageStep() {
    final primary = Theme.of(context).primaryColor;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            context.tr('Choose Your Language'),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('Select your preferred language for the app'),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: ListView.builder(
              itemCount: _languages.length,
              itemBuilder: (context, index) {
                final lang = _languages[index];
                final isSelected = _selectedLanguage == lang['name'];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: isSelected ? 4 : 1,
                  color: isSelected ? primary.withOpacity(0.1) : null,
                  child: ListTile(
                    onTap: () {
                      setState(() {
                        _selectedLanguage = lang['name']!;
                      });
                      _selectLanguage(lang['name']!);
                    },
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isSelected ? primary : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          lang['code']!.toUpperCase(),
                          style: TextStyle(
                            color: isSelected
                                ? Theme.of(context).colorScheme.onPrimary
                                : Colors.grey[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    title: ArabicLabel(
                      lang['native']!,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(context.tr(lang['name']!)),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: primary)
                        : null,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentStep = 1;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                context.tr('Next'),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryStep() {
    final primary = Theme.of(context).primaryColor;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _currentStep = 1;
                  });
                },
              ),
              const SizedBox(width: 8),
              Text(
                context.tr('Choose Your Country'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('This helps us provide accurate prayer times'),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: ListView.builder(
              itemCount: _countries.length,
              itemBuilder: (context, index) {
                final country = _countries[index];
                final isSelected = _selectedCountry == country;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: isSelected ? 4 : 1,
                  color: isSelected ? primary.withOpacity(0.1) : null,
                  child: ListTile(
                    onTap: () {
                      setState(() {
                        _selectedCountry = country;
                      });
                    },
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isSelected ? primary : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Colors.grey[700],
                      ),
                    ),
                    title: Text(
                      country,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: primary)
                        : null,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _completeOnboarding,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                context.tr('Get Started'),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelStep() {
    final levels = [
      {
        'title': 'New Muslim',
        'subtitle': 'Just started learning about Islam',
        'icon': Icons.auto_stories,
        'color': Colors.blue,
        'features': ['Basic prayers', 'Quran basics', 'Islamic fundamentals'],
      },
      {
        'title': 'Beginner',
        'subtitle': 'Learning the basics of Islamic practices',
        'icon': Icons.school,
        'color': Colors.green,
        'features': ['Daily prayers', 'Quran reading', 'Basic Arabic'],
      },
      {
        'title': 'Intermediate',
        'subtitle': 'Regular practitioner seeking to improve',
        'icon': Icons.trending_up,
        'color': Colors.orange,
        'features': ['Tajweed', 'Hadith study', 'Advanced learning'],
      },
      {
        'title': 'Advanced',
        'subtitle': 'Deep knowledge and regular practice',
        'icon': Icons.workspace_premium,
        'color': Colors.purple,
        'features': ['Tafsir', 'Fiqh', 'Islamic scholarship'],
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _currentStep = 0;
                  });
                },
              ),
              const SizedBox(width: 8),
              const Text(
                'Your Learning Level',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Help us personalize your experience',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: ListView.builder(
              itemCount: levels.length,
              itemBuilder: (context, index) {
                final level = levels[index];
                final isSelected = _selectedLevel == level['title'];

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: isSelected ? 6 : 2,
                  color: isSelected
                      ? (level['color'] as Color).withOpacity(0.1)
                      : null,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedLevel = level['title'] as String;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? level['color'] as Color
                                  : (level['color'] as Color).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              level['icon'] as IconData,
                              color: isSelected
                                  ? Colors.white
                                  : level['color'] as Color,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  level['title'] as String,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? level['color'] as Color
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  level['subtitle'] as String,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  children: (level['features'] as List<String>)
                                      .map((feature) => Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: (level['color'] as Color)
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              feature,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: level['color'] as Color,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: level['color'] as Color,
                              size: 28,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentStep = 2;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Next',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
