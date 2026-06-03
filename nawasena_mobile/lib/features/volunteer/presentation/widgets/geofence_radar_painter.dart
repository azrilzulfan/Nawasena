import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:nawasena_mobile/core/theme/app_colors.dart';

/// Custom painter untuk animasi radar geofence
class GeofenceRadarPainter extends CustomPainter {
  final double animationValue; // 0.0 → 1.0
  final bool isInside;

  const GeofenceRadarPainter({
    required this.animationValue,
    required this.isInside,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;
    final activeColor = isInside ? AppColors.success : AppColors.primary;

    // ── Concentric ripple rings ────────────────────────────────────
    for (int i = 0; i < 3; i++) {
      final ringProgress =
      (animationValue - (i * 0.33)).clamp(0.0, 1.0);
      if (ringProgress == 0) continue;
      final radius = maxRadius * ringProgress;
      final opacity = (1.0 - ringProgress) * 0.35;

      final ringPaint = Paint()
        ..color = activeColor.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius, ringPaint);

      final borderPaint = Paint()
        ..color = activeColor.withValues(alpha: opacity * 2.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(center, radius, borderPaint);
    }

    // ── Geofence boundary circle ───────────────────────────────────
    final boundaryPaint = Paint()
      ..color = activeColor.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    const dashCount = 24;
    final dashAngle = (2 * math.pi) / dashCount;
    for (int i = 0; i < dashCount; i++) {
      if (i % 2 == 0) {
        final startAngle = i * dashAngle;
        final sweepAngle = dashAngle * 0.7;
        final rect = Rect.fromCircle(center: center, radius: maxRadius * 0.88);
        canvas.drawArc(rect, startAngle, sweepAngle, false, boundaryPaint);
      }
    }

    // ── Center dot ────────────────────────────────────────────────
    final centerDotPaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 10, centerDotPaint);
    canvas.drawCircle(
      center,
      10,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(GeofenceRadarPainter old) =>
      old.animationValue != animationValue || old.isInside != isInside;
}