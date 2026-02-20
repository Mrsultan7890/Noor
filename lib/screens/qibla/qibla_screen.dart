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
  String? _locationName;

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
        throw Exception('Location permission required');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      final qibla = _getQiblaDirection(position.latitude, position.longitude);
      final distance = _getDistanceToKaaba(position.latitude, position.longitude);

      setState(() {
        _qiblaDirection = qibla;
        _locationName = '${position.latitude.toStringAsFixed(2)}°, ${position.longitude.toStringAsFixed(2)}°';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Unable to get location. Please enable GPS and grant permission.';
        _isLoading = false;
      });
    }
  }

  double _getQiblaDirection(double lat, double lon) {
    const kaabaLat = 21.4225;
    const kaabaLon = 39.8262;

    final dLon = (kaabaLon - lon) * pi / 180;
    final lat1 = lat * pi / 180;
    const lat2 = kaabaLat * pi / 180;

    final y = sin(dLon) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    final bearing = atan2(y, x) * 180 / pi;

    return (bearing + 360) % 360;
  }

  double _getDistanceToKaaba(double lat, double lon) {
    const kaabaLat = 21.4225;
    const kaabaLon = 39.8262;
    return Geolocator.distanceBetween(lat, lon, kaabaLat, kaabaLon) / 1000;
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
        title: const Text('Qibla Direction - قبلہ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _calculateQibla,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade50, Colors.green.shade50],
          ),
        ),
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
                            style: const TextStyle(fontSize: 16),
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
                              // Compass circle
                              Container(
                                width: 260,
                                height: 260,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.green, width: 4),
                                ),
                              ),
                              // Direction markers
                              Positioned(top: 10, child: Text('N', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red))),
                              Positioned(bottom: 10, child: Text('S', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                              Positioned(left: 10, child: Text('W', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                              Positioned(right: 10, child: Text('E', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                              // Qibla arrow
                              Transform.rotate(
                                angle: (_qiblaDirection ?? 0) * pi / 180,
                                child: Icon(
                                  Icons.navigation,
                                  size: 120,
                                  color: Colors.green.shade700,
                                ),
                              ),
                              // Center dot
                              Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.green,
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
                              _buildInfoCard(
                                icon: Icons.explore,
                                title: 'Direction',
                                value: _getDirectionText(_qiblaDirection),
                                color: Colors.green,
                              ),
                              const SizedBox(height: 16),
                              _buildInfoCard(
                                icon: Icons.straighten,
                                title: 'Angle',
                                value: '${_qiblaDirection?.toStringAsFixed(1)}°',
                                color: Colors.teal,
                              ),
                              const SizedBox(height: 16),
                              _buildInfoCard(
                                icon: Icons.location_on,
                                title: 'Your Location',
                                value: _locationName ?? '',
                                color: Colors.blue,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.green.shade700),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Face the direction shown by the green arrow to pray towards Kaaba',
                                  style: TextStyle(fontSize: 14),
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
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
