import 'package:flutter/material.dart';

/// Animated pill-shaped progress bar
class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.value,
    this.color,
    this.backgroundColor,
    this.height = 8,
    this.showGlow = false,
  });

  final double value; // 0.0 to 1.0
  final Color? color;
  final Color? backgroundColor;
  final double height;
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color:
              backgroundColor ?? Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(999),
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: value.clamp(0.0, 1.0),
          child: Container(
            decoration: BoxDecoration(
              color: color ?? Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(999),
              boxShadow: showGlow
                  ? [
                      BoxShadow(
                        color: (color ??
                                Theme.of(context).colorScheme.primaryContainer)
                            .withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
