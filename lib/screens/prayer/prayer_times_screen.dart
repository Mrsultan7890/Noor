import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import 'dart:async';
import 'dart:convert';
import '../../models/prayer_times_model.dart';
import '../../services/prayer_times_service.dart';
import '../../services/prayer_notification_service.dart';
import '../../providers/user_provider.dart';
import '../../utils/activity_feedback.dart';
import '../../utils/user_friendly_error.dart';
import '../../providers/app_language_provider.dart';
import '../../widgets/service_loading_view.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen>
    with WidgetsBindingObserver {
  final PrayerTimesService _service = PrayerTimesService();
  PrayerTimes? _prayerTimes;
  bool _isLoading = true;
  Timer? _timer;
  Duration _timeUntilNext = Duration.zero;
  String _nextPrayer = '';
  String? _errorMessage;
  String? _notificationError;
  List<PrayerLog> _todayLogs = [];
  bool _isFetchingPrayerTimes = false;
  bool _reloadPrayerTimesWhenIdle = false;
  AsrSchool _asrSchool = AsrSchool.hanafi;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPrayerTimes();
    _loadAsrSchool();
    _loadTodayLogs();
    _timer =
        Timer.periodic(const Duration(seconds: 1), (_) => _updateCountdown());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadPrayerTimes();
    }
  }

  Future<void> _loadPrayerTimes() async {
    if (_isFetchingPrayerTimes) {
      _reloadPrayerTimesWhenIdle = true;
      return;
    }
    _isFetchingPrayerTimes = true;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _notificationError = null;
    });

    try {
      final position = await _service.getCurrentLocation();
      final times = await _service.getPrayerTimes(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      if (!mounted) return;

      await PrayerNotificationService.saveLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool('prayer_notifications_enabled') ?? true) {
        try {
          await PrayerNotificationService.schedulePrayerNotifications(
            times,
            latitude: position.latitude,
            longitude: position.longitude,
          );
        } catch (e) {
          debugPrint('Could not schedule prayer reminders: $e');
          _notificationError = UserFriendlyError.notification(e);
        }
      }

      if (!mounted) return;
      setState(() {
        _prayerTimes = times;
        _nextPrayer = _service.getNextPrayer(times);
        _timeUntilNext = _service.getTimeUntilNext(times);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Could not load prayer times: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage = UserFriendlyError.prayerTimes(e);
        _isLoading = false;
      });
    } finally {
      _isFetchingPrayerTimes = false;
      if (_reloadPrayerTimesWhenIdle && mounted) {
        _reloadPrayerTimesWhenIdle = false;
        unawaited(_loadPrayerTimes());
      }
    }
  }

  Future<void> _loadAsrSchool() async {
    try {
      final school = await _service.getAsrSchool();
      if (mounted) setState(() => _asrSchool = school);
    } catch (error, stackTrace) {
      debugPrint(
          'Could not load the Asr calculation setting: $error\n$stackTrace');
    }
  }

  Future<void> _showAsrSchoolPicker() async {
    final selectedSchool = await showModalBottomSheet<AsrSchool>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Text(
                'Asr calculation',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            for (final school in AsrSchool.values)
              RadioListTile<AsrSchool>(
                value: school,
                groupValue: _asrSchool,
                title: Text('${school.label} method'),
                subtitle: Text(
                  school == AsrSchool.hanafi
                      ? 'Asr begins when an object’s shadow is twice its height.'
                      : 'Asr begins when an object’s shadow equals its height.',
                ),
                onChanged: (value) => Navigator.pop(context, value),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (selectedSchool == null || selectedSchool == _asrSchool || !mounted) {
      return;
    }

    try {
      await _service.setAsrSchool(selectedSchool);
      if (!mounted) return;
      setState(() => _asrSchool = selectedSchool);
      await _loadPrayerTimes();
    } catch (error, stackTrace) {
      debugPrint(
          'Could not update the Asr calculation setting: $error\n$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Could not update the Asr setting. Please try again.'),
          ),
        );
      }
    }
  }

  void _updateCountdown() {
    if (_prayerTimes != null) {
      setState(() {
        _timeUntilNext = _service.getTimeUntilNext(_prayerTimes!);
        _nextPrayer = _service.getNextPrayer(_prayerTimes!);
      });
    }
  }

  Future<void> _loadTodayLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      final today = DateTime.now().toIso8601String().split('T')[0];
      final logsJson = prefs.getString('prayer_logs_$today');
      if (logsJson == null) return;
      final decoded = json.decode(logsJson) as List<dynamic>;
      setState(() {
        _todayLogs = decoded.map((e) => PrayerLog.fromJson(e)).toList();
      });
    } catch (error, stackTrace) {
      debugPrint('Could not load today\'s prayer log: $error\n$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Today’s prayer log could not be loaded.'),
          ),
        );
      }
    }
  }

  Future<void> _logPrayer(String prayer) async {
    if (_isPrayerLogged(prayer)) return;
    final log = PrayerLog(
      prayer: prayer,
      timestamp: DateTime.now(),
      onTime: true,
    );

    final updatedLogs = [..._todayLogs, log];
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      await prefs.setString(
        'prayer_logs_$today',
        json.encode(updatedLogs.map((e) => e.toJson()).toList()),
      );
    } catch (error, stackTrace) {
      debugPrint('Could not save prayer log: $error\n$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Could not save this prayer log. Please try again.')),
        );
      }
      return;
    }
    if (!mounted) return;
    _todayLogs = updatedLogs;
    setState(() {});

    if (!mounted) return;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.isAuthenticated) {
      await logActivityWithFeedback(
        context: context,
        userProvider: userProvider,
        activityType: 'prayer_logged',
        points: 5,
        metadata: {'prayer': prayer, 'time': DateTime.now().toIso8601String()},
        activityName: '$prayer prayer',
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('$prayer logged. Sign in to sync profile points.')),
      );
    }
  }

  bool _isPrayerLogged(String prayer) {
    return _todayLogs.any((log) => log.prayer == prayer);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Prayer Times')),
        actions: [
          IconButton(
            tooltip: context.tr('Asr calculation method'),
            icon: const Icon(Icons.tune),
            onPressed: _showAsrSchoolPicker,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPrayerTimes,
          ),
        ],
      ),
      body: _isLoading
          ? const ServiceLoadingView(
              serviceName: 'Prayer Times',
              icon: Icons.access_time,
            )
          : _errorMessage != null || _prayerTimes == null
              ? _buildErrorState()
              : RefreshIndicator(
                  onRefresh: _loadPrayerTimes,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        if (_notificationError != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              _notificationError!,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.error),
                            ),
                          ),
                        _buildAsrMethodInfo(),
                        const SizedBox(height: 12),
                        _buildNextPrayerCard(),
                        const SizedBox(height: 24),
                        _buildPrayersList(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildAsrMethodInfo() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.calculate_outlined),
        title: Text(context.tr('Asr calculation')),
        subtitle:
            Text('${context.tr(_asrSchool.label)} ${context.tr('method')}'),
        trailing: const Icon(Icons.tune),
        onTap: _showAsrSchoolPicker,
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(_errorMessage ?? context.tr('Prayer times are unavailable.')),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadPrayerTimes,
            child: Text(context.tr('Try again')),
          ),
        ],
      ),
    );
  }

  Widget _buildNextPrayerCard() {
    final hours = _timeUntilNext.inHours;
    final minutes = _timeUntilNext.inMinutes % 60;
    final seconds = _timeUntilNext.inSeconds % 60;
    final theme = Theme.of(context);
    final foreground = theme.brightness == Brightness.dark
        ? Colors.white
        : theme.colorScheme.onSurface;
    final timeBoxBackground = theme.brightness == Brightness.dark
        ? Colors.white.withOpacity(0.2)
        : theme.colorScheme.onSurface.withOpacity(0.08);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: context.watch<ThemeProvider>().backgroundGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            context.tr('Next Prayer'),
            style: TextStyle(
              color: foreground.withOpacity(0.75),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _nextPrayer,
            style: TextStyle(
              color: foreground,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _TimeBox(
                value: hours,
                label: context.tr('Hours'),
                foreground: foreground,
                background: timeBoxBackground,
              ),
              const SizedBox(width: 8),
              Text(':', style: TextStyle(color: foreground, fontSize: 24)),
              const SizedBox(width: 8),
              _TimeBox(
                value: minutes,
                label: context.tr('Min'),
                foreground: foreground,
                background: timeBoxBackground,
              ),
              const SizedBox(width: 8),
              Text(':', style: TextStyle(color: foreground, fontSize: 24)),
              const SizedBox(width: 8),
              _TimeBox(
                value: seconds,
                label: context.tr('Sec'),
                foreground: foreground,
                background: timeBoxBackground,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrayersList() {
    final prayers = [
      {'name': 'Fajr', 'time': _prayerTimes!.fajr, 'icon': Icons.wb_twilight},
      {
        'name': 'Sunrise',
        'time': _prayerTimes!.sunrise,
        'icon': Icons.wb_sunny,
        'noLog': true
      },
      {'name': 'Dhuhr', 'time': _prayerTimes!.dhuhr, 'icon': Icons.wb_sunny},
      {'name': 'Asr', 'time': _prayerTimes!.asr, 'icon': Icons.wb_cloudy},
      {
        'name': 'Maghrib',
        'time': _prayerTimes!.maghrib,
        'icon': Icons.nights_stay
      },
      {'name': 'Isha', 'time': _prayerTimes!.isha, 'icon': Icons.bedtime},
    ];

    return Column(
      children: prayers.map((prayer) {
        final isLogged = _isPrayerLogged(prayer['name'] as String);
        final noLog = prayer['noLog'] == true;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color:
                    isLogged ? Colors.green.withOpacity(0.2) : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                prayer['icon'] as IconData,
                color: isLogged ? Colors.green : Colors.grey[700],
              ),
            ),
            title: Text(
              context.tr(prayer['name'] as String),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(prayer['time'] as String),
            trailing: noLog
                ? null
                : isLogged
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        color: const Color(0xFF2E7D32),
                        onPressed: () => _logPrayer(prayer['name'] as String),
                      ),
          ),
        );
      }).toList(),
    );
  }
}

class _TimeBox extends StatelessWidget {
  final int value;
  final String label;
  final Color foreground;
  final Color background;

  const _TimeBox({
    required this.value,
    required this.label,
    required this.foreground,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value.toString().padLeft(2, '0'),
            style: TextStyle(
              color: foreground,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: foreground.withOpacity(0.75),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
