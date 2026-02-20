import 'package:flutter/material.dart';
import 'memory_game_levels.dart';
import 'prayer_quiz_levels.dart';
import 'names_puzzle_levels.dart';
import 'wudu_game_levels.dart';

class KidsZoneScreen extends StatelessWidget {
  const KidsZoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kids Zone - بچوں کا زون'),
        backgroundColor: Colors.purple,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple.shade100, Colors.blue.shade100],
          ),
        ),
        child: GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.all(16),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _GameCard(
              title: 'Memory Match',
              subtitle: '50 Levels',
              icon: Icons.grid_on,
              color: Colors.pink,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MemoryGameLevels())),
            ),
            _GameCard(
              title: 'Prayer Quiz',
              subtitle: '50 Levels',
              icon: Icons.quiz,
              color: Colors.orange,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrayerQuizLevels())),
            ),
            _GameCard(
              title: '99 Names',
              subtitle: '99 Levels',
              icon: Icons.star,
              color: Colors.amber,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NamesPuzzleLevels())),
            ),
            _GameCard(
              title: 'Wudu Steps',
              subtitle: '20 Levels',
              icon: Icons.water_drop,
              color: Colors.blue,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WuduGameLevels())),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _GameCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, color.withOpacity(0.7)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 64, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
