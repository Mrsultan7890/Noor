import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../../models/arabic_course_model.dart';
import '../../providers/app_language_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/arabic_course_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/arabic_course_localizations.dart';
import '../../widgets/arabic_text.dart';
import '../../widgets/service_loading_view.dart';

Future<ArabicCourseProgress> _syncArabicProgressWithAccount({
  required BuildContext context,
  required UserProvider userProvider,
  required ArabicCourseProgressService progressService,
  required ArabicCourseProgress localProgress,
}) async {
  if (!userProvider.isAuthenticated) return localProgress;
  try {
    final requestProgress = await progressService.toSyncJson();
    final response =
        await userProvider.syncArabicCourseProgress(requestProgress);
    final serverProgress = response['progress'];
    if (serverProgress is! Map<String, dynamic>) {
      throw const FormatException(
        'Server returned invalid Arabic course progress.',
      );
    }
    return await progressService.mergeServerProgress(
      serverProgress,
      syncedHeartSpendIds:
          (requestProgress['heart_spend_ids'] as List).cast<String>().toSet(),
    );
  } catch (error) {
    debugPrint('Arabic course account sync failed: $error');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(arabicCourseText(
            context,
            'Your lesson is saved on this device, but account sync failed. '
            'It will retry next time.',
          )),
        ),
      );
    }
    return localProgress;
  }
}

class ArabicCourseRoadScreen extends StatefulWidget {
  const ArabicCourseRoadScreen({super.key});

  @override
  State<ArabicCourseRoadScreen> createState() => _ArabicCourseRoadScreenState();
}

