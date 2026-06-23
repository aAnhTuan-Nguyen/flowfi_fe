import 'package:flutter/material.dart';

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
                    color: iconBgColor ??
                        Theme.of(context).colorScheme.surfaceContainerLow,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    iconData,
                    color: Theme.of(context).colorScheme.primary,
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
                        style: (Theme.of(context).textTheme.titleMedium ??
                                const TextStyle())
                            .copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
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
                                style:
                                    (Theme.of(context).textTheme.labelSmall ??
                                            const TextStyle())
                                        .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        )
                      else
                        Text(
                          timestamp,
                          style: (Theme.of(context).textTheme.labelSmall ??
                                  const TextStyle())
                              .copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      if (category != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            timestamp,
                            style: (Theme.of(context).textTheme.labelSmall ??
                                    const TextStyle())
                                .copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  isExpense ? '-$amount' : '+$amount',
                  style: (Theme.of(context).textTheme.titleMedium ??
                          const TextStyle())
                      .copyWith(
                    color: isExpense
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.secondary,
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
            color: Theme.of(context).colorScheme.surfaceContainer,
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
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: (Theme.of(context).textTheme.labelSmall ?? const TextStyle())
            .copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}
