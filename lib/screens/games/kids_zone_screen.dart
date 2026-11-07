import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import 'memory_game_levels.dart';
import 'prayer_quiz_levels.dart';
import 'names_puzzle_levels.dart';
import 'wudu_game_levels.dart';
import 'game_widgets.dart';

class KidsZoneScreen extends StatelessWidget {
  const KidsZoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final games = [
      _GameCard(
        title: 'Memory Match',
        icon: Icons.grid_on,
        levels: '50 Levels',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MemoryGameLevels()),
        ),
      ),
      _GameCard(
        title: 'Prayer Quiz',
        icon: Icons.quiz,
        levels: '50 Levels',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PrayerQuizLevels()),
        ),
      ),
      _GameCard(
        title: '99 Names Puzzle',
        icon: Icons.extension,
        levels: '99 Levels',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NamesPuzzleLevels()),
        ),
      ),
      _GameCard(
        title: 'Wudu Steps',
        icon: Icons.water_drop,
        levels: '12 Levels',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WuduGameLevels()),
        ),
      ),
    ];

    return Scaffold(
      body: GameScreenBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Games',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Learn, play, and make progress',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Consumer<UserProvider>(
                builder: (context, userProvider, _) {
                  final user = userProvider.currentUser;
                  if (user == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Card(
                      child: ListTile(
                        leading: Icon(
                          Icons.local_fire_department_rounded,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        title: Text(
                          '${user.points} points',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text('${user.streakDays}-day streak'),
                        trailing: const Icon(Icons.stars_rounded),
                      ),
                    ),
                  );
                },
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: 4,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    mainAxisExtent: 260,
                  ),
                  itemBuilder: (context, index) {
                    return games[index];
                  },
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
  final String levels;
  final VoidCallback onTap;

  const _GameCard({
    required this.title,
    required this.icon,
    required this.levels,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colors.primary.withOpacity(0.24)),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withOpacity(0.1),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              child: Icon(
                icon,
                size: 96,
                color: colors.primary.withOpacity(0.06),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 40, color: colors.primary),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      levels,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
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
