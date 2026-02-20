import 'package:flutter/material.dart';
import 'dart:async';

class RamadanHomeScreen extends StatefulWidget {
  const RamadanHomeScreen({super.key});

  @override
  State<RamadanHomeScreen> createState() => _RamadanHomeScreenState();
}

class _RamadanHomeScreenState extends State<RamadanHomeScreen> {
  Timer? _timer;
  Duration _timeUntilSehri = Duration.zero;
  Duration _timeUntilIftar = Duration.zero;
  
  // Example times - should be fetched from API
  final TimeOfDay _sehriTime = const TimeOfDay(hour: 5, minute: 30);
  final TimeOfDay _iftarTime = const TimeOfDay(hour: 18, minute: 45);
  
  @override
  void initState() {
    super.initState();
    _calculateTimes();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateTimes();
    });
  }
  
  void _calculateTimes() {
    final now = DateTime.now();
    
    // Calculate Sehri time
    var sehri = DateTime(
      now.year,
      now.month,
      now.day,
      _sehriTime.hour,
      _sehriTime.minute,
    );
    if (now.isAfter(sehri)) {
      sehri = sehri.add(const Duration(days: 1));
    }
    
    // Calculate Iftar time
    var iftar = DateTime(
      now.year,
      now.month,
      now.day,
      _iftarTime.hour,
      _iftarTime.minute,
    );
    if (now.isAfter(iftar)) {
      iftar = iftar.add(const Duration(days: 1));
    }
    
    setState(() {
      _timeUntilSehri = sehri.difference(now);
      _timeUntilIftar = iftar.difference(now);
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
        title: const Text('Ramadan Mubarak 🌙'),
      ),
      body: SingleChildScrollView(
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
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDuration(_timeUntilSehri),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sehri ends at ${_sehriTime.format(context)}',
                      style: TextStyle(color: Colors.grey[600]),
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
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDuration(_timeUntilIftar),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Iftar at ${_iftarTime.format(context)}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Ramadan Progress
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
                      value: 0.3, // Example: 9/30 days
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    const SizedBox(height: 8),
                    const Text('Day 9 of 30'),
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
                    const Text(
                      'اَللّٰهُمَّ اِنِّی لَکَ صُمْتُ وَبِکَ اٰمَنْتُ وَعَلَيْکَ تَوَکَّلْتُ وَعَلٰی رِزْقِکَ اَفْطَرْتُ',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 20,
                        height: 2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'اے اللہ! میں نے تیرے لیے روزہ رکھا اور تجھ پر ایمان لایا اور تجھ پر بھروسہ کیا اور تیرے رزق سے افطار کیا',
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
