import 'package:flutter/material.dart';

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
            ? Theme.of(context)
                .colorScheme
                .primaryContainer
                .withValues(alpha: 0.15)
            : Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: selected
              ? Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withValues(alpha: 0.4)
              : Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '#$label',
            style: (Theme.of(context).textTheme.labelSmall ?? const TextStyle())
                .copyWith(
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
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
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
