import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:waves/core/utilities/enum.dart';

class AuthButton extends StatelessWidget {
  const AuthButton({super.key, required this.authType, required this.onTap, required this.label});

  final AuthType authType;
  final VoidCallback onTap;
  final String label;

  static double buttonHeight = 45;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Hero(
      tag: enumToString(authType),
      child: SizedBox(
        height: AuthButton.buttonHeight,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            padding:
                const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
            shape: RoundedRectangleBorder(
              side: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
              borderRadius: const BorderRadius.all(Radius.circular(40)),
            ),
            surfaceTintColor: Colors.transparent,
            backgroundColor: colorScheme.surfaceVariant,
            foregroundColor: colorScheme.onSurface,
          ),
          child: child(theme, colorScheme, label),
        ),
      ),
    );
  }

  Widget child(ThemeData theme, ColorScheme colorScheme, String label) {
    if (authType == AuthType.hiveKeyChain) {
      return _buttonChildren(
          theme, colorScheme, 'assets/images/auth/hive-keychain-logo.png', label);
    } else if (authType == AuthType.hiveAuth) {
      return _buttonChildren(
          theme, colorScheme, 'assets/images/auth/hiveauth_icon.png', label);
    } else if (authType == AuthType.hiveSign) {
      return _buttonChildren(
          theme, colorScheme, 'assets/images/auth/hive-signer-logo.png', label);
    } else {
      return _buttonChildren(theme, colorScheme, null, label);
    }
  }

  Row _buttonChildren(
      ThemeData theme, ColorScheme colorScheme, String? input, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        input != null
            ? SizedBox(
                height: 30,
                width: 30,
                child: Image.asset(
                  input,
                  height: 30,
                ),
              )
            : Icon(Icons.key, color: colorScheme.onSurface),
        const Gap(10),
        Text(
          text,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: colorScheme.onSurface),
        )
      ],
    );
  }
}
