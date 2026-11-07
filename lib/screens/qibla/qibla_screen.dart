import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../widgets/arabic_text.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double? _qiblaDirection;
  bool _isLoading = false;
  bool _compassAvailable = true;
  String? _error;
  String? _compassError;
  String? _locationName;
  double? _heading;
  StreamSubscription<CompassEvent>? _compassSubscription;

  @override
  void initState() {
    super.initState();
    _listenToCompass();
    _calculateQibla();
  }

  void _listenToCompass() {
    final events = FlutterCompass.events;
    if (events == null) {
      _compassAvailable = false;
      _compassError = 'This device does not provide a compass sensor.';
      return;
    }

    _compassSubscription = events.listen(
      (event) {
        if (!mounted) return;
        setState(() {
          _heading = event.heading;
          _compassAvailable = event.heading != null;
          _compassError = event.heading == null
              ? 'Compass heading is unavailable on this device.'
              : null;
        });
      },
      onError: (Object error) {
        if (!mounted) return;
        setState(() {
          _compassAvailable = false;
          _compassError = 'Unable to read the device compass: $error';
        });
      },
    );
  }

  Future<void> _calculateQibla() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final status = await Permission.location.request();
      if (!status.isGranted) {
        throw Exception('Location permission required');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      final qibla = calculateQiblaBearing(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _qiblaDirection = qibla;
        _locationName =
            '${position.latitude.toStringAsFixed(2)}°, '
            '${position.longitude.toStringAsFixed(2)}°';
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Unable to get location: $e';
        _isLoading = false;
      });
    }
  }

  String _getDirectionText(double? angle) {
    if (angle == null) return '';
    if (angle >= 337.5 || angle < 22.5) return 'North ⬆️';
    if (angle >= 22.5 && angle < 67.5) return 'North-East ↗️';
    if (angle >= 67.5 && angle < 112.5) return 'East ➡️';
    if (angle >= 112.5 && angle < 157.5) return 'South-East ↘️';
    if (angle >= 157.5 && angle < 202.5) return 'South ⬇️';
    if (angle >= 202.5 && angle < 247.5) return 'South-West ↙️';
    if (angle >= 247.5 && angle < 292.5) return 'West ⬅️';
    return 'North-West ↖️';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ArabicLabel('Qibla Direction - قبلہ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _calculateQibla,
          ),
        ],
      ),
      body: Container(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_off, size: 80, color: Colors.red),
                          const SizedBox(height: 24),
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _calculateQibla,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Try Again'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        // Compass
                        Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Transform.rotate(
                                angle: -(_heading ?? 0) * pi / 180,
                                child: SizedBox(
                                  width: 260,
                                  height: 260,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            width: 4,
                                          ),
                                        ),
                                      ),
                                      const Positioned(
                                        top: 10,
                                        child: Text(
                                          'N',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                      ),
                                      const Positioned(
                                        bottom: 10,
                                        child: Text(
                                          'S',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                      ),
                                      const Positioned(
                                        left: 10,
                                        child: Text(
                                          'W',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                      ),
                                      const Positioned(
                                        right: 10,
                                        child: Text(
                                          'E',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Transform.rotate(
                                angle: calculateRelativeQiblaBearing(
                                      _qiblaDirection ?? 0,
                                      _heading ?? 0,
                                    ) *
                                    pi /
                                    180,
                                child: Icon(
                                  Icons.navigation,
                                  size: 120,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Info cards
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              if (!_compassAvailable || _heading == null)
                                Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _compassError ??
                                        'Waiting for the device compass sensor…',
                                    style: const TextStyle(
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                ),
                              _buildInfoCard(
                                icon: Icons.explore,
                                title: 'Direction',
                                value: _getDirectionText(_qiblaDirection),
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 16),
                              _buildInfoCard(
                                icon: Icons.straighten,
                                title: 'Angle',
                                value: '${_qiblaDirection?.toStringAsFixed(1)}°',
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 16),
                              _buildInfoCard(
                                icon: Icons.navigation,
                                title: 'Device heading',
                                value: _heading == null
                                    ? 'Unavailable'
                                    : '${_heading!.toStringAsFixed(1)}°',
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 16),
                              _buildInfoCard(
                                icon: Icons.location_on,
                                title: 'Your Location',
                                value: _locationName ?? '',
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Face the arrow shown to pray towards the Kaaba',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    unawaited(_compassSubscription?.cancel());
    super.dispose();
  }
}

double calculateQiblaBearing(double latitude, double longitude) {
  const kaabaLatitude = 21.4225;
  const kaabaLongitude = 39.8262;

  final longitudeDifference = (kaabaLongitude - longitude) * pi / 180;
  final latitudeRadians = latitude * pi / 180;
  const kaabaLatitudeRadians = kaabaLatitude * pi / 180;
  final y = sin(longitudeDifference) * cos(kaabaLatitudeRadians);
  final x = cos(latitudeRadians) * sin(kaabaLatitudeRadians) -
      sin(latitudeRadians) *
          cos(kaabaLatitudeRadians) *
          cos(longitudeDifference);
  return (atan2(y, x) * 180 / pi + 360) % 360;
}

double calculateRelativeQiblaBearing(double qiblaBearing, double heading) {
  return (qiblaBearing - heading + 360) % 360;
}
