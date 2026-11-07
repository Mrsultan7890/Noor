import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AnimatedNoorLogo extends StatelessWidget {
  const AnimatedNoorLogo({
    super.key,
    required this.progress,
    required this.palette,
  });

  final Animation<double> progress;
  final NoorThemePalette palette;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _NoorLogoPainter(progress: progress, palette: palette),
    );
  }
}

class _NoorLogoPainter extends CustomPainter {
  _NoorLogoPainter({
    required this.progress,
    required this.palette,
  }) : super(repaint: progress);

  final Animation<double> progress;
  final NoorThemePalette palette;

  double _stage(double start, double end) {
    final value =
        ((progress.value - start) / (end - start)).clamp(0.0, 1.0).toDouble();
    return Curves.easeInOut.transform(value);
  }

  void _drawProgressivePath(
    Canvas canvas,
    Path path,
    Paint paint,
    double amount,
  ) {
    if (amount <= 0) return;

    final metrics = path.computeMetrics().toList();
    final totalLength = metrics.fold<double>(
      0,
      (length, metric) => length + metric.length,
    );
    var remaining = totalLength * amount;
    final revealedPath = Path();

    for (final metric in metrics) {
      if (remaining <= 0) break;
      final length = remaining.clamp(0.0, metric.length).toDouble();
      revealedPath.addPath(metric.extractPath(0, length), Offset.zero);
      remaining -= length;
    }

    canvas.drawPath(revealedPath, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 512;
    canvas
      ..save()
      ..scale(scale);

    const bounds = Rect.fromLTWH(0, 0, 512, 512);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bounds, const Radius.circular(112)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: palette.gradientColors,
        ).createShader(bounds),
    );

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = palette.accent.withOpacity(0.22 * _stage(0, 0.35));
    canvas.drawCircle(const Offset(256, 256), 220, ringPaint);

    final outerArch = Path()
      ..moveTo(104, 414)
      ..lineTo(104, 258)
      ..cubicTo(104, 174, 172, 106, 256, 106)
      ..cubicTo(340, 106, 408, 174, 408, 258)
      ..lineTo(408, 414);
    _drawProgressivePath(
      canvas,
      outerArch,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 13
        ..strokeCap = StrokeCap.round
        ..color = palette.secondaryAccent,
      _stage(0.02, 0.52),
    );

    final innerArch = Path()
      ..moveTo(160, 414)
      ..lineTo(160, 285)
      ..cubicTo(160, 232, 203, 189, 256, 189)
      ..cubicTo(309, 189, 352, 232, 352, 285)
      ..lineTo(352, 414);
    _drawProgressivePath(
      canvas,
      innerArch,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..color = palette.accent.withOpacity(0.85),
      _stage(0.2, 0.66),
    );

    final base = Path()
      ..moveTo(143, 414)
      ..lineTo(369, 414);
    _drawProgressivePath(
      canvas,
      base,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 13
        ..strokeCap = StrokeCap.round
        ..color = palette.secondaryAccent,
      _stage(0.48, 0.72),
    );

    final roof = Path()
      ..moveTo(205, 245)
      ..lineTo(205, 214)
      ..lineTo(226, 195)
      ..lineTo(256, 167)
      ..lineTo(286, 195)
      ..lineTo(307, 214)
      ..lineTo(307, 245)
      ..lineTo(289, 245)
      ..lineTo(289, 221)
      ..lineTo(256, 191)
      ..lineTo(223, 221)
      ..lineTo(223, 245)
      ..close();
    final roofProgress = _stage(0.55, 0.76);
    _drawProgressivePath(
      canvas,
      roof,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeJoin = StrokeJoin.round
        ..color = palette.secondaryAccent,
      roofProgress,
    );
    if (roofProgress >= 1) {
      canvas.drawPath(roof, Paint()..color = palette.secondaryAccent);
    }

    final bodyProgress = _stage(0.67, 0.84);
    if (bodyProgress > 0) {
      canvas.drawRect(
        const Rect.fromLTWH(220, 246, 72, 126),
        Paint()..color = palette.secondaryAccent.withOpacity(bodyProgress),
      );
    }

    final pillarsProgress = _stage(0.72, 0.9);
    if (pillarsProgress > 0) {
      final pillarPaint = Paint()
        ..color = palette.accent.withOpacity(pillarsProgress);
      canvas
        ..drawRect(const Rect.fromLTWH(171, 264, 20, 108), pillarPaint)
        ..drawRect(const Rect.fromLTWH(321, 264, 20, 108), pillarPaint);
    }

    final doorProgress = _stage(0.78, 0.92);
    if (doorProgress > 0) {
      final door = Path()
        ..moveTo(240, 372)
        ..lineTo(240, 318)
        ..cubicTo(240, 294, 272, 294, 272, 318)
        ..lineTo(272, 372)
        ..close();
      canvas.drawPath(
        door,
        Paint()..color = palette.gradientStart.withOpacity(doorProgress),
      );
    }

    final starProgress = _stage(0.84, 1);
    if (starProgress > 0) {
      final star = Path()
        ..moveTo(256, 91)
        ..lineTo(264, 108)
        ..lineTo(283, 111)
        ..lineTo(269, 124)
        ..lineTo(272, 143)
        ..lineTo(256, 134)
        ..lineTo(240, 143)
        ..lineTo(243, 124)
        ..lineTo(229, 111)
        ..lineTo(248, 108)
        ..close();
      canvas.drawPath(
        star,
        Paint()..color = palette.accent.withOpacity(starProgress),
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _NoorLogoPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.palette != palette;
}
