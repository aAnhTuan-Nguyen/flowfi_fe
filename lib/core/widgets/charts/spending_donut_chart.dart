import 'dart:math';
import 'package:flutter/material.dart';

/// Donut chart for spending category breakdown
class SpendingDonutChart extends StatelessWidget {
  const SpendingDonutChart({
    super.key,
    required this.segments,
    required this.centerLabel,
    required this.centerValue,
  });

  final List<DonutSegment> segments;
  final String centerLabel;
  final String centerValue;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            painter: _DonutPainter(
              segments: segments,
              trackColor: colorScheme.surfaceContainer,
            ),
            child: const SizedBox(width: 160, height: 160),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                centerLabel,
                style: (Theme.of(context).textTheme.labelSmall ??
                        const TextStyle())
                    .copyWith(color: Theme.of(context).colorScheme.outline),
              ),
              Text(
                centerValue,
                style: (Theme.of(context).textTheme.headlineMedium ??
                        const TextStyle())
                    .copyWith(color: Theme.of(context).colorScheme.onSurface),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DonutSegment {
  const DonutSegment({
    required this.value,
    required this.color,
    required this.label,
  });

  final double value; // fraction 0.0–1.0
  final Color color;
  final String label;
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.segments, required this.trackColor});

  final List<DonutSegment> segments;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const strokeWidth = 22.0;
    const startAngle = -pi / 2;

    // Background track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    double currentAngle = startAngle;
    for (final seg in segments) {
      final sweepAngle = 2 * pi * seg.value;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        currentAngle,
        sweepAngle - 0.04,
        false,
        Paint()
          ..color = seg.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.butt,
      );
      currentAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.segments != segments;
}
