import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_provider.dart';
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
import '../profile/profile_screen.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../tasks/daily_tasks_screen.dart';
import '../auth/login_screen.dart';
import '../stories/stories_home_screen.dart';

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
          // Profile Section
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              if (userProvider.isAuthenticated) {
                return Column(
                  children: [
                    const _SectionHeader(title: 'Account', icon: Icons.person),
                    _FeatureTile(
                      title: 'My Profile',
                      subtitle: 'View stats and progress',
                      icon: Icons.account_circle,
                      color: Colors.blue,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfileScreen()),
                      ),
                    ),
                    _FeatureTile(
                      title: 'Leaderboard',
                      subtitle: 'Global & country rankings',
                      icon: Icons.leaderboard,
                      color: Colors.amber,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              } else {
                return Column(
                  children: [
                    Card(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      child: ListTile(
                        leading: const Icon(Icons.login, color: Color(0xFF2E7D32)),
                        title: const Text('Login to sync your progress'),
                        subtitle: const Text('Track stats & compete on leaderboard'),
                        trailing: ElevatedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          ),
                          child: const Text('Login'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              }
            },
          ),
          
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
            title: 'Daily Tasks',
            subtitle: 'Track your daily Islamic activities',
            icon: Icons.checklist,
            color: Colors.green,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DailyTasksScreen()),
            ),
          ),
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
            title: 'Islamic Stories',
            subtitle: 'Seerat, Sahaba & Prophets stories',
            icon: Icons.auto_stories,
            color: Colors.deepOrange,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StoriesHomeScreen()),
            ),
          ),
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
          
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              if (userProvider.isAuthenticated) {
                return _FeatureTile(
                  title: 'Logout',
                  subtitle: 'Sign out from your account',
                  icon: Icons.logout,
                  color: Colors.red,
                  onTap: () async {
                    await userProvider.logout();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Logged out successfully')),
                      );
                    }
                  },
                );
              }
              return const SizedBox.shrink();
            },
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
