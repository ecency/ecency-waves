import 'package:flutter/material.dart';

class DuoTextButtons extends StatelessWidget {
  const DuoTextButtons(
      {super.key,
      this.buttonHeight,
      required this.buttonOneText,
      required this.buttonOneOnTap,});

  final double? buttonHeight;
  final String buttonOneText;
  final VoidCallback buttonOneOnTap;


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        SizedBox(
          height: buttonHeight,
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: theme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
            onPressed: buttonOneOnTap,
            child: Text(
              buttonOneText,
              style: theme.textTheme.bodySmall!
                  .copyWith(color: theme.colorScheme.onPrimary),
            ),
          ),
        ),
      ],
    );
  }
}
