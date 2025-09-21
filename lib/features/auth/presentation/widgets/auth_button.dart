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
    String? asset;
    if (authType == AuthType.hiveKeyChain) {
      asset = 'assets/images/auth/hive-keychain-logo.png';
    } else if (authType == AuthType.hiveAuth) {
      asset = 'assets/images/auth/hiveauth_icon.png';
    } else if (authType == AuthType.hiveSign) {
      asset = 'assets/images/auth/hive-signer-logo.png';
    } else if (authType == AuthType.ecency) {
      asset = 'assets/images/auth/ecency-logo.png';
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: _buttonChildren(theme, colorScheme, asset, label),
    );
  }

  Row _buttonChildren(
      ThemeData theme, ColorScheme colorScheme, String? input, String text) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (input != null)
          SizedBox(
            height: 30,
            width: 30,
            child: Center(
              child: Image.asset(
                input,
                height: 24,
                fit: BoxFit.contain,
                alignment: Alignment.center,
              ),
            ),
          )
        else
          Icon(
            Icons.key,
            color: colorScheme.onSurface,
            size: 24,
          ),
        const Gap(10),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: colorScheme.onSurface),
            textAlign: TextAlign.left,
          ),
        )
      ],
    );
  }
}
