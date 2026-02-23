import 'package:flutter/material.dart';
import '../../models/quran_model.dart';
import '../quran/enhanced_quran_reader_screen.dart';
import 'arabic_alphabet_screen.dart';

class LearningHubScreen extends StatelessWidget {
  const LearningHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn - سیکھیں'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Theme.of(context).primaryColor,
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.school, color: Colors.white, size: 32),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Islamic Learning Center',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Learn Quran, Arabic & Islamic Knowledge',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Quran Learning',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          _LearningCard(
            title: 'Learn with Audio',
            subtitle: 'Listen & follow along with recitation',
            icon: Icons.headphones,
            color: Colors.green,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EnhancedQuranReaderScreen(
                    surah: Surah(
                      number: 1,
                      name: 'سُورَةُ ٱلْفَاتِحَةِ',
                      englishName: 'Al-Fatihah',
                      englishNameTranslation: 'The Opening',
                      numberOfAyahs: 7,
                      revelationType: 'Meccan',
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 12),
          
          _LearningCard(
            title: 'Transliteration',
            subtitle: 'Read Arabic in Roman script',
            icon: Icons.text_fields,
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EnhancedQuranReaderScreen(
                    surah: Surah(
                      number: 1,
                      name: 'سُورَةُ ٱلْفَاتِحَةِ',
                      englishName: 'Al-Fatihah',
                      englishNameTranslation: 'The Opening',
                      numberOfAyahs: 7,
                      revelationType: 'Meccan',
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 12),
          
          _LearningCard(
            title: 'Word by Word',
            subtitle: 'Understand each Arabic word meaning',
            icon: Icons.translate,
            color: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EnhancedQuranReaderScreen(
                    surah: Surah(
                      number: 1,
                      name: 'سُورَةُ ٱلْفَاتِحَةِ',
                      englishName: 'Al-Fatihah',
                      englishNameTranslation: 'The Opening',
                      numberOfAyahs: 7,
                      revelationType: 'Meccan',
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Arabic Language',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          _LearningCard(
            title: 'Arabic Alphabet',
            subtitle: 'Learn 28 letters with pronunciation',
            icon: Icons.abc,
            color: Colors.purple,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ArabicAlphabetScreen(),
                ),
              );
            },
          ),
          
          const SizedBox(height: 12),
          
          _LearningCard(
            title: 'Harakat (Zabar, Zer, Pesh)',
            subtitle: 'Master Arabic vowel marks',
            icon: Icons.format_size,
            color: Colors.teal,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ArabicAlphabetScreen(),
                ),
              );
            },
          ),
          
          const SizedBox(height: 12),
          
          _LearningCard(
            title: 'Interactive Quiz',
            subtitle: 'Test your Arabic knowledge',
            icon: Icons.quiz,
            color: Colors.red,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ArabicAlphabetScreen(),
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          Card(
            color: Colors.amber.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.emoji_events, color: Colors.amber.shade700, size: 40),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Keep Learning!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Practice daily to improve your skills',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.amber.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LearningCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _LearningCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
