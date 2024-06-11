import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class DuoTextButtons extends StatelessWidget {
  const DuoTextButtons(
      {super.key,
      this.buttonHeight,
      required this.buttonOneText,
      required this.buttonTwoText,
      required this.buttonOneOnTap,
      required this.buttonTwoOnTap});

  final double? buttonHeight;
  final String buttonOneText;
  final String buttonTwoText;
  final VoidCallback buttonOneOnTap;
  final VoidCallback buttonTwoOnTap;

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
        const Gap(10),
        SizedBox(
          height: buttonHeight,
          child: TextButton(
            style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                backgroundColor: theme.primaryColor),
            onPressed: buttonTwoOnTap,
            child: Text(
              buttonTwoText,
              style: theme.textTheme.bodySmall!
                  .copyWith(color: theme.colorScheme.onPrimary),
            ),
          ),
        ),
      ],
    );
  }
}
