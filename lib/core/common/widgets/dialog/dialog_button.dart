import 'package:flutter/material.dart';

class DialogButton extends StatelessWidget {
  const DialogButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  final String text;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 25,
      child: TextButton(
          style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              backgroundColor: theme.primaryColorDark),
          onPressed: onPressed,
          child: Text(
            text,
            style: theme.textTheme.bodySmall!
                .copyWith(color: theme.primaryColorLight),
          )),
    );
  }
}
