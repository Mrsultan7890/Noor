import 'package:flutter_test/flutter_test.dart';
import 'package:noor/screens/qibla/qibla_screen.dart';

void main() {
  test('Qibla bearing is zero at the Kaaba', () {
    expect(calculateQiblaBearing(21.4225, 39.8262), closeTo(0, 0.001));
  });

  test('Qibla bearing matches a known London bearing', () {
    expect(
      calculateQiblaBearing(51.5074, -0.1278),
      closeTo(118.99, 0.02),
    );
  });

  test('relative Qibla direction follows the live device heading', () {
    expect(calculateRelativeQiblaBearing(120, 45), closeTo(75, 0.001));
    expect(calculateRelativeQiblaBearing(1, 359), closeTo(2, 0.001));
  });

  test('compass heading smoothing follows the shortest path across north', () {
    expect(smoothCompassHeading(359, 1), closeTo(0.3, 0.001));
    expect(smoothCompassHeading(1, 359), closeTo(359.7, 0.001));
  });

  test('compass heading smoothing quickly follows sensor updates', () {
    expect(smoothCompassHeading(0, 100), closeTo(65, 0.001));
  });

  test('compass heading normalization handles values outside one rotation', () {
    expect(normalizeCompassHeading(361), closeTo(1, 0.001));
    expect(normalizeCompassHeading(-1), closeTo(359, 0.001));
  });

  test('magnetic Qibla bearing accounts for east and west declination', () {
    expect(calculateMagneticQiblaBearing(120, 10), closeTo(110, 0.001));
    expect(calculateMagneticQiblaBearing(120, -10), closeTo(130, 0.001));
  });
}
