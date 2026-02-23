import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/update_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../screens/quran/quran_list_screen.dart';
import '../../screens/quran/mushaf_quran_screen.dart';
import '../../screens/quran/enhanced_quran_reader_screen.dart';
import '../../screens/learning/arabic_alphabet_screen.dart';
import '../../models/quran_model.dart';
import '../../screens/tasbih/tasbih_screen.dart';
import '../../screens/schedule/schedule_list_screen.dart';
import '../../screens/ramadan/ramadan_home_screen.dart';
import '../../screens/prayer/prayer_times_screen.dart';
import '../../screens/qibla/qibla_screen.dart';
import '../../screens/hadith/hadith_screen.dart';
import '../../screens/dua/dua_screen.dart';
import '../../screens/names/names_screen.dart';
import '../../screens/games/kids_zone_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../widgets/feature_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkForUpdates();
  }

  Future<void> _checkForUpdates() async {
    await Future.delayed(const Duration(seconds: 2));
    final updateInfo = await UpdateService.checkForUpdate();
    if (updateInfo != null && updateInfo['hasUpdate'] == true && mounted) {
      _showUpdateDialog(updateInfo);
    }
  }

  void _showUpdateDialog(Map<String, dynamic> info) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.system_update, color: Colors.green),
            SizedBox(width: 8),
            Text('Update Available'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('New version ${info['latestVersion']} is available!'),
            Text('Current: ${info['currentVersion']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 16),
            const Text('What\'s New:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(info['changelog'] ?? 'Bug fixes and improvements'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () async {
              final url = Uri.parse(info['downloadUrl']);
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }
  
  bool _isRamadanActive() {
    final now = DateTime.now();
    final ramadanStart = DateTime(2025, 2, 28);
    final eidDate = DateTime(2025, 3, 30);
    return now.isAfter(ramadanStart) && now.isBefore(eidDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Noor - نور',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              color: Theme.of(context).primaryColor,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.wb_sunny, color: Colors.white, size: 32),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'السلام علیکم',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Welcome to Noor - Your Islamic Companion',
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
            
            // Quick Access
            Text(
              'Quick Access',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _QuickAccessCard(
                    title: 'Quran',
                    icon: Icons.menu_book,
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QuranListScreen(),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _QuickAccessCard(
                    title: 'Mushaf',
                    icon: Icons.auto_stories,
                    color: Colors.brown,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MushafQuranScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _QuickAccessCard(
                    title: 'Tasbih',
                    icon: Icons.circle_outlined,
                    color: Colors.teal,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TasbihScreen(),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _QuickAccessCard(
                    title: 'Qibla',
                    icon: Icons.explore,
                    color: Colors.indigo,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QiblaScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Featured
            Text(
              'Featured',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            FeatureCard(
              title: 'Learn Quran with Audio',
              subtitle: 'Transliteration, Word-by-Word & Recitation',
              icon: Icons.headphones,
              color: Colors.deepOrange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EnhancedQuranReaderScreen(
                      surah: Surah(
                        number: 1,
                        name: 'سُورَةُ ٱلْفَاتِحَةِ',
                        englishName: 'Al-Fatihah',
                        numberOfAyahs: 7,
                        revelationType: 'Meccan',
                      ),
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 12),
            
            FeatureCard(
              title: 'Learn Arabic Alphabet',
              subtitle: 'Letters, Harakat & Interactive Quiz',
              icon: Icons.school,
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
            
            FeatureCard(
              title: 'My Schedule',
              subtitle: 'Build your Islamic routine',
              icon: Icons.schedule,
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ScheduleListScreen(),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 12),
            
            FeatureCard(
              title: 'Prayer Times',
              subtitle: 'Daily Salah timings',
              icon: Icons.access_time,
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrayerTimesScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.title,
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
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
