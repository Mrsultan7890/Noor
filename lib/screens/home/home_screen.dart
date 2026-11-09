import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/update_service.dart';
import '../../services/prayer_notification_service.dart';
import '../../services/prayer_times_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../screens/quran/quran_list_screen.dart';
import '../../screens/quran/mushaf_quran_screen.dart';
import '../../screens/quran/enhanced_quran_reader_screen.dart';
import '../../screens/learning/arabic_alphabet_screen.dart';
import '../../models/quran_model.dart';
import '../../models/schedule_model.dart';
import '../../screens/quran/quran_reader_screen.dart';
import '../../screens/tasbih/tasbih_screen.dart';
import '../../screens/schedule/schedule_list_screen.dart';
import '../../screens/prayer/prayer_times_screen.dart';
import '../../screens/qibla/qibla_screen.dart';
import '../../widgets/feature_card.dart';
import '../../providers/theme_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/app_language_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/arabic_text.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PrayerTimesService _prayerTimesService = PrayerTimesService();
  Timer? _prayerCountdownTimer;
  DateTime? _prayerTimesDate;
  String? _nextPrayerName;
  Duration _timeUntilNextPrayer = Duration.zero;
  Surah? _lastReadSurah;
  bool _isLoadingPrayerSummary = false;
  bool _prayerSummaryFailed = false;

  @override
  void initState() {
    super.initState();
    _checkForUpdates();
    _loadLastReadSurah();
    _loadPrayerSummary();
    _prayerCountdownTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _updatePrayerCountdown(),
    );
  }

  @override
  void dispose() {
    _prayerCountdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadLastReadSurah() async {
    final preferences = await SharedPreferences.getInstance();
    final number = preferences.getInt('quran_last_read_surah_number');
    if (number == null || !mounted) return;
    setState(() {
      _lastReadSurah = Surah(
        number: number,
        name: preferences.getString('quran_last_read_surah_name') ?? '',
        englishName:
            preferences.getString('quran_last_read_surah_english_name') ??
                'Surah $number',
        englishNameTranslation:
            preferences.getString('quran_last_read_surah_translation') ?? '',
        numberOfAyahs:
            preferences.getInt('quran_last_read_surah_ayah_count') ?? 0,
        revelationType:
            preferences.getString('quran_last_read_surah_revelation_type') ??
                '',
      );
    });
  }

  Future<void> _loadPrayerSummary() async {
    if (_isLoadingPrayerSummary) return;
    _isLoadingPrayerSummary = true;
    try {
      final location = await PrayerNotificationService.getSavedLocation();
      if (location == null) return;
      final prayerTimes = await _prayerTimesService.getPrayerTimes(
        latitude: location.latitude,
        longitude: location.longitude,
      );
      if (!mounted) return;
      _prayerTimesDate = DateTime.now();
      setState(() {
        _prayerSummaryFailed = false;
        _nextPrayerName = _prayerTimesService.getNextPrayer(prayerTimes);
        _timeUntilNextPrayer =
            _prayerTimesService.getTimeUntilNext(prayerTimes);
      });
    } catch (error, stackTrace) {
      debugPrint('Could not load the home prayer summary: $error\n$stackTrace');
      if (mounted) setState(() => _prayerSummaryFailed = true);
    } finally {
      _isLoadingPrayerSummary = false;
    }
  }

  void _updatePrayerCountdown() {
    if (!mounted || _nextPrayerName == null) return;
    final now = DateTime.now();
    if (_prayerTimesDate == null ||
        now.year != _prayerTimesDate!.year ||
        now.month != _prayerTimesDate!.month ||
        now.day != _prayerTimesDate!.day) {
      if (!_prayerSummaryFailed) unawaited(_loadPrayerSummary());
      return;
    }
    if (_timeUntilNextPrayer > Duration.zero) {
      setState(() {
        _timeUntilNextPrayer -= const Duration(minutes: 1);
      });
    } else if (!_prayerSummaryFailed) {
      unawaited(_loadPrayerSummary());
    }
  }

  Future<void> _openPrayerTimes() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrayerTimesScreen()),
    );
    if (mounted) unawaited(_loadPrayerSummary());
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
            Text('Current: ${info['currentVersion']}',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 16),
            const Text('What\'s New:',
                style: TextStyle(fontWeight: FontWeight.bold)),
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

  @override
  Widget build(BuildContext context) {
    final palette =
        AppTheme.palettes[context.watch<ThemeProvider>().selectedTheme]!;
    return Scaffold(
      appBar: AppBar(
        title: const ArabicLabel(
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
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: palette.gradientColors),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.wb_sunny, color: Colors.white, size: 32),
                        SizedBox(width: 12),
                        Expanded(
                          child: ArabicText(
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
                      context.tr('Welcome to Noor - Your Islamic Companion'),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _NextPrayerCard(
              prayerName: _nextPrayerName,
              timeUntil: _timeUntilNextPrayer,
              hasError: _prayerSummaryFailed,
              onTap: _openPrayerTimes,
            ),
            const SizedBox(height: 12),
            const _TodayScheduleCard(),
            if (_lastReadSurah != null) ...[
              const SizedBox(height: 12),
              _ContinueReadingCard(
                surah: _lastReadSurah!,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        QuranReaderScreen(surah: _lastReadSurah!),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Text(
              context.tr('Quick Access'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickAccessCard(
                    title: context.tr('Quran'),
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
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickAccessCard(
                    title: context.tr('Mushaf'),
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
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickAccessCard(
                    title: context.tr('Tasbih'),
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
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickAccessCard(
                    title: context.tr('Qibla'),
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
            Text(
              context.tr('Featured'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            FeatureCard(
              title: context.tr('Learn Quran with Audio'),
              subtitle:
                  context.tr('Transliteration, Word-by-Word & Recitation'),
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
                        englishNameTranslation: 'The Opening',
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
              title: context.tr('Learn Arabic Alphabet'),
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
              title: context.tr('My Schedule'),
              subtitle: context.tr('Build your Islamic routine'),
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
              title: context.tr('Prayer Times'),
              subtitle: context.tr('Daily Salah timings'),
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

class _NextPrayerCard extends StatelessWidget {
  final String? prayerName;
  final Duration timeUntil;
  final bool hasError;
  final VoidCallback onTap;

  const _NextPrayerCard({
    required this.prayerName,
    required this.timeUntil,
    required this.hasError,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hours = timeUntil.inHours.clamp(0, 999).toString().padLeft(2, '0');
    final minutes = (timeUntil.inMinutes % 60).clamp(0, 59).toString().padLeft(
          2,
          '0',
        );
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.mosque)),
        title: Text(
          prayerName == null
              ? context.tr('Prayer Times')
              : '${context.tr('Next Prayer')}: ${context.tr(prayerName!)}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          prayerName == null
              ? hasError
                  ? context.tr(
                      'Prayer times could not be refreshed. Tap to try again.')
                  : context.tr('Set up your location to see the next prayer')
              : context.tr('In {time}').replaceAll('{time}', '$hours:$minutes'),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _TodayScheduleCard extends StatelessWidget {
  const _TodayScheduleCard();

  @override
  Widget build(BuildContext context) {
    return Consumer<ScheduleProvider>(
      builder: (context, provider, child) {
        final schedules = provider.schedules
            .where((schedule) => schedule.isRecurringToday)
            .toList();
        final completed =
            schedules.where((schedule) => schedule.wasCompletedToday).length;
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ScheduleListScreen(),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.checklist),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          context.tr("Today's routine"),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text('$completed/${schedules.length}'),
                    ],
                  ),
                  if (provider.isLoading) ...[
                    const SizedBox(height: 12),
                    const LinearProgressIndicator(),
                  ] else if (provider.loadError != null) ...[
                    const SizedBox(height: 8),
                    Text(context.tr('Your routine could not be loaded.')),
                  ] else if (schedules.isEmpty) ...[
                    const SizedBox(height: 8),
                    Text(context.tr('Add a routine to build a steady habit.')),
                  ] else ...[
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: completed / schedules.length,
                    ),
                    const SizedBox(height: 8),
                    for (final schedule in schedules.take(3))
                      _SchedulePreview(schedule: schedule),
                    if (schedules.length > 3)
                      Text('+ ${schedules.length - 3} more'),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SchedulePreview extends StatelessWidget {
  final Schedule schedule;

  const _SchedulePreview({required this.schedule});

  @override
  Widget build(BuildContext context) {
    final time = TimeOfDay.fromDateTime(schedule.time).format(context);
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(
            schedule.wasCompletedToday
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            size: 18,
            color: schedule.wasCompletedToday
                ? Theme.of(context).colorScheme.primary
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(schedule.title,
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          Text(time),
        ],
      ),
    );
  }
}

class _ContinueReadingCard extends StatelessWidget {
  final Surah surah;
  final VoidCallback onTap;

  const _ContinueReadingCard({
    required this.surah,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.menu_book)),
        title: Text(
          context.tr('Continue reading'),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle:
            Text('${surah.englishName} · ${surah.englishNameTranslation}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
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
              const SizedBox(height: 12),
              Text(
                context.tr(title),
                style: const TextStyle(
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
