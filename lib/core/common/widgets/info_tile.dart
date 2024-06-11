import 'package:flutter/material.dart';

class InfoTile extends StatelessWidget {
  const InfoTile({super.key, required this.text, this.color, this.textStyle});

  final String text;
  final Color? color;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        color: color ?? theme.colorScheme.tertiaryContainer.withOpacity(0.6),
      ),
      child: Text(
        text,
        style:textStyle ?? theme.textTheme.labelLarge!.copyWith(
            color: theme.primaryColorDark.withOpacity(0.9),
            fontWeight: FontWeight.w300),
      ),
    );
  }
}
