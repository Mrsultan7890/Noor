import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../widgets/arabic_text.dart';
import '../../utils/user_friendly_error.dart';
import '../../widgets/service_loading_view.dart';

const _geomagneticChannel = MethodChannel('com.noor.app/geomagnetic');

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
  String? _bearingWarning;
  String? _locationName;
  double? _heading;
  double? _compassAccuracy;
  DateTime? _lastCompassUpdate;
  bool _compassStale = true;
  StreamSubscription<CompassEvent>? _compassSubscription;
  Timer? _compassFreshnessTimer;

  @override
  void initState() {
    super.initState();
    _listenToCompass();
    _compassFreshnessTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        final stale = _lastCompassUpdate == null ||
            DateTime.now().difference(_lastCompassUpdate!) >
                const Duration(seconds: 3);
        if (stale != _compassStale && mounted) {
          setState(() => _compassStale = stale);
        }
      },
    );
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
        final heading = event.heading;
        setState(() {
          if (heading != null && heading.isFinite) {
            _heading = _heading == null
                ? normalizeCompassHeading(heading)
                : smoothCompassHeading(
                    _heading!,
                    heading,
                    smoothingFactor: 0.65,
                  );
            _lastCompassUpdate = DateTime.now();
            _compassStale = false;
          }
          _compassAccuracy = event.accuracy;
          _compassAvailable = heading != null && heading.isFinite;
          _compassError = !_compassAvailable
              ? 'Compass heading is unavailable on this device.'
              : null;
        });
      },
      onError: (Object error) {
        debugPrint('Compass stream failed: $error');
        if (!mounted) return;
        setState(() {
          _compassAvailable = false;
          _compassError =
              'The compass is unavailable. Try moving your phone in a figure-eight.';
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

      final trueBearing = calculateQiblaBearing(
        position.latitude,
        position.longitude,
      );
      var declination = 0.0;
      String? bearingWarning;
      try {
        declination = await _geomagneticChannel.invokeMethod<double>(
              'getDeclination',
              {
                'latitude': position.latitude,
                'longitude': position.longitude,
                'altitude': position.altitude,
              },
            ) ??
            (throw StateError('Magnetic declination was unavailable.'));
        if (!declination.isFinite) {
          throw StateError('Magnetic declination was invalid.');
        }
      } on PlatformException catch (error) {
        debugPrint('Could not calculate magnetic declination: $error');
        bearingWarning =
            'Magnetic north correction is unavailable; the compass direction may be slightly off.';
      } on MissingPluginException catch (error) {
        debugPrint(
            'Magnetic declination is not supported on this platform: $error');
        bearingWarning =
            'Magnetic north correction is unavailable; the compass direction may be slightly off.';
      } on StateError catch (error) {
        debugPrint('Could not calculate magnetic declination: $error');
        bearingWarning =
            'Magnetic north correction is unavailable; the compass direction may be slightly off.';
      }
      final qibla = calculateMagneticQiblaBearing(trueBearing, declination);

      setState(() {
        _qiblaDirection = qibla;
        _bearingWarning = bearingWarning;
        _locationName = '${position.latitude.toStringAsFixed(2)}°, '
            '${position.longitude.toStringAsFixed(2)}°';
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Could not calculate the Qibla direction: $e');
      if (!mounted) return;
      setState(() {
        _error = UserFriendlyError.qiblaLocation(e);
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
            ? const ServiceLoadingView(
                serviceName: 'Qibla',
                icon: Icons.explore_outlined,
              )
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_off,
                            size: 80,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _calculateQibla,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Try Again'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final dialSize = min(
                              320.0,
                              max(1.0, constraints.maxWidth - 32),
                            );
                            final relativeBearing =
                                _qiblaDirection == null || _heading == null
                                    ? 0.0
                                    : calculateRelativeQiblaBearing(
                                        _qiblaDirection!,
                                        _heading!,
                                      );
                            final aligned = !_compassStale &&
                                _compassAvailable &&
                                _heading != null &&
                                _qiblaDirection != null &&
                                (relativeBearing < 5 || relativeBearing > 355);
                            return Column(
                              children: [
                                _CompassStatus(
                                  isLive: !_compassStale &&
                                      _compassAvailable &&
                                      _heading != null,
                                  isAligned: aligned,
                                  heading: _heading,
                                ),
                                const SizedBox(height: 18),
                                Container(
                                  width: dialSize,
                                  height: dialSize,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outlineVariant,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .shadow
                                            .withOpacity(0.16),
                                        blurRadius: 28,
                                        offset: const Offset(0, 12),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Transform.rotate(
                                        angle: -(_heading ?? 0) * pi / 180,
                                        child: CustomPaint(
                                          size: Size.square(dialSize - 20),
                                          painter: _CompassDialPainter(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                            accent: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ),
                                      ),
                                      Transform.rotate(
                                        angle: relativeBearing * pi / 180,
                                        child: Icon(
                                          Icons.navigation_rounded,
                                          size: dialSize * 0.39,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                      Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          border: Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surface,
                                            width: 3,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Qibla ${_qiblaDirection?.toStringAsFixed(1) ?? '--'}°'
                                  '  ·  ${_getDirectionText(_qiblaDirection)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        // Info cards
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              if (_compassAccuracy != null &&
                                  _compassAccuracy! > 15)
                                const _CompassNotice(
                                  message:
                                      'Compass may be inaccurate. Move away from metal or electronics, then slowly move your phone in a figure-eight to calibrate it.',
                                  isWarning: true,
                                ),
                              if (!_compassAvailable ||
                                  _heading == null ||
                                  _compassStale)
                                _CompassNotice(
                                  message: _compassError ??
                                      (_heading == null
                                          ? 'Waiting for the device compass sensor…'
                                          : 'No live compass updates. Check that the device has a compass sensor.'),
                                  isWarning: true,
                                ),
                              if (_bearingWarning != null)
                                _CompassNotice(
                                  message: _bearingWarning!,
                                  isWarning: true,
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
                                value:
                                    '${_qiblaDirection?.toStringAsFixed(1)}°',
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 16),
                              _buildInfoCard(
                                icon: Icons.navigation,
                                title: 'Device heading',
                                value: _heading == null
                                    ? 'Unavailable'
                                    : '${normalizeCompassHeading(_heading!).toStringAsFixed(1)}°',
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
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Face the arrow shown to pray towards the Kaaba',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
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
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
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

  @override
  void dispose() {
    _compassFreshnessTimer?.cancel();
    unawaited(_compassSubscription?.cancel());
    super.dispose();
  }
}

class _CompassStatus extends StatelessWidget {
  const _CompassStatus({
    required this.isLive,
    required this.isAligned,
    required this.heading,
  });

  final bool isLive;
  final bool isAligned;
  final double? heading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isAligned
        ? theme.colorScheme.tertiary
        : isLive
            ? theme.colorScheme.primary
            : theme.colorScheme.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAligned
                ? Icons.check_circle_rounded
                : isLive
                    ? Icons.explore_rounded
                    : Icons.sensors_off_rounded,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(
            isAligned
                ? 'Facing Qibla'
                : isLive
                    ? 'Live compass · ${normalizeCompassHeading(heading!).toStringAsFixed(0)}°'
                    : 'Compass not updating',
            style: theme.textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompassNotice extends StatelessWidget {
  const _CompassNotice({
    required this.message,
    required this.isWarning,
  });

  final String message;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = isWarning ? scheme.tertiary : scheme.primary;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        message,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      ),
    );
  }
}

class _CompassDialPainter extends CustomPainter {
  const _CompassDialPainter({required this.color, required this.accent});

  final Color color;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    final tickPaint = Paint()
      ..color = color.withOpacity(0.35)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    for (var index = 0; index < 60; index++) {
      final angle = index * 2 * pi / 60;
      final major = index % 5 == 0;
      final innerRadius = radius - (major ? 16 : 9);
      canvas.drawLine(
        Offset(
          center.dx + radius * sin(angle),
          center.dy - radius * cos(angle),
        ),
        Offset(
          center.dx + innerRadius * sin(angle),
          center.dy - innerRadius * cos(angle),
        ),
        tickPaint..strokeWidth = major ? 2 : 1,
      );
    }

    final labelStyle = TextStyle(
      color: color,
      fontSize: radius * 0.12,
      fontWeight: FontWeight.w700,
    );
    for (final entry in const [
      ('N', 0.0),
      ('E', pi / 2),
      ('S', pi),
      ('W', 3 * pi / 2),
    ]) {
      final text = TextPainter(
        text: TextSpan(
          text: entry.$1,
          style: labelStyle.copyWith(
            color: entry.$1 == 'N' ? accent : color,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final point = Offset(
        center.dx + (radius - 32) * sin(entry.$2),
        center.dy - (radius - 32) * cos(entry.$2),
      );
      text.paint(canvas, point - Offset(text.width / 2, text.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _CompassDialPainter oldDelegate) =>
      color != oldDelegate.color || accent != oldDelegate.accent;
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

double calculateMagneticQiblaBearing(
  double trueBearing,
  double magneticDeclination,
) =>
    normalizeCompassHeading(trueBearing - magneticDeclination);

double normalizeCompassHeading(double heading) => (heading % 360 + 360) % 360;

double smoothCompassHeading(
  double currentHeading,
  double nextHeading, {
  double smoothingFactor = 0.65,
}) {
  final normalizedCurrent = normalizeCompassHeading(currentHeading);
  final normalizedNext = normalizeCompassHeading(nextHeading);
  var difference = normalizedNext - normalizedCurrent;
  if (difference > 180) {
    difference -= 360;
  } else if (difference < -180) {
    difference += 360;
  }
  return normalizeCompassHeading(
    currentHeading + difference * smoothingFactor,
  );
}
