import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

class ParallelogramPainter extends CustomPainter {
  const ParallelogramPainter({
    required this.fillColors,
    required this.borderColor,
    required this.borderWidth,
    required this.skew,
    required this.radius,
    this.glowColor,
  });

  final List<Color> fillColors;
  final Color borderColor;
  final double borderWidth;
  final double skew;
  final double radius;
  final Color? glowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _roundedParallelogramPath(size);
    final glow = glowColor;

    if (glow != null) {
      final shadowPaint = Paint()
        ..color = glow.withValues(alpha: 0.55)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 20.r);
      canvas.drawPath(path.shift(Offset(0, 10.h)), shadowPaint);
      canvas.drawPath(path, shadowPaint);
    }

    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: fillColors,
        stops: const [0, 0.48, 1],
      ).createShader(Offset.zero & size);

    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..color = borderColor;

    canvas.drawPath(path, fill);
    canvas.drawPath(path, border);
  }

  @override
  bool shouldRepaint(ParallelogramPainter oldDelegate) {
    return oldDelegate.fillColors != fillColors ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.skew != skew ||
        oldDelegate.radius != radius ||
        oldDelegate.glowColor != glowColor;
  }

  Path _roundedParallelogramPath(Size size) {
    final points = [
      Offset(skew, 0),
      Offset(size.width, 0),
      Offset(size.width - skew, size.height),
      Offset(0, size.height),
    ];
    final path = Path();

    for (var index = 0; index < points.length; index++) {
      final previous = points[(index - 1 + points.length) % points.length];
      final current = points[index];
      final next = points[(index + 1) % points.length];
      final start = _pointAlong(current, previous, radius);
      final end = _pointAlong(current, next, radius);

      if (index == 0) {
        path.moveTo(start.dx, start.dy);
      } else {
        path.lineTo(start.dx, start.dy);
      }

      path.arcToPoint(end, radius: Radius.circular(radius));
    }

    return path..close();
  }

  Offset _pointAlong(Offset from, Offset to, double distance) {
    final vector = to - from;
    final length = vector.distance;
    if (length == 0) return from;
    return from + vector / length * distance.clamp(0, length / 2);
  }
}
