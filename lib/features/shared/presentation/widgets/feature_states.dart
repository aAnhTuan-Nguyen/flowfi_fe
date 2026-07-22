import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'forui_controls.dart';

class FlowFiFeatureScaffold extends StatelessWidget {
  const FlowFiFeatureScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
    this.actions = const [],
    this.onRefresh,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;
  final List<Widget> actions;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: onRefresh ?? () async {},
        notificationPredicate: onRefresh == null ? (_) => false : (_) => true,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, color: colors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: textTheme.titleLarge),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (actions.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      ...actions,
                    ],
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              sliver: child,
            ),
          ],
        ),
      ),
    );
  }
}

Future<T?> showFlowFiFormSheet<T>({
  required BuildContext context,
  required String title,
  required Widget child,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return FlowFiFormSheet(title: title, child: child);
    },
  );
}

class FlowFiFormSheet extends StatelessWidget {
  const FlowFiFormSheet({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: colors.outlineVariant,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    FlowFiIconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Đóng',
                      icon: Icons.close_rounded,
                      variant: FlowFiButtonVariant.ghost,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FlowFiCard extends StatelessWidget {
  const FlowFiCard({
    super.key,
    required this.child,
    this.color,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F172015),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class FlowFiIconBadge extends StatelessWidget {
  const FlowFiIconBadge({
    super.key,
    required this.icon,
    this.color,
    this.foregroundColor,
    this.tone,
    this.size = 44,
    this.radius = 16,
  });

  final IconData icon;
  final Color? color;
  final Color? foregroundColor;
  final FlowFiTone? tone;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final toneStyle = tone == null ? null : flowFiToneStyle(context, tone!);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? toneStyle?.background ?? colors.primaryContainer,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(
        icon,
        color: foregroundColor ?? toneStyle?.foreground ?? colors.primary,
        size: size <= 36 ? 18 : 22,
      ),
    );
  }
}

class FlowFiMetricCard extends StatelessWidget {
  const FlowFiMetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color,
    this.iconColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? color;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final resolvedIconColor = iconColor ?? colors.primary;

    return FlowFiCard(
      color: color,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FlowFiIconBadge(
            icon: icon,
            color: resolvedIconColor.withValues(alpha: 0.12),
            foregroundColor: resolvedIconColor,
            size: 36,
            radius: 13,
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: colors.onSurfaceVariant),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class FlowFiProfileRow extends StatelessWidget {
  const FlowFiProfileRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        FlowFiIconBadge(icon: icon, size: 38, radius: 14),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class FlowFiAmountText extends StatelessWidget {
  const FlowFiAmountText({
    super.key,
    required this.amount,
    this.currencyCode,
    this.align = TextAlign.start,
    this.color,
  });

  final String amount;
  final String? currencyCode;
  final TextAlign align;
  final Color? color;

  String _formatAmount(String amountStr) {
    final isNegative = amountStr.trim().startsWith('-');
    final doubleAmount = double.tryParse(amountStr.replaceAll(RegExp(r'[^0-9.-]'), '')) ?? 0.0;
    final absAmount = doubleAmount.abs();
    
    String formatted;
    if (absAmount >= 1000000) {
      final inMillions = absAmount / 1000000;
      final str = inMillions.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
      formatted = '${str.replaceAll('.', ',')}M';
    } else {
      final intAmount = absAmount.truncate();
      final str = intAmount.toString();
      final buffer = StringBuffer();
      for (int i = 0; i < str.length; i++) {
        if (i > 0 && (str.length - i) % 3 == 0) {
          buffer.write('.');
        }
        buffer.write(str[i]);
      }
      formatted = buffer.toString();
    }
    
    return '${isNegative ? '-' : ''}$formatted';
  }

  @override
  Widget build(BuildContext context) {
    final formattedAmt = _formatAmount(amount);
    final label = currencyCode == null ? formattedAmt : '$formattedAmt $currencyCode';
    return Text(
      label,
      textAlign: align,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: color ?? Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class FlowFiStatusBadge extends StatelessWidget {
  const FlowFiStatusBadge({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.foregroundColor,
    this.tone = FlowFiTone.info,
  });

  final String label;
  final IconData? icon;
  final Color? color;
  final Color? foregroundColor;
  final FlowFiTone tone;

  @override
  Widget build(BuildContext context) {
    final toneStyle = flowFiToneStyle(context, tone);
    final textColor = foregroundColor ?? toneStyle.foreground;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color ?? toneStyle.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FlowFiSegmentedFilter<T> extends StatelessWidget {
  const FlowFiSegmentedFilter({
    super.key,
    required this.values,
    required this.selected,
    required this.labelBuilder,
    required this.onSelected,
  });

  final List<T> values;
  final T selected;
  final String Function(T value) labelBuilder;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Row(
          children: [
            for (final value in values)
              _FlowFiSegment<T>(
                value: value,
                selected: selected == value,
                label: labelBuilder(value),
                onSelected: onSelected,
              ),
          ],
        ),
      ),
    );
  }
}

class _FlowFiSegment<T> extends StatelessWidget {
  const _FlowFiSegment({
    required this.value,
    required this.selected,
    required this.label,
    required this.onSelected,
  });

  final T value;
  final bool selected;
  final String label;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Material(
        color: selected ? colors.surfaceContainerLowest : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => onSelected(value),
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 36, minWidth: 72),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: selected ? colors.primary : colors.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FlowFiActionTile extends StatelessWidget {
  const FlowFiActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: colors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class FlowFiListItemCard extends StatelessWidget {
  const FlowFiListItemCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.tone = FlowFiTone.info,
    this.trailing,
    this.status,
    this.action,
    this.color,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final FlowFiTone tone;
  final Widget? trailing;
  final Widget? status;
  final Widget? action;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final content = Row(
      children: [
        FlowFiIconBadge(icon: icon, tone: tone, size: 44, radius: 14),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (status != null) ...[
                    const SizedBox(width: 8),
                    Flexible(child: status!),
                  ],
                ],
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        if (action != null) ...[const SizedBox(width: 6), action!],
      ],
    );

    if (onTap == null) {
      return FlowFiCard(
        color: color,
        padding: const EdgeInsets.all(14),
        child: content,
      );
    }

    return FlowFiCard(
      color: color,
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(padding: const EdgeInsets.all(14), child: content),
        ),
      ),
    );
  }
}

class FlowFiProgressBar extends StatelessWidget {
  const FlowFiProgressBar({
    super.key,
    required this.value,
    this.tone = FlowFiTone.positive,
    this.height = 8,
  });

  final double value;
  final FlowFiTone tone;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final toneStyle = flowFiToneStyle(context, tone);
    final clamped = value.clamp(0.0, 1.0).toDouble();

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Stack(
        children: [
          Container(height: height, color: colors.surfaceContainerHigh),
          FractionallySizedBox(
            widthFactor: clamped,
            child: Container(height: height, color: toneStyle.foreground),
          ),
        ],
      ),
    );
  }
}

class FlowFiChartCard extends StatelessWidget {
  const FlowFiChartCard({
    super.key,
    required this.title,
    required this.chart,
    this.subtitle,
    this.trailing,
    this.legend = const [],
  });

  final String title;
  final String? subtitle;
  final Widget chart;
  final Widget? trailing;
  final List<Widget> legend;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return FlowFiCard(
      color: colors.surfaceContainerLowest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ?trailing,
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: 16),
          chart,
          if (legend.isNotEmpty) ...[const SizedBox(height: 14), ...legend],
        ],
      ),
    );
  }
}

