import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../tasbih/tasbih_screen.dart';
import '../schedule/schedule_list_screen.dart';
import '../prayer/prayer_times_screen.dart';
import '../qibla/qibla_screen.dart';
import '../hadith/hadith_screen.dart';
import '../dua/dua_screen.dart';
import '../names/names_screen.dart';
import '../games/kids_zone_screen.dart';
import '../ramadan/ramadan_home_screen.dart';
import '../settings/settings_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

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
        title: const Text('More - مزید'),
        automaticallyImplyLeading: false,
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_isRamadanActive()) ...[
            const _SectionHeader(title: 'Ramadan Special', icon: Icons.nightlight_round),
            _FeatureTile(
              title: 'Ramadan Features',
              subtitle: 'Sehri/Iftar Timer & Roza Counter',
              icon: Icons.nightlight_round,
              color: Colors.purple,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RamadanHomeScreen()),
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          const _SectionHeader(title: 'Daily Tools', icon: Icons.today),
          _FeatureTile(
            title: 'Tasbih Counter',
            subtitle: 'Digital Dhikr counter',
            icon: Icons.circle_outlined,
            color: Colors.teal,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TasbihScreen()),
            ),
          ),
          _FeatureTile(
            title: 'My Schedule',
            subtitle: 'Islamic routine builder',
            icon: Icons.schedule,
            color: Colors.orange,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ScheduleListScreen()),
            ),
          ),
          _FeatureTile(
            title: 'Prayer Times',
            subtitle: 'Daily Salah timings',
            icon: Icons.access_time,
            color: Colors.blue,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PrayerTimesScreen()),
            ),
          ),
          _FeatureTile(
            title: 'Qibla Direction',
            subtitle: 'Find direction to Kaaba',
            icon: Icons.explore,
            color: Colors.indigo,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const QiblaScreen()),
            ),
          ),
          
          const SizedBox(height: 24),
          
          const _SectionHeader(title: 'Islamic Knowledge', icon: Icons.book),
          _FeatureTile(
            title: 'Hadith',
            subtitle: 'Authentic Hadith collection',
            icon: Icons.book,
            color: Colors.brown,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HadithScreen()),
            ),
          ),
          _FeatureTile(
            title: 'Dua',
            subtitle: 'Daily duas & supplications',
            icon: Icons.favorite,
            color: Colors.pink,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DuaScreen()),
            ),
          ),
          _FeatureTile(
            title: '99 Names of Allah',
            subtitle: 'Asma ul Husna',
            icon: Icons.star,
            color: Colors.amber,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NamesScreen()),
            ),
          ),
          
          const SizedBox(height: 24),
          
          const _SectionHeader(title: 'Kids Zone', icon: Icons.child_care),
          _FeatureTile(
            title: 'Islamic Games',
            subtitle: '219+ Levels for Kids',
            icon: Icons.games,
            color: Colors.deepPurple,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const KidsZoneScreen()),
            ),
          ),
          
          const SizedBox(height: 24),
          
          const _SectionHeader(title: 'Settings', icon: Icons.settings),
          _FeatureTile(
            title: 'App Settings',
            subtitle: 'Preferences & configurations',
            icon: Icons.settings,
            color: Colors.grey,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ),
          ),
          
          const SizedBox(height: 24),
          
          Center(
            child: Column(
              children: [
                Text(
                  'Noor - نور',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Islamic Companion App',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FeatureTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
