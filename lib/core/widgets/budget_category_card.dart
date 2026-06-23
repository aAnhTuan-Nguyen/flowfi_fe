import 'package:flutter/material.dart';
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
    final progressColor = isWarning
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: isWarning
            ? Border.all(
                color:
                    Theme.of(context).colorScheme.error.withValues(alpha: 0.25),
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
                      style: (Theme.of(context).textTheme.titleMedium ??
                              const TextStyle())
                          .copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '${(usagePercent * 100).toInt()}% of budget used',
                      style: (Theme.of(context).textTheme.labelSmall ??
                              const TextStyle())
                          .copyWith(
                        color: isWarning
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isWarning)
                Icon(
                  Icons.warning_amber_rounded,
                  color: Theme.of(context).colorScheme.error,
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