class _ArabicCourseRoadScreenState extends State<ArabicCourseRoadScreen> {
  final _contentService = ArabicCourseService();
  final _progressService = ArabicCourseProgressService();
  ArabicCourseContent? _content;
  ArabicCourseProgress? _progress;
  Object? _loadError;
  bool _isLoading = true;
  String? _loadedLanguage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final language = context.watch<AppLanguageProvider>().languageCode;
    if (language == _loadedLanguage) return;
    _loadedLanguage = language;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load(language);
    });
  }

  Future<void> _load([String? languageCode]) async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final language =
          languageCode ?? context.read<AppLanguageProvider>().languageCode;
      final content = await _contentService.load(languageCode: language);
      final progress = await _progressService.load();
      if (!mounted) return;
      setState(() {
        _content = content;
        _progress = progress;
        _isLoading = false;
      });
      if (context.read<UserProvider>().isAuthenticated) {
        final syncedProgress = await _syncWithAccount(progress);
        if (mounted) {
          setState(() => _progress = syncedProgress);
        }
      }
    } on ArabicCourseLoadException catch (error) {
      debugPrint('Arabic course could not be loaded: $error');
      if (!mounted) return;
      setState(() {
        _loadError = error;
        _isLoading = false;
      });
    } catch (error) {
      debugPrint('Arabic course initialization failed: $error');
      if (!mounted) return;
      setState(() {
        _loadError = error;
        _isLoading = false;
      });
    }
  }

  Future<ArabicCourseProgress> _syncWithAccount(
    ArabicCourseProgress progress,
  ) =>
      _syncArabicProgressWithAccount(
        context: context,
        userProvider: context.read<UserProvider>(),
        progressService: _progressService,
        localProgress: progress,
      );

  bool _isLessonUnlocked(
    ArabicCourseContent content,
    ArabicCourseProgress progress,
    int levelIndex,
    int lessonIndex,
  ) {
    final previousLevels = content.levels.take(levelIndex);
    if (previousLevels.any(
      (level) => !level.lessons.every(
        (lesson) => progress.completedLessonIds.contains(lesson.id),
      ),
    )) {
      return false;
    }
    final lessons = content.levels[levelIndex].lessons;
    return lessonIndex == 0 ||
        lessons.take(lessonIndex).every(
              (lesson) => progress.completedLessonIds.contains(lesson.id),
            );
  }

  Future<void> _openLesson(int levelIndex, int index) async {
    final content = _content!;
    final progress = _progress!;
    final level = content.levels[levelIndex];
    final lesson = level.lessons[index];
    final wasCompleted = progress.completedLessonIds.contains(lesson.id);
    final unlocked = _isLessonUnlocked(content, progress, levelIndex, index);
    if (!unlocked) return;

    final completed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ArabicCourseLessonScreen(
          lesson: lesson,
          quizPrompt: level.quizPrompt,
          progressService: _progressService,
          contentService: _contentService,
        ),
      ),
    );
    if (completed != true || !mounted) return;
    var updated = await _progressService.completeLesson(lesson.id);
    if (!mounted) return;
    setState(() => _progress = updated);
    final userProvider = context.read<UserProvider>();
    if (userProvider.isAuthenticated) {
      updated = await _syncWithAccount(updated);
      if (mounted) {
        setState(() => _progress = updated);
      }
    } else if (!wasCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(arabicCourseText(
            context,
            'Lesson complete! +20 points',
          )),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final palette = AppTheme.palettes[theme.selectedTheme]!;
    return Scaffold(
      appBar: AppBar(
        title: Text(arabicCourseText(context, 'Arabic Course')),
      ),
      body: _isLoading
          ? const ServiceLoadingView(
              serviceName: 'Arabic Course',
              icon: Icons.translate,
            )
          : _loadError != null
              ? _LoadErrorView(onRetry: _load)
              : _content == null || _progress == null
                  ? _LoadErrorView(onRetry: _load)
                  : _buildRoad(context, palette),
    );
  }

  Widget _buildRoad(BuildContext context, NoorThemePalette palette) {
    final content = _content!;
    final progress = _progress!;
    final lessons = content.levels.expand((level) => level.lessons).toList();
    final completedCount = lessons
        .where((lesson) => progress.completedLessonIds.contains(lesson.id))
        .length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        _CourseHeader(
          palette: palette,
          title: arabicCourseText(context, 'Arabic Course'),
          completedCount: completedCount,
          lessonCount: lessons.length,
          points: progress.points,
          hearts: progress.hearts,
          isOffline: content.isOffline,
        ),
        const SizedBox(height: 8),
        Text(
          arabicCourseText(
            context,
            'Complete all lessons in a level to unlock the next one.',
          ),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        for (var levelIndex = 0;
            levelIndex < content.levels.length;
            levelIndex++)
          _buildLevelRoad(context, content, progress, levelIndex, palette),
      ],
    );
  }

  Widget _buildLevelRoad(
    BuildContext context,
    ArabicCourseContent content,
    ArabicCourseProgress progress,
    int levelIndex,
    NoorThemePalette palette,
  ) {
    final level = content.levels[levelIndex];
    final lessons = level.lessons;
    final completedCount = lessons
        .where((lesson) => progress.completedLessonIds.contains(lesson.id))
        .length;
    final continueIndex = lessons.indexWhere(
      (lesson) => !progress.completedLessonIds.contains(lesson.id),
    );
    final currentIndex =
        continueIndex == -1 ? lessons.length - 1 : continueIndex;
    final unlocked = _isLessonUnlocked(content, progress, levelIndex, 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Row(
          children: [
            Icon(
              unlocked ? Icons.menu_book_rounded : Icons.lock_rounded,
              color: unlocked
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Level ${level.order}: ${level.title}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            Text(
              '$completedCount/${lessons.length}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            const rowHeight = 142.0;
            final roadWidth = constraints.maxWidth;
            final nodeWidth = min(166.0, roadWidth * 0.44);
            return SizedBox(
              height: lessons.length * rowHeight,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _RoadPainter(
                        count: lessons.length,
                        accent: Theme.of(context).colorScheme.primary,
                        heightPerNode: rowHeight,
                      ),
                    ),
                  ),
                  for (var index = 0; index < lessons.length; index++)
                    _buildRoadNode(
                      context,
                      levelIndex,
                      index,
                      nodeWidth,
                      rowHeight,
                      roadWidth,
                      currentIndex,
                      palette,
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRoadNode(
    BuildContext context,
    int levelIndex,
    int index,
    double nodeWidth,
    double rowHeight,
    double roadWidth,
    int continueIndex,
    NoorThemePalette palette,
  ) {
    final content = _content!;
    final progress = _progress!;
    final lessons = content.levels[levelIndex].lessons;
    final lesson = lessons[index];
    final completed = progress.completedLessonIds.contains(lesson.id);
    final unlocked = _isLessonUnlocked(content, progress, levelIndex, index);
    final isCurrent = unlocked && !completed;
    final center = constraintsCenter(index, roadWidth, nodeWidth);
    final theme = Theme.of(context);
    return Positioned(
      top: index * rowHeight + 4,
      left: center - nodeWidth / 2,
      width: nodeWidth,
      height: rowHeight - 8,
      child: Semantics(
        button: unlocked,
        enabled: unlocked,
        label:
            '${arabicCourseText(context, 'Lesson')} ${index + 1}: ${lesson.title}',
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: unlocked ? () => _openLesson(levelIndex, index) : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: completed
                      ? palette.accent
                      : isCurrent
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surface,
                  border: Border.all(
                    color: palette.accent,
                    width: isCurrent ? 3 : 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: palette.gradientStart.withOpacity(0.22),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  completed
                      ? Icons.check_rounded
                      : unlocked
                          ? Icons.play_arrow_rounded
                          : Icons.lock_rounded,
                  color: completed
                      ? palette.gradientStart
                      : isCurrent
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                  size: 30,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${arabicCourseText(context, 'Lesson')} ${index + 1}',
                textAlign: TextAlign.center,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isCurrent ? theme.colorScheme.primary : null,
                ),
              ),
              Text(
                lesson.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall,
              ),
              if (index == continueIndex && isCurrent)
                Text(
                  arabicCourseText(context, 'Continue learning'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  double constraintsCenter(int index, double width, double nodeWidth) {
    final center = index.isEven ? width * 0.28 : width * 0.72;
    return center.clamp(nodeWidth / 2, width - nodeWidth / 2).toDouble();
  }
}

class _CourseHeader extends StatelessWidget {
  const _CourseHeader({
    required this.palette,
    required this.title,
    required this.completedCount,
    required this.lessonCount,
    required this.points,
    required this.hearts,
    required this.isOffline,
  });

  final NoorThemePalette palette;
  final String title;
  final int completedCount;
  final int lessonCount;
  final int points;
  final int hearts;
  final bool isOffline;

  @override
  Widget build(BuildContext context) {
    final progress = completedCount / lessonCount;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: palette.gradientColors),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: palette.gradientStart.withOpacity(0.22),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_stories_rounded,
                  color: Colors.white, size: 30),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.fade,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _CounterPill(
                icon: Icons.favorite_rounded,
                label: '$hearts/${ArabicCourseProgress.dailyHeartLimit}',
                color: const Color(0xFFFF8A80),
              ),
              _CounterPill(
                icon: Icons.stars_rounded,
                label: '$points',
                color: palette.secondaryAccent,
              ),
              if (isOffline)
                _CounterPill(
                  icon: Icons.cloud_off_rounded,
                  label: arabicCourseText(context, 'Offline'),
                  color: Colors.white,
                ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation(palette.secondaryAccent),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).round()}%  ·  $completedCount / $lessonCount '
            '${arabicCourseText(context, 'lessons complete')}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
          if (isOffline) ...[
            const SizedBox(height: 6),
            Text(
              arabicCourseText(context, 'Using saved lessons offline'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.82),
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CounterPill extends StatelessWidget {
  const _CounterPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.18),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 17, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
}

class _RoadPainter extends CustomPainter {
  const _RoadPainter({
    required this.count,
    required this.accent,
    required this.heightPerNode,
  });

  final int count;
  final Color accent;
  final double heightPerNode;

  @override
  void paint(Canvas canvas, Size size) {
    if (count < 2) return;
    final path = Path();
    final centerA = size.width * 0.28;
    final centerB = size.width * 0.72;
    final centerOffset = heightPerNode * 0.26;
    double xFor(int index) => index.isEven ? centerA : centerB;
    path.moveTo(xFor(0), centerOffset);
    for (var index = 1; index < count; index++) {
      final startY = (index - 1) * heightPerNode + centerOffset;
      final endY = index * heightPerNode + centerOffset;
      path.cubicTo(
        xFor(index - 1),
        startY + heightPerNode * 0.45,
        xFor(index),
        endY - heightPerNode * 0.45,
        xFor(index),
        endY,
      );
    }
    final paint = Paint()
      ..color = accent.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _RoadPainter oldDelegate) =>
      count != oldDelegate.count ||
      accent != oldDelegate.accent ||
      heightPerNode != oldDelegate.heightPerNode;
}

class _LoadErrorView extends StatelessWidget {
  const _LoadErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 48),
              const SizedBox(height: 12),
              Text(
                arabicCourseText(
                  context,
                  'Arabic lessons could not be loaded.',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(arabicCourseText(context, 'Try again')),
              ),
            ],
          ),
        ),
      );
}

class ArabicCourseLessonScreen extends StatefulWidget {
  const ArabicCourseLessonScreen({
    required this.lesson,
    required this.quizPrompt,
    required this.progressService,
    required this.contentService,
    super.key,
  });

  final ArabicCourseLesson lesson;
  final String quizPrompt;
  final ArabicCourseProgressService progressService;
  final ArabicCourseService contentService;

  @override
  State<ArabicCourseLessonScreen> createState() =>
      _ArabicCourseLessonScreenState();
}

class _ArabicCourseLessonScreenState extends State<ArabicCourseLessonScreen> {
  final _pageController = PageController();
  final _audioPlayer = AudioPlayer();
  int _currentPage = 0;
  bool _isLoadingAudio = false;

  @override
  void dispose() {
    _pageController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playItem(ArabicCourseItem item) async {
    setState(() => _isLoadingAudio = true);
    try {
      final file = await widget.contentService.audioFile(item.audioPath);
      await _audioPlayer.setAudioSource(
        AudioSource.file(file.path),
      );
      await _audioPlayer.play();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${arabicCourseText(context, 'Audio could not be played.')}: $error',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoadingAudio = false);
    }
  }

  Future<void> _startQuiz() async {
    final completed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ArabicCourseQuizScreen(
          lesson: widget.lesson,
          prompt: widget.quizPrompt,
          progressService: widget.progressService,
          contentService: widget.contentService,
        ),
      ),
    );
    if (completed != null && mounted) Navigator.pop(context, completed);
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    final item = lesson.items[_currentPage];
    final isLastPage = _currentPage == lesson.items.length - 1;
    return Scaffold(
      appBar: AppBar(
        title: Text(lesson.title),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${arabicCourseText(context, 'Item')} '
                  '${_currentPage + 1} / ${lesson.items.length}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: (_currentPage + 1) / lesson.items.length,
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: lesson.items.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) => _LessonItemView(
                lesson: lesson,
                item: lesson.items[index],
                showChart: index == 0,
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: _isLoadingAudio ? null : () => _playItem(item),
                    icon: _isLoadingAudio
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.volume_up_rounded),
                    tooltip: arabicCourseText(context, 'Listen'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: isLastPage
                          ? _startQuiz
                          : () => _pageController.nextPage(
                                duration: const Duration(milliseconds: 280),
                                curve: Curves.easeOut,
                              ),
                      child: Text(
                        isLastPage
                            ? arabicCourseText(context, 'Take the quiz')
                            : context.tr('Next'),
                      ),
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

class _LessonItemView extends StatelessWidget {
  const _LessonItemView({
    required this.lesson,
    required this.item,
    required this.showChart,
  });

  final ArabicCourseLesson lesson;
  final ArabicCourseItem item;
  final bool showChart;

  @override
  Widget build(BuildContext context) {
    final palette =
        AppTheme.palettes[context.watch<ThemeProvider>().selectedTheme]!;
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      children: [
        Text(
          lesson.objective,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (showChart && lesson.chart.isNotEmpty) ...[
          const SizedBox(height: 12),
          _InfoCard(
            title: arabicCourseText(context, 'Sound chart'),
            accent: palette.secondaryAccent,
            child: Column(
              children: [
                if (lesson.chart['mark'] != null)
                  ArabicText(
                    lesson.chart['mark']!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 44),
                  ),
                if (lesson.chart['letters'] != null)
                  ArabicText(
                    lesson.chart['letters']!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 25),
                  ),
                if (lesson.chart['alifExample'] != null)
                  ArabicText(
                    lesson.chart['alifExample']!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 30),
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
            child: Column(
              children: [
                ArabicText(
                  item.arabic,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.transliteration,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
                if (item.meaning != null) ...[
                  const SizedBox(height: 6),
                  Text(item.meaning!, textAlign: TextAlign.center),
                ],
              ],
            ),
          ),
        ),
        if (item.forms.isNotEmpty) ...[
          const SizedBox(height: 12),
          _InfoCard(
            title: arabicCourseText(context, 'Letter forms'),
            accent: palette.accent,
            child: Wrap(
              alignment: WrapAlignment.spaceAround,
              spacing: 16,
              runSpacing: 10,
              children: item.forms.entries
                  .map(
                    (entry) => Column(
                      children: [
                        Text(
                          arabicCourseText(context, entry.key),
                          style: theme.textTheme.labelSmall,
                        ),
                        ArabicText(
                          entry.value,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 30),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
        if (item.exampleArabic != null) ...[
          const SizedBox(height: 12),
          _InfoCard(
            title: arabicCourseText(context, 'Example'),
            accent: palette.secondaryAccent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ArabicText(
                  item.exampleArabic!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 36),
                ),
                if (item.exampleTransliteration != null)
                  Text(
                    item.exampleTransliteration!,
                    textAlign: TextAlign.center,
                  ),
                if (item.exampleMeaning != null)
                  Text(
                    item.exampleMeaning!,
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        _InfoCard(
          title: arabicCourseText(context, 'Lesson tip'),
          accent: palette.accent,
          child: Text(lesson.instruction),
        ),
        if (item.note != null) ...[
          const SizedBox(height: 12),
          _InfoCard(
            title: arabicCourseText(context, 'Note'),
            accent: palette.secondaryAccent,
            child: Text(item.note!),
          ),
        ],
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.accent,
    required this.child,
  });

  final String title;
  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              child,
            ],
          ),
        ),
      );
}

class ArabicCourseQuizScreen extends StatefulWidget {
  const ArabicCourseQuizScreen({
    required this.lesson,
    required this.prompt,
    required this.progressService,
    required this.contentService,
    super.key,
  });

  final ArabicCourseLesson lesson;
  final String prompt;
  final ArabicCourseProgressService progressService;
  final ArabicCourseService contentService;

  @override
  State<ArabicCourseQuizScreen> createState() => _ArabicCourseQuizScreenState();
}

class _ArabicCourseQuizScreenState extends State<ArabicCourseQuizScreen> {
  final _audioPlayer = AudioPlayer();
  late List<ArabicCourseItem> _questions;
  late ArabicCourseProgress _progress;
  int _questionIndex = 0;
  int _correctCount = 0;
  String? _selectedItemId;
  bool _checked = false;
  bool _isLoading = true;
  bool _isLoadingAudio = false;
  bool _isChecking = false;
  bool _outOfHearts = false;
  bool _failed = false;
  bool _passed = false;
  Object? _progressError;
  List<ArabicCourseItem> _options = const [];

  ArabicCourseItem get _question => _questions[_questionIndex];

  @override
  void initState() {
    super.initState();
    _questions = widget.lesson.items.toList()..shuffle();
    _questions = _questions.take(widget.lesson.quizQuestionCount).toList();
    _setOptions(_questions.first);
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try {
      final progress = await widget.progressService.load();
      if (!mounted) return;
      setState(() {
        _progress = progress;
        _isLoading = false;
        _outOfHearts = progress.hearts == 0;
      });
    } catch (error) {
      debugPrint('Arabic quiz progress could not be loaded: $error');
      if (!mounted) return;
      setState(() {
        _progressError = error;
        _isLoading = false;
      });
    }
  }

  Future<void> _syncProgressWithAccount(
    ArabicCourseProgress progress,
  ) async {
    final userProvider = context.read<UserProvider>();
    if (!userProvider.isAuthenticated) return;
    final synced = await _syncArabicProgressWithAccount(
      context: context,
      userProvider: userProvider,
      progressService: widget.progressService,
      localProgress: progress,
    );
    if (mounted) setState(() => _progress = synced);
  }

  void _setOptions(ArabicCourseItem target) {
    final distractors = widget.lesson.items
        .where((item) => item.id != target.id)
        .toList()
      ..shuffle();
    _options = [target, ...distractors.take(3)]..shuffle();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playQuestion() async {
    setState(() => _isLoadingAudio = true);
    try {
      final file = await widget.contentService.audioFile(_question.audioPath);
      await _audioPlayer.setAudioSource(
        AudioSource.file(file.path),
      );
      await _audioPlayer.play();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${arabicCourseText(context, 'Audio could not be played.')}: $error',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoadingAudio = false);
    }
  }

  Future<void> _checkAnswer() async {
    if (_selectedItemId == null || _checked || _isChecking) return;
    final isCorrect = _selectedItemId == _question.id;
    if (!isCorrect) {
      setState(() => _isChecking = true);
      try {
        final updated = await widget.progressService.useHeart();
        if (!mounted) return;
        setState(() {
          _progress = updated;
          _outOfHearts = updated.hearts == 0;
        });
        unawaited(_syncProgressWithAccount(updated));
      } catch (error) {
        if (!mounted) return;
        setState(() => _isChecking = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${arabicCourseText(context, 'Could not save your heart.')}: '
              '$error',
            ),
          ),
        );
        return;
      }
    }
    setState(() {
      _checked = true;
      _isChecking = false;
      if (isCorrect) _correctCount++;
    });
  }

  Future<void> _advance() async {
    if (_questionIndex + 1 < _questions.length) {
      setState(() {
        _questionIndex++;
        _selectedItemId = null;
        _checked = false;
        _setOptions(_question);
      });
      return;
    }
    final requiredCorrect = _questions.length >= 3 ? 2 : _questions.length;
    if (_correctCount >= requiredCorrect) {
      setState(() => _passed = true);
    } else {
      setState(() => _failed = true);
    }
  }

  void _retry() {
    setState(() {
      _questions = widget.lesson.items.toList()..shuffle();
      _questions = _questions.take(widget.lesson.quizQuestionCount).toList();
      _questionIndex = 0;
      _correctCount = 0;
      _selectedItemId = null;
      _checked = false;
      _failed = false;
      _setOptions(_questions.first);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(arabicCourseText(context, 'Lesson quiz')),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _progressError != null
              ? _buildProgressError(context)
              : _outOfHearts
                  ? _buildOutOfHearts(context)
                  : _passed
                      ? _buildPassed(context)
                      : _failed
                          ? _buildFailed(context)
                          : _buildQuestion(context),
    );
  }

  Widget _buildQuestion(BuildContext context) {
    final question = _question;
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${arabicCourseText(context, 'Question')} '
                '${_questionIndex + 1} / ${_questions.length}',
                style: theme.textTheme.titleMedium,
              ),
            ),
            _CounterPill(
              icon: Icons.favorite_rounded,
              label: '${_progress.hearts}',
              color: const Color(0xFFFF8A80),
            ),
          ],
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: (_questionIndex + 1) / _questions.length,
        ),
        const SizedBox(height: 22),
        Text(widget.prompt, style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Column(
              children: [
                IconButton.filled(
                  onPressed: _isLoadingAudio ? null : _playQuestion,
                  icon: _isLoadingAudio
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.volume_up_rounded, size: 30),
                  iconSize: 58,
                ),
                Text(arabicCourseText(context, 'Listen again')),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        for (final option in _options)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _AnswerChoice(
              item: option,
              isSelected: _selectedItemId == option.id,
              isCorrect: _checked && option.id == question.id,
              isWrongSelection: _checked &&
                  _selectedItemId == option.id &&
                  option.id != question.id,
              enabled: !_checked,
              onTap: () => setState(() => _selectedItemId = option.id),
            ),
          ),
        if (_checked) ...[
          const SizedBox(height: 4),
          Text(
            _selectedItemId == question.id
                ? arabicCourseText(context, 'Correct!')
                : arabicCourseText(context, 'Not quite. One heart was used.'),
            style: theme.textTheme.titleMedium?.copyWith(
              color: _selectedItemId == question.id
                  ? Colors.green
                  : theme.colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
        const SizedBox(height: 12),
        FilledButton(
          onPressed: !_checked
              ? (_selectedItemId == null || _isChecking ? null : _checkAnswer)
              : _outOfHearts
                  ? () => Navigator.pop(context, false)
                  : _advance,
          child: Text(
            !_checked
                ? arabicCourseText(context, 'Check answer')
                : _outOfHearts
                    ? arabicCourseText(context, 'Back to learning path')
                    : arabicCourseText(context, 'Continue'),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressError(BuildContext context) => _QuizResultView(
        icon: Icons.error_outline_rounded,
        title: arabicCourseText(
          context,
          'Learning progress could not be loaded.',
        ),
        message: arabicCourseText(
          context,
          'Your saved progress is unavailable. Please try again later.',
        ),
        buttonLabel: arabicCourseText(context, 'Back to learning path'),
        onPressed: () => Navigator.pop(context, false),
      );

  Widget _buildOutOfHearts(BuildContext context) => _QuizResultView(
        icon: Icons.favorite_border_rounded,
        title: arabicCourseText(context, 'No hearts left today'),
        message: arabicCourseText(
          context,
          'Your hearts refill tomorrow. Premium is not available yet.',
        ),
        buttonLabel: arabicCourseText(context, 'Back to learning path'),
        onPressed: () => Navigator.pop(context, false),
      );

  Widget _buildPassed(BuildContext context) => _QuizResultView(
        icon: Icons.emoji_events_rounded,
        title: arabicCourseText(context, 'Stage complete!'),
        message: arabicCourseText(context, 'You passed the lesson quiz.'),
        buttonLabel: arabicCourseText(context, 'Continue'),
        onPressed: () => Navigator.pop(context, true),
      );

  Widget _buildFailed(BuildContext context) => _QuizResultView(
        icon: Icons.refresh_rounded,
        title: arabicCourseText(context, 'Try the quiz again'),
        message: arabicCourseText(
          context,
          'You need two correct answers to pass this stage.',
        ),
        buttonLabel: arabicCourseText(context, 'Try again'),
        onPressed: _retry,
        secondaryLabel: arabicCourseText(context, 'Back to learning path'),
        onSecondaryPressed: () => Navigator.pop(context, false),
      );
}

class _AnswerChoice extends StatelessWidget {
  const _AnswerChoice({
    required this.item,
    required this.isSelected,
    required this.isCorrect,
    required this.isWrongSelection,
    required this.enabled,
    required this.onTap,
  });

  final ArabicCourseItem item;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrongSelection;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final border = isCorrect
        ? Colors.green
        : isWrongSelection
            ? theme.colorScheme.error
            : isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant;
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border, width: isSelected ? 2 : 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: ArabicText(
                  item.arabic,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isCorrect)
                const Icon(Icons.check_circle_rounded, color: Colors.green),
              if (isWrongSelection)
                Icon(Icons.cancel_rounded, color: theme.colorScheme.error),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuizResultView extends StatelessWidget {
  const _QuizResultView({
    required this.icon,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onPressed,
    this.secondaryLabel,
    this.onSecondaryPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback onPressed;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryPressed;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 72,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onPressed,
                  child: Text(buttonLabel),
                ),
              ),
              if (secondaryLabel != null) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: onSecondaryPressed,
                  child: Text(secondaryLabel!),
                ),
              ],
            ],
          ),
        ),
      );
}
