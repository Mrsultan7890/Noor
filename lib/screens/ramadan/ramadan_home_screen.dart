import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/prayer_times_model.dart';
import '../../services/prayer_times_service.dart';
import '../../widgets/arabic_text.dart';

class RamadanHomeScreen extends StatefulWidget {
  const RamadanHomeScreen({super.key});

  @override
  State<RamadanHomeScreen> createState() => _RamadanHomeScreenState();
}

class _RamadanHomeScreenState extends State<RamadanHomeScreen> {
  final PrayerTimesService _prayerTimesService = PrayerTimesService();
  Timer? _timer;
  Duration _timeUntilSehri = Duration.zero;
  Duration _timeUntilIftar = Duration.zero;
  PrayerTimes? _prayerTimes;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPrayerTimes();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateTimes();
    });
  }

  Future<void> _loadPrayerTimes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final position = await _prayerTimesService.getCurrentLocation();
      if (!mounted) return;

      final times = await _prayerTimesService.getPrayerTimes(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      if (!mounted) return;

      setState(() {
        _prayerTimes = times;
        _isLoading = false;
      });
      _calculateTimes();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Unable to load local timings: $e';
        _isLoading = false;
      });
    }
  }

  void _calculateTimes() {
    final times = _prayerTimes;
    if (times == null || !mounted) return;
    setState(() {
      _timeUntilSehri =
          _prayerTimesService.timeUntilNextOccurrence(times.fajr);
      _timeUntilIftar =
          _prayerTimesService.timeUntilNextOccurrence(times.maghrib);
    });
  }
  
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ramadan Planner 🌙'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null || _prayerTimes == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_off, size: 56),
                        const SizedBox(height: 16),
                        Text(_errorMessage ?? 'Local timings are unavailable.',
                            textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadPrayerTimes,
                          child: const Text('Try again'),
                        ),
                      ],
                    ),
                  ),
                )
              : _buildPlanner(context),
    );
  }

  Widget _buildPlanner(BuildContext context) {
    final times = _prayerTimes!;
    final isRamadan = times.hijriMonth == 9;
    return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Sehri Timer
            Card(
              color: Colors.purple[50],
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(
                      Icons.nightlight_round,
                      size: 64,
                      color: Colors.purple,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Time until Sehri',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDuration(_timeUntilSehri),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sehri ends at ${_prayerTimesService.formatPrayerTime(times.fajr)}',
                      style: const TextStyle(
                        color: Color(0xFF334155),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Iftar Timer
            Card(
              color: Colors.orange[50],
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(
                      Icons.wb_sunny,
                      size: 64,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Time until Iftar',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDuration(_timeUntilIftar),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Iftar at ${_prayerTimesService.formatPrayerTime(times.maghrib)}',
                      style: const TextStyle(
                        color: Color(0xFF334155),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            if (isRamadan)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ramadan Progress',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: times.hijriDay / 30,
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      const SizedBox(height: 8),
                      Text('Hijri day ${times.hijriDay} of Ramadan'),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Iftar Dua
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Iftar Dua',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    const ArabicText(
                      'اَللّٰهُمَّ اِنِّی لَکَ صُمْتُ وَبِکَ اٰمَنْتُ وَعَلَيْکَ تَوَکَّلْتُ وَعَلٰی رِزْقِکَ اَفْطَرْتُ',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 20,
                        height: 2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const ArabicText(
                      'اے اللہ! میں نے تیرے لیے روزہ رکھا اور تجھ پر ایمان لایا اور تجھ پر بھروسہ کیا اور تیرے رزق سے افطار کیا',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 16,
                        color: Color(0xFF1E293B),
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
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
