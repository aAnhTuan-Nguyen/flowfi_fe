import 'package:flutter/material.dart';
import 'glass_card.dart';

/// Wallet list item card — icon, name, subtitle, balance, color accent bar
class WalletCard extends StatelessWidget {
  const WalletCard({
    super.key,
    required this.name,
    required this.subtitle,
    required this.balance,
    required this.iconData,
    required this.accentColor,
    required this.iconBgColor,
    this.onTap,
  });

  final String name;
  final String subtitle;
  final String balance;
  final IconData iconData;
  final Color accentColor;
  final Color iconBgColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: accentColor, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: (Theme.of(context).textTheme.labelMedium ??
                            const TextStyle())
                        .copyWith(
                            color: Theme.of(context).colorScheme.onSurface)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: (Theme.of(context).textTheme.labelSmall ??
                            const TextStyle())
                        .copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  balance,
                  style: (Theme.of(context).textTheme.labelMedium ??
                          const TextStyle())
                      .copyWith(color: Theme.of(context).colorScheme.onSurface)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
