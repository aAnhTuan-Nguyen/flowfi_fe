import 'package:flutter/material.dart';

/// Section header with title + optional trailing action button
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: (Theme.of(context).textTheme.headlineMedium ??
                    const TextStyle())
                .copyWith(color: Theme.of(context).colorScheme.onSurface),
          ),
          if (actionLabel != null && onAction != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: (Theme.of(context).textTheme.labelMedium ??
                        const TextStyle())
                    .copyWith(color: Theme.of(context).colorScheme.secondary),
              ),
            ),
        ],
      ),
    );
  }
}
