import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Category icon container with colored background
/// Maps transaction categories to icons
enum TransactionCategory {
  food,
  shop,
  transport,
  rent,
  fun,
  health,
  salary,
  coffee,
  groceries,
  other,
}

class CategoryIcon extends StatelessWidget {
  const CategoryIcon({
    super.key,
    required this.category,
    this.size = 48,
  });

  final TransactionCategory category;
  final double size;

  @override
  Widget build(BuildContext context) {
    final config = getCategoryConfig(context)[category] ?? getCategoryConfig(context)[TransactionCategory.other]!;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: config.bgColor,
        shape: BoxShape.circle,
      ),
      child: Icon(config.icon, color: config.iconColor, size: size * 0.46),
    );
  }

  static Map<TransactionCategory, CategoryConfig> getCategoryConfig(BuildContext context) => {
    TransactionCategory.food: CategoryConfig(
      icon: Icons.restaurant,
      bgColor: context.colors.surfaceContainerLow,
      iconColor: context.colors.primary,
    ),
    TransactionCategory.shop: CategoryConfig(
      icon: Icons.shopping_cart_outlined,
      bgColor: context.colors.surfaceContainerLow,
      iconColor: context.colors.primary,
    ),
    TransactionCategory.transport: CategoryConfig(
      icon: Icons.directions_car_outlined,
      bgColor: context.colors.surfaceContainerLow,
      iconColor: context.colors.secondary,
    ),
    TransactionCategory.rent: CategoryConfig(
      icon: Icons.home_outlined,
      bgColor: context.colors.surfaceContainerLow,
      iconColor: context.colors.primary,
    ),
    TransactionCategory.fun: CategoryConfig(
      icon: Icons.movie_outlined,
      bgColor: context.colors.surfaceContainerLow,
      iconColor: context.colors.tertiary,
    ),
    TransactionCategory.health: CategoryConfig(
      icon: Icons.health_and_safety_outlined,
      bgColor: context.colors.surfaceContainerLow,
      iconColor: context.colors.primary,
    ),
    TransactionCategory.salary: CategoryConfig(
      icon: Icons.payments_outlined,
      bgColor: const Color(0x3322C55E),
      iconColor: context.colors.primary,
    ),
    TransactionCategory.coffee: CategoryConfig(
      icon: Icons.coffee,
      bgColor: context.colors.surfaceContainerLow,
      iconColor: context.colors.primary,
    ),
    TransactionCategory.groceries: CategoryConfig(
      icon: Icons.shopping_basket_outlined,
      bgColor: context.colors.surfaceContainerLow,
      iconColor: context.colors.primary,
    ),
    TransactionCategory.other: CategoryConfig(
      icon: Icons.receipt_outlined,
      bgColor: context.colors.surfaceContainerLow,
      iconColor: context.colors.onSurfaceVariant,
    ),
  };
}

class CategoryConfig {
  const CategoryConfig({
    required this.icon,
    required this.bgColor,
    required this.iconColor,
  });

  final IconData icon;
  final Color bgColor;
  final Color iconColor;
}
