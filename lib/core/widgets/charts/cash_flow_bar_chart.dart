import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Grouped bar chart for Income vs Expense by week
class CashFlowBarChart extends StatelessWidget {
  const CashFlowBarChart({
    super.key,
    required this.incomeValues,
    required this.expenseValues,
    this.labels = const ['W1', 'W2', 'W3', 'W4'],
    this.activeIndex = 2,
  });

  final List<double> incomeValues; // 0.0–1.0
  final List<double> expenseValues; // 0.0–1.0
  final List<String> labels;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CashFlowPainter(
        incomeValues: incomeValues,
        expenseValues: expenseValues,
        labels: labels,
        activeIndex: activeIndex,
        colors: context.colors,
      ),
      child: const SizedBox(height: 192),
    );
  }
}

class _CashFlowPainter extends CustomPainter {
  _CashFlowPainter({
    required this.incomeValues,
    required this.expenseValues,
    required this.labels,
    required this.activeIndex,
    required this.colors,
  });

  final List<double> incomeValues;
  final List<double> expenseValues;
  final List<String> labels;
  final int activeIndex;
  final AppColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    final barAreaHeight = size.height - 28;
    final groupWidth = size.width / incomeValues.length;
    const barGap = 3.0;
    final barWidth = (groupWidth - 24) / 2;

    for (var i = 0; i < incomeValues.length; i++) {
      final isActive = i == activeIndex;
      final opacity = isActive ? 1.0 : (i < activeIndex ? 1.0 : 0.4);
      final groupLeft = i * groupWidth + 12;

      // Income bar
      final incomeH = barAreaHeight * incomeValues[i];
      canvas.drawRRect(
        RRect.fromLTRBR(
          groupLeft,
          barAreaHeight - incomeH,
          groupLeft + barWidth,
          barAreaHeight,
          const Radius.circular(4),
        ),
        Paint()
          ..color = colors.primary.withValues(alpha: opacity)
          ..style = PaintingStyle.fill,
      );

      // Expense bar
      final expenseH = barAreaHeight * expenseValues[i];
      final expLeft = groupLeft + barWidth + barGap;
      canvas.drawRRect(
        RRect.fromLTRBR(
          expLeft,
          barAreaHeight - expenseH,
          expLeft + barWidth,
          barAreaHeight,
          const Radius.circular(4),
        ),
        Paint()
          ..color = colors.secondary.withValues(alpha: opacity)
          ..style = PaintingStyle.fill,
      );

      // Labels
      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: AppTextStyles.labelSm(
            color: isActive
                ? colors.onSurface
                : colors.outline,
          ).copyWith(
            fontSize: 10,
            fontWeight:
                isActive ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(
        canvas,
        Offset(
          groupLeft + groupWidth / 2 - tp.width / 2 - 12,
          size.height - 20,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(_CashFlowPainter old) => true;
}
