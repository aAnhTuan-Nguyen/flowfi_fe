import 'package:flutter/material.dart';

/// Weekly bar chart — 7 day columns with one highlighted active day
class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({
    super.key,
    required this.values,
    this.activeIndex = 2,
    this.labels = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
  });

  final List<double> values; // relative heights 0.0–1.0
  final int activeIndex;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomPaint(
      painter: _WeeklyBarPainter(
        values: values,
        activeIndex: activeIndex,
        labels: labels,
        colorScheme: theme.colorScheme,
        labelStyle: theme.textTheme.labelSmall ?? const TextStyle(),
      ),
      child: const SizedBox(height: 160),
    );
  }
}

class _WeeklyBarPainter extends CustomPainter {
  _WeeklyBarPainter({
    required this.values,
    required this.activeIndex,
    required this.labels,
    required this.colorScheme,
    required this.labelStyle,
  });

  final List<double> values;
  final int activeIndex;
  final List<String> labels;
  final ColorScheme colorScheme;
  final TextStyle labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final barAreaHeight = size.height - 24;
    final barWidth = size.width / values.length;
    final barPadding = barWidth * 0.25;

    for (var i = 0; i < values.length; i++) {
      final isActive = i == activeIndex;
      final barH = barAreaHeight * values[i];
      final left = i * barWidth + barPadding;
      final right = (i + 1) * barWidth - barPadding;
      final top = barAreaHeight - barH;

      final paint = Paint()
        ..color = isActive
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHigh
        ..style = PaintingStyle.fill;

      final rrect = RRect.fromLTRBR(
        left,
        top,
        right,
        barAreaHeight,
        const Radius.circular(4),
      );
      canvas.drawRRect(rrect, paint);

      // Labels
      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: labelStyle
              .copyWith(
                color: isActive
                    ? colorScheme.onSurface
                    : colorScheme.onSurfaceVariant,
              )
              .copyWith(fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(
        canvas,
        Offset(
          i * barWidth + barWidth / 2 - tp.width / 2,
          size.height - 18,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(_WeeklyBarPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.activeIndex != activeIndex;
}
