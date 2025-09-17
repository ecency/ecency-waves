import 'package:flutter/material.dart';

class UpVotePercentageButtons extends StatelessWidget {
  const UpVotePercentageButtons(
      {super.key, required this.onTap, required this.percentageValue});

  final Function(double) onTap;
  final double percentageValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark
        ? Colors.black87
        : theme.colorScheme.onPrimary;
    return GestureDetector(
      onTap: () {
        onTap(percentageValue);
      },
      child: CircleAvatar(
        radius: 20,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: textColor,
        child: Text(
          "${(percentageValue * 100).round()}",
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
