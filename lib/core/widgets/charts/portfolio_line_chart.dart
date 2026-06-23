import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Portfolio growth line chart with gradient fill and month labels
class PortfolioLineChart extends StatelessWidget {
  const PortfolioLineChart({
    super.key,
    this.labels = const ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN'],
  });

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CustomPaint(
          painter: _PortfolioPainter(
            dataPoints: const [0.75, 0.72, 0.68, 0.55, 0.35, 0.1],
            colors: context.colors,
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: labels
                      .map(
                        (l) => Text(
                          l,
                          style: AppTextStyles.labelSm(
                            color: context.colors.onSurfaceVariant,
                          ).copyWith(fontSize: 9, fontWeight: FontWeight.w700),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PortfolioPainter extends CustomPainter {
  _PortfolioPainter({
    required this.dataPoints,
    required this.colors,
  });

  final List<double> dataPoints;
  final AppColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    final chartH = size.height - 28;
    final stepX = size.width / (dataPoints.length - 1);

    final points = <Offset>[];
    for (var i = 0; i < dataPoints.length; i++) {
      points.add(Offset(i * stepX, chartH * dataPoints[i]));
    }

    // Bezier path
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (var i = 0; i < points.length - 1; i++) {
      final cp1 = Offset(
        points[i].dx + stepX / 3,
        points[i].dy,
      );
      final cp2 = Offset(
        points[i + 1].dx - stepX / 3,
        points[i + 1].dy,
      );
      path.cubicTo(
        cp1.dx,
        cp1.dy,
        cp2.dx,
        cp2.dy,
        points[i + 1].dx,
        points[i + 1].dy,
      );
    }

    // Gradient fill
    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, chartH)
      ..lineTo(points.first.dx, chartH)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colors.primaryContainer.withValues(alpha: 0.3),
            colors.primaryContainer.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, chartH)),
    );

    // Stroke
    canvas.drawPath(
      path,
      Paint()
        ..color = colors.primaryContainer
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_PortfolioPainter old) => false;
}
