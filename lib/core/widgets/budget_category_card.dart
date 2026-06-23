import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'progress_bar.dart';

/// Budget category card with icon, usage percentage, and progress bar
/// Warning state turns red when usage is high
class BudgetCategoryCard extends StatelessWidget {
  const BudgetCategoryCard({
    super.key,
    required this.category,
    required this.usagePercent,
    required this.iconData,
    required this.iconColor,
    required this.iconBgColor,
    this.isWarning = false,
  });

  final String category;
  final double usagePercent; // 0.0 to 1.0
  final IconData iconData;
  final Color iconColor;
  final Color iconBgColor;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    final progressColor = isWarning ? context.colors.error : context.colors.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: isWarning
            ? Border.all(
                color: context.colors.error.withValues(alpha: 0.25),
                width: 1,
              )
            : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(iconData, color: iconColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: AppTextStyles.bodySemibold(
                        color: context.colors.onSurface,
                      ),
                    ),
                    Text(
                      '${(usagePercent * 100).toInt()}% of budget used',
                      style: AppTextStyles.labelSm(
                        color: isWarning
                            ? context.colors.error
                            : context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isWarning)
                Icon(
                  Icons.warning_amber_rounded,
                  color: context.colors.error,
                  size: 20,
                ),
            ],
          ),
          const SizedBox(height: 10),
          ProgressBar(value: usagePercent, color: progressColor, height: 6),
        ],
      ),
    );
  }
}
