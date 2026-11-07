import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class GameScreenBackground extends StatelessWidget {
  const GameScreenBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: context.watch<ThemeProvider>().backgroundGradient,
      ),
      child: child,
    );
  }
}

class GameLevelCard extends StatelessWidget {
  const GameLevelCard({
    required this.level,
    required this.title,
    required this.subtitle,
    required this.unlocked,
    required this.onTap,
    this.stars = 0,
    super.key,
  });

  final int level;
  final String title;
  final String subtitle;
  final bool unlocked;
  final VoidCallback? onTap;
  final int stars;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: unlocked ? colors.primary : colors.primary.withOpacity(0.12),
          foregroundColor: unlocked ? colors.onPrimary : colors.onSurface.withOpacity(0.65),
          child: unlocked ? Text('$level') : const Icon(Icons.lock_outline),
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: stars > 0
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  3,
                  (index) => Icon(
                    index < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: colors.tertiary,
                    size: 19,
                  ),
                ),
              )
            : Icon(
                unlocked ? Icons.play_circle_outline : Icons.lock_outline,
                color: unlocked ? colors.primary : colors.onSurface.withOpacity(0.45),
              ),
        onTap: onTap,
      ),
    );
  }
}
