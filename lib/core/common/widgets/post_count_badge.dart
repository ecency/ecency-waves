import 'package:flutter/material.dart';

class PostCountBadge extends StatelessWidget {
  const PostCountBadge({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor =
        isDark ? colorScheme.onPrimary : theme.primaryColor;
    final textColor =
        isDark ? colorScheme.onSecondary : colorScheme.onPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$count',
        style: (theme.textTheme.bodySmall ?? const TextStyle()).copyWith(
          color: textColor,
        ),
      ),
    );
  }
}
