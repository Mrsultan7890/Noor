import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../screens/quran/quran_list_screen.dart';
import '../screens/tasbih/tasbih_screen.dart';
import '../screens/schedule/schedule_list_screen.dart';
import '../screens/ramadan/ramadan_home_screen.dart';
import '../widgets/feature_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  
  bool _isRamadanActive() {
    final now = DateTime.now();
    final ramadanStart = DateTime(2025, 2, 28);
    final eidDate = DateTime(2025, 3, 30);
    return now.isAfter(ramadanStart) && now.isBefore(eidDate);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Noor - نور',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.themeMode == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'السلام علیکم',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Welcome to Noor - Your Islamic Companion',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Ramadan Section (Conditional)
            if (_isRamadanActive()) ...[
              Text(
                '🌙 Ramadan Special',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              FeatureCard(
                title: 'Ramadan Features',
                subtitle: 'Sehri/Iftar Timer, Roza Counter & More',
                icon: Icons.nightlight_round,
                color: Colors.purple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RamadanHomeScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
            
            // Core Features
            Text(
              'Core Features',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            FeatureCard(
              title: 'Quran - قرآن',
              subtitle: 'Read with Urdu translation',
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
            
            const SizedBox(height: 12),
            
            FeatureCard(
              title: 'Tasbih - تسبیح',
              subtitle: 'Digital counter for Dhikr',
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
            
            const SizedBox(height: 12),
            
            FeatureCard(
              title: 'My Schedule - میرا شیڈول',
              subtitle: 'Custom Islamic routine builder',
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
            
            const SizedBox(height: 24),
            
            // Coming Soon
            Text(
              'Coming Soon',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Opacity(
              opacity: 0.5,
              child: Column(
                children: [
                  FeatureCard(
                    title: 'Hadith - حدیث',
                    subtitle: 'Authentic Hadith collection',
                    icon: Icons.book,
                    color: Colors.brown,
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  FeatureCard(
                    title: 'Dua - دعا',
                    subtitle: 'Daily duas and supplications',
                    icon: Icons.favorite,
                    color: Colors.pink,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
