import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/prayer_times_service.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  final PrayerTimesService _service = PrayerTimesService();
  Map<String, String>? _prayerTimes;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPrayerTimes();
  }

  Future<void> _loadPrayerTimes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final status = await Permission.location.request();
      if (!status.isGranted) {
        throw Exception('Location permission denied');
      }

      final position = await Geolocator.getCurrentPosition();
      final times = await _service.getPrayerTimes(position.latitude, position.longitude);

      setState(() {
        _prayerTimes = times;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayer Times - نماز کے اوقات'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadPrayerTimes),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _loadPrayerTimes, child: const Text('Retry')),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: _prayerTimes!.entries.map((entry) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Icon(_getIcon(entry.key), color: Colors.white),
                        ),
                        title: Text(entry.key, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        trailing: Text(entry.value, style: TextStyle(fontSize: 24, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                      ),
                    );
                  }).toList(),
                ),
    );
  }

  IconData _getIcon(String prayer) {
    switch (prayer) {
      case 'Fajr': return Icons.wb_twilight;
      case 'Dhuhr': return Icons.wb_sunny;
      case 'Asr': return Icons.wb_cloudy;
      case 'Maghrib': return Icons.wb_twilight;
      case 'Isha': return Icons.nightlight;
      default: return Icons.access_time;
    }
  }
}
