import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Transaction list item with icon, merchant name, timestamp, and signed amount
class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.merchantName,
    required this.timestamp,
    required this.amount,
    required this.isExpense,
    required this.iconData,
    this.category,
    this.walletName,
    this.iconBgColor,
    this.onTap,
    this.showDivider = true,
  });

  final String merchantName;
  final String timestamp;
  final String amount;
  final bool isExpense;
  final IconData iconData;
  final String? category;
  final String? walletName;
  final Color? iconBgColor;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(0),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBgColor ?? context.colors.surfaceContainerLow,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    iconData,
                    color: context.colors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        merchantName,
                        style: AppTextStyles.bodySemibold(
                          color: context.colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (category != null)
                        Row(
                          children: [
                            _CategoryTag(label: category!),
                            if (walletName != null) ...[
                              const SizedBox(width: 4),
                              Text(
                                '• $walletName',
                                style: AppTextStyles.labelSm(
                                  color: context.colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        )
                      else
                        Text(
                          timestamp,
                          style: AppTextStyles.labelSm(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      if (category != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            timestamp,
                            style: AppTextStyles.labelSm(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  isExpense ? '-$amount' : '+$amount',
                  style: AppTextStyles.numericBold(
                    color: isExpense ? context.colors.expense : context.colors.income,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: context.colors.surfaceContainer,
            indent: 76,
          ),
      ],
    );
  }
}

class _CategoryTag extends StatelessWidget {
  const _CategoryTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSm(color: context.colors.onSurfaceVariant),
      ),
    );
  }
}
