import 'package:flutter/material.dart';
import '../quran/enhanced_quran_reader_screen.dart';
import '../quran/quran_reader_screen.dart';
import '../learning/arabic_alphabet_screen.dart';
import '../learning/shahada_screen.dart';
import '../learning/salah_guide_screen.dart';
import '../learning/wudu_guide_screen.dart';
import '../../models/quran_model.dart';

class NewMuslimHomeScreen extends StatelessWidget {
  const NewMuslimHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome New Muslim! 🌙'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Welcome Card
          Card(
            color: Theme.of(context).primaryColor,
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'السلام علیکم',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Welcome to Islam! Start your journey here.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            'Step 1: Learn the Basics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          _LearningCard(
            title: 'Shahada (Declaration of Faith)',
            subtitle: 'The first pillar of Islam',
            icon: Icons.favorite,
            color: Colors.red,
            progress: 0.0,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ShahadaScreen()),
              );
            },
          ),
          
          _LearningCard(
            title: 'How to Pray (Salah)',
            subtitle: 'Step-by-step prayer guide',
            icon: Icons.self_improvement,
            color: Colors.blue,
            progress: 0.0,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SalahGuideScreen()),
              );
            },
          ),
          
          _LearningCard(
            title: 'Wudu (Ablution)',
            subtitle: 'Learn how to perform wudu',
            icon: Icons.water_drop,
            color: Colors.cyan,
            progress: 0.0,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WuduGuideScreen()),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            'Step 2: Learn Arabic Basics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          _LearningCard(
            title: 'Arabic Alphabet',
            subtitle: '28 letters with pronunciation',
            icon: Icons.abc,
            color: Colors.purple,
            progress: 0.0,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ArabicAlphabetScreen(),
                ),
              );
            },
          ),
          
          _LearningCard(
            title: 'Basic Duas',
            subtitle: 'Essential daily supplications',
            icon: Icons.menu_book,
            color: Colors.orange,
            progress: 0.0,
            onTap: () => _showBasicDuas(context),
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            'Step 3: Start Reading Quran',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          _LearningCard(
            title: 'Surah Al-Fatihah',
            subtitle: 'The Opening - Learn with audio',
            icon: Icons.headphones,
            color: Colors.green,
            progress: 0.0,
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
          
          _LearningCard(
            title: 'Short Surahs',
            subtitle: 'Easy surahs for beginners',
            icon: Icons.auto_stories,
            color: Colors.teal,
            progress: 0.0,
            onTap: () => _showShortSurahs(context),
          ),
          
          const SizedBox(height: 24),
          
          Card(
            color: Colors.amber.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.lightbulb, color: Colors.amber.shade700, size: 40),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Take Your Time',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Learn at your own pace. May Allah guide you!',
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

  static void _showBasicDuas(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Basic Duas'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Before Eating:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('بِسْمِ اللَّهِ', style: TextStyle(fontSize: 18)),
              Text('Bismillah (In the name of Allah)'),
              SizedBox(height: 16),
              Text(
                'After Eating:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('الْحَمْدُ لِلَّهِ', style: TextStyle(fontSize: 18)),
              Text('Alhamdulillah (Praise be to Allah)'),
              SizedBox(height: 16),
              Text(
                'Before Sleeping:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا', style: TextStyle(fontSize: 18)),
              Text('Bismika Allahumma amutu wa ahya'),
              SizedBox(height: 16),
              Text(
                'When Waking Up:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا', style: TextStyle(fontSize: 18)),
              Text('Alhamdulillah alladhi ahyana'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static void _showShortSurahs(BuildContext context) {
    final surahs = [
      Surah(number: 112, name: 'سُورَةُ الْإِخْلَاصِ', englishName: 'Al-Ikhlas', englishNameTranslation: 'The Sincerity', numberOfAyahs: 4, revelationType: 'Meccan'),
      Surah(number: 113, name: 'سُورَةُ الْفَلَقِ', englishName: 'Al-Falaq', englishNameTranslation: 'The Daybreak', numberOfAyahs: 5, revelationType: 'Meccan'),
      Surah(number: 114, name: 'سُورَةُ النَّاسِ', englishName: 'An-Nas', englishNameTranslation: 'Mankind', numberOfAyahs: 6, revelationType: 'Meccan'),
      Surah(number: 108, name: 'سُورَةُ الْكَوْثَرِ', englishName: 'Al-Kawthar', englishNameTranslation: 'The Abundance', numberOfAyahs: 3, revelationType: 'Meccan'),
      Surah(number: 109, name: 'سُورَةُ الْكَافِرُونَ', englishName: 'Al-Kafirun', englishNameTranslation: 'The Disbelievers', numberOfAyahs: 6, revelationType: 'Meccan'),
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Short Surahs for Beginners'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: surahs.length,
            itemBuilder: (context, index) {
              final surah = surahs[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    '${surah.number}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                title: Text(surah.englishName),
                subtitle: Text('${surah.numberOfAyahs} verses'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuranReaderScreen(surah: surah),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
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
  final double progress;
  final VoidCallback onTap;

  const _LearningCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
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
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
              if (progress > 0) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
