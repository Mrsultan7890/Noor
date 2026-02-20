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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.purple.shade400, Colors.pink.shade300, Colors.orange.shade300],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        '🎮 Kids Zone',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(blurRadius: 10, color: Colors.black26, offset: Offset(2, 2)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  padding: const EdgeInsets.all(20),
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  children: [
                    _GameCard(
                      title: 'Memory\nMatch',
                      icon: Icons.grid_on,
                      gradient: [Colors.blue.shade400, Colors.cyan.shade300],
                      levels: '50 Levels',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MemoryGameLevels())),
                    ),
                    _GameCard(
                      title: 'Prayer\nQuiz',
                      icon: Icons.quiz,
                      gradient: [Colors.orange.shade400, Colors.red.shade300],
                      levels: '50 Levels',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrayerQuizLevels())),
                    ),
                    _GameCard(
                      title: '99 Names\nPuzzle',
                      icon: Icons.extension,
                      gradient: [Colors.amber.shade400, Colors.yellow.shade300],
                      levels: '99 Levels',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NamesPuzzleLevels())),
                    ),
                    _GameCard(
                      title: 'Wudu\nSteps',
                      icon: Icons.water_drop,
                      gradient: [Colors.teal.shade400, Colors.green.shade300],
                      levels: '20 Levels',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WuduGameLevels())),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Color> gradient;
  final String levels;
  final VoidCallback onTap;

  const _GameCard({
    required this.title,
    required this.icon,
    required this.gradient,
    required this.levels,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: gradient[0].withOpacity(0.5), blurRadius: 15, offset: const Offset(0, 8)),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -20,
              right: -20,
              child: Icon(icon, size: 120, color: Colors.white.withOpacity(0.2)),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 40, color: Colors.white),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      levels,
                      style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
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
