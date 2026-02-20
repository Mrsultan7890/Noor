import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double? _qiblaDirection;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _calculateQibla();
  }

  Future<void> _calculateQibla() async {
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
      final qibla = _getQiblaDirection(position.latitude, position.longitude);

      setState(() {
        _qiblaDirection = qibla;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  double _getQiblaDirection(double lat, double lon) {
    const kaabaLat = 21.4225;
    const kaabaLon = 39.8262;

    final dLon = (kaabaLon - lon) * pi / 180;
    final lat1 = lat * pi / 180;
    final lat2 = kaabaLat * pi / 180;

    final y = sin(dLon) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    final bearing = atan2(y, x) * 180 / pi;

    return (bearing + 360) % 360;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Qibla Direction - قبلہ'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _calculateQibla),
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
                      ElevatedButton(onPressed: _calculateQibla, child: const Text('Retry')),
                    ],
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.navigation, size: 200, color: Theme.of(context).primaryColor),
                      const SizedBox(height: 32),
                      Text('${_qiblaDirection?.toInt()}°', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      const Text('Direction to Kaaba', style: TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
    );
  }
}
