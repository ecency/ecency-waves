import 'package:flutter/material.dart';
import 'package:waves/core/utilities/enum.dart';

class AuthButton extends StatelessWidget {
  const AuthButton({super.key, required this.authType, required this.onTap});

  final AuthType authType;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 45,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
            shape: RoundedRectangleBorder(
                side:
                    BorderSide(color: theme.primaryColorDark.withOpacity(0.5)),
                borderRadius: const BorderRadius.all(Radius.circular(40))),
            surfaceTintColor: theme.primaryColorLight,
            backgroundColor: theme.primaryColorLight),
        child: child(theme),
      ),
    );
  }

  Widget child(ThemeData theme) {
    if (authType == AuthType.hiveKeyChain) {
      return Image.asset(
        'assets/images/auth/hive_key_chain_button.png',
        height: 30,
      );
    } else if (authType == AuthType.hiveAuth) {
      return Image.asset(
        'assets/images/auth/hive_auth_button.png',
        height: 30,
      );
    } else {
      return Text(
        authType == AuthType.postingKey ? "Paste Posting Key" : "Hive Signer",
        style: theme.textTheme.bodyMedium,
      );
    }
  }
}
