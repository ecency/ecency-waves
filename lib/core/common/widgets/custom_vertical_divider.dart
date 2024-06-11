import 'package:flutter/material.dart';

class CustomVerticalDivider extends StatelessWidget {
  const CustomVerticalDivider({super.key, this.height, this.width, this.color, this.horizontalMargin});

  final double? height;
  final double? width;
  final Color? color;
  final double? horizontalMargin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalMargin ?? 0),
      width: width ?? 2,
      height: height ?? 45,
      color: color ?? theme.colorScheme.tertiary,
    );
  }
}
