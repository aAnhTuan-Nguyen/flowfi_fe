import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'glass_card.dart';
import 'progress_bar.dart';
import 'badge_chip.dart';

/// Horizontal-scroll saving goal card
/// Shows icon, streak/status badge, goal name, progress, percentage
class GoalCard extends StatelessWidget {
  const GoalCard({
    super.key,
    required this.goalName,
    required this.currentAmount,
    required this.targetAmount,
    required this.progress,
    required this.iconData,
    required this.progressColor,
    required this.iconColor,
    required this.iconBgColor,
    this.badgeLabel,
    this.badgeColor,
    this.badgeTextColor,
    this.onTap,
  });

  final String goalName;
  final String currentAmount;
  final String targetAmount;
  final double progress; // 0.0 to 1.0
  final IconData iconData;
  final Color progressColor;
  final Color iconColor;
  final Color iconBgColor;
  final String? badgeLabel;
  final Color? badgeColor;
  final Color? badgeTextColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: 280,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(iconData, color: iconColor, size: 22),
                  ),
                  if (badgeLabel != null)
                    BadgeChip(
                      label: badgeLabel!,
                      color: badgeColor ?? context.colors.tertiaryContainer,
                      textColor:
                          badgeTextColor ?? context.colors.onTertiaryContainer,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                goalName,
                style: AppTextStyles.bodyLg(color: context.colors.onSurface)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                '$currentAmount of $targetAmount',
                style: AppTextStyles.labelMd(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              ProgressBar(
                value: progress,
                color: progressColor,
                height: 10,
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${(progress * 100).toInt()}%',
                  style: AppTextStyles.labelSm(color: progressColor)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
