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

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  final PrayerTimesService _service = PrayerTimesService();
  PrayerTimes? _prayerTimes;
  bool _isLoading = true;
  Timer? _timer;
  Duration _timeUntilNext = Duration.zero;
  String _nextPrayer = '';
  String? _errorMessage;
  String? _notificationError;
  List<PrayerLog> _todayLogs = [];

  @override
  void initState() {
    super.initState();
    _loadPrayerTimes();
    _loadTodayLogs();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateCountdown());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadPrayerTimes() async {
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

      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool('prayer_notifications_enabled') ?? true) {
        try {
          await PrayerNotificationService.schedulePrayerNotifications(times);
        } catch (e) {
          _notificationError =
              'Prayer times loaded, but reminders could not be scheduled: $e';
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
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Unable to load prayer times: $e';
        _isLoading = false;
      });
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
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final today = DateTime.now().toIso8601String().split('T')[0];
    final logsJson = prefs.getString('prayer_logs_$today');
    
    if (logsJson != null) {
      final List<dynamic> decoded = json.decode(logsJson);
      setState(() {
        _todayLogs = decoded.map((e) => PrayerLog.fromJson(e)).toList();
      });
    }
  }

  Future<void> _logPrayer(String prayer) async {
    final log = PrayerLog(
      prayer: prayer,
      timestamp: DateTime.now(),
      onTime: true,
    );
    
    _todayLogs.add(log);
    
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    await prefs.setString(
      'prayer_logs_$today',
      json.encode(_todayLogs.map((e) => e.toJson()).toList()),
    );
    if (!mounted) return;
    setState(() {});
    
    // Log activity to backend for points
    if (mounted) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.isAuthenticated) {
        await userProvider.logActivity(
          activityType: 'prayer_logged',
          points: 5,
          metadata: {'prayer': prayer, 'time': DateTime.now().toIso8601String()},
        );
      }
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$prayer logged! +5 points'),
        ),
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
        title: const Text('Prayer Times'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPrayerTimes,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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
                              style: TextStyle(color: Theme.of(context).colorScheme.error),
                            ),
                          ),
                        _buildNextPrayerCard(),
                        const SizedBox(height: 24),
                        _buildPrayersList(),
                      ],
                    ),
                  ),
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
          Text(_errorMessage ?? 'Prayer times are unavailable.'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadPrayerTimes,
            child: const Text('Try again'),
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
            'Next Prayer',
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
                label: 'Hours',
                foreground: foreground,
                background: timeBoxBackground,
              ),
              const SizedBox(width: 8),
              Text(':', style: TextStyle(color: foreground, fontSize: 24)),
              const SizedBox(width: 8),
              _TimeBox(
                value: minutes,
                label: 'Min',
                foreground: foreground,
                background: timeBoxBackground,
              ),
              const SizedBox(width: 8),
              Text(':', style: TextStyle(color: foreground, fontSize: 24)),
              const SizedBox(width: 8),
              _TimeBox(
                value: seconds,
                label: 'Sec',
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
      {'name': 'Sunrise', 'time': _prayerTimes!.sunrise, 'icon': Icons.wb_sunny, 'noLog': true},
      {'name': 'Dhuhr', 'time': _prayerTimes!.dhuhr, 'icon': Icons.wb_sunny},
      {'name': 'Asr', 'time': _prayerTimes!.asr, 'icon': Icons.wb_cloudy},
      {'name': 'Maghrib', 'time': _prayerTimes!.maghrib, 'icon': Icons.nights_stay},
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
                color: isLogged ? Colors.green.withOpacity(0.2) : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                prayer['icon'] as IconData,
                color: isLogged ? Colors.green : Colors.grey[700],
              ),
            ),
            title: Text(
              prayer['name'] as String,
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
