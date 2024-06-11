import 'package:flutter/material.dart';

class SingleLineHeaderContentText extends StatelessWidget {
  const SingleLineHeaderContentText({super.key, required this.header, required this.content});

  final String header;
  final String content;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RichText(
      text: TextSpan(
        text: "$header -",
        style: theme.textTheme.labelLarge!.copyWith(
            fontWeight: FontWeight.w300),
        children: <TextSpan>[
          TextSpan(
            text: "  $content",
            style: theme.textTheme.labelLarge!.copyWith(
            color: theme.primaryColorDark.withOpacity(0.8),
            fontWeight: FontWeight.w300),
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