class FlowFiLegendRow extends StatelessWidget {
  const FlowFiLegendRow({
    super.key,
    required this.color,
    required this.label,
    this.value,
  });

  final Color color;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (value != null) ...[
          const SizedBox(width: 8),
          Text(
            value!,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}

class FlowFiForuiButton extends StatelessWidget {
  const FlowFiForuiButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return FlowFiButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
    );
  }
}

class FlowFiEmptyState extends StatelessWidget {
  const FlowFiEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: FlowFiStateContent(icon: icon, title: title, message: message),
      ),
    );
  }
}

class FlowFiInlineEmptyState extends StatelessWidget {
  const FlowFiInlineEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return FlowFiStateContent(icon: icon, title: title, message: message);
  }
}

class FlowFiErrorState extends StatelessWidget {
  const FlowFiErrorState({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: FlowFiCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 36,
                color: FlowFiColors.danger,
              ),
              const SizedBox(height: 12),
              Text(
                'Không tải được dữ liệu',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'Kiểm tra kết nối backend rồi thử lại.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              FlowFiButton(
                label: 'Thử lại',
                onPressed: onRetry,
                fullWidth: false,
                icon: Icons.refresh_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FlowFiInlineError extends StatelessWidget {
  const FlowFiInlineError({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return FlowFiCard(
      child: Row(
        children: [
          FlowFiIconBadge(
            icon: Icons.cloud_off_rounded,
            tone: FlowFiTone.negative,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
          FlowFiButton(
            label: 'Thử lại',
            onPressed: onRetry,
            fullWidth: false,
            variant: FlowFiButtonVariant.ghost,
          ),
        ],
      ),
    );
  }
}

class FlowFiSliverLoading extends StatelessWidget {
  const FlowFiSliverLoading({super.key, this.label = 'Đang tải dữ liệu'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(child: FlowFiInlineLoading(label: label)),
    );
  }
}

SliverList separatedSliverList({
  required int itemCount,
  required Widget Function(BuildContext context, int index) itemBuilder,
}) {
  return SliverList.separated(
    itemCount: itemCount,
    itemBuilder: itemBuilder,
    separatorBuilder: (_, _) => const SizedBox(height: 10),
  );
}

class FlowFiInlineLoading extends StatelessWidget {
  const FlowFiInlineLoading({super.key, this.label = 'Đang tải dữ liệu'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return FlowFiCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset(
            'assets/lottie/loading_state.json',
            width: 88,
            height: 88,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 8),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class FlowFiStateContent extends StatelessWidget {
  const FlowFiStateContent({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return FlowFiCard(
      color: colors.surfaceContainerLowest,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Lottie.asset(
                'assets/lottie/empty_state.json',
                width: 104,
                height: 104,
                fit: BoxFit.contain,
                repeat: false,
              ),
              Icon(icon, size: 30, color: colors.primary),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
