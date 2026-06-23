import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Hashtag chip used for transaction tagging (#Vacation, #Work)
class TagChip extends StatelessWidget {
  const TagChip({
    super.key,
    required this.label,
    this.onRemove,
    this.selected = false,
  });

  final String label;
  final VoidCallback? onRemove;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 10,
        right: onRemove != null ? 4 : 10,
        top: 6,
        bottom: 6,
      ),
      decoration: BoxDecoration(
        color: selected
            ? context.colors.primaryContainer.withValues(alpha: 0.15)
            : context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: selected
              ? context.colors.primaryContainer.withValues(alpha: 0.4)
              : context.colors.outlineVariant,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '#$label',
            style: AppTextStyles.labelSm(
              color: selected ? context.colors.primary : context.colors.onSurfaceVariant,
            ),
          ),
          if (onRemove != null) ...[
            const SizedBox(width: 2),
            GestureDetector(
              onTap: onRemove,
              child: Icon(
                Icons.close,
                size: 14,
                color: selected
                    ? context.colors.primary
                    : context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
