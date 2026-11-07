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
}
