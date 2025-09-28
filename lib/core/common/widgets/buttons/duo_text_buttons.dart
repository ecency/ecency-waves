import 'package:flutter/material.dart';

class DuoTextButtons extends StatelessWidget {
  const DuoTextButtons({
    super.key,
    this.buttonHeight,
    required this.buttonOneText,
    required this.buttonOneOnTap,
    this.buttonOneEnabled = true,
    this.buttonOneLoading = false,
    this.buttonTwoText,
    this.buttonTwoOnTap,
    this.buttonTwoEnabled = true,
    this.buttonTwoLoading = false,
    this.buttonTwoOutlined = true,
  });

  final double? buttonHeight;
  final String buttonOneText;
  final VoidCallback buttonOneOnTap;
  final bool buttonOneEnabled;
  final bool buttonOneLoading;
  final String? buttonTwoText;
  final VoidCallback? buttonTwoOnTap;
  final bool buttonTwoEnabled;
  final bool buttonTwoLoading;
  final bool buttonTwoOutlined;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[_buildPrimaryButton(context)];
    if (buttonTwoText != null) {
      children
        ..add(const SizedBox(width: 10))
        ..add(_buildSecondaryButton(context));
    }

    return Row(children: children);
  }

  Widget _buildPrimaryButton(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDisabled = !buttonOneEnabled || buttonOneLoading;
    return SizedBox(
      height: buttonHeight,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: theme.primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 10),
        ),
        onPressed: isDisabled ? null : buttonOneOnTap,
        child: buttonOneLoading
            ? _buildLoader(color: theme.colorScheme.onPrimary)
            : Text(
                buttonOneText,
                style: theme.textTheme.bodySmall!
                    .copyWith(color: theme.colorScheme.onPrimary),
              ),
      ),
    );
  }

  Widget _buildSecondaryButton(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDisabled =
        buttonTwoOnTap == null || !buttonTwoEnabled || buttonTwoLoading;
    final Color primaryColor = theme.primaryColor;
    final Color onPrimary = theme.colorScheme.onPrimary;
    final Widget child = buttonTwoLoading
        ? _buildLoader(
            color: buttonTwoOutlined ? primaryColor : onPrimary,
          )
        : Text(
            buttonTwoText!,
            style: theme.textTheme.bodySmall!.copyWith(
              color: buttonTwoOutlined ? primaryColor : onPrimary,
            ),
          );

    if (buttonTwoOutlined) {
      return SizedBox(
        height: buttonHeight,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            foregroundColor: primaryColor,
            side: BorderSide(color: primaryColor),
          ),
          onPressed: isDisabled ? null : buttonTwoOnTap,
          child: child,
        ),
      );
    }

    return SizedBox(
      height: buttonHeight,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 10),
        ),
        onPressed: isDisabled ? null : buttonTwoOnTap,
        child: child,
      ),
    );
  }

  Widget _buildLoader({required Color color}) {
    return SizedBox(
      width: 16,
      height: 16,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}
