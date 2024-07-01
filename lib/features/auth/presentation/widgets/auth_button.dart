import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:waves/core/locales/locale_text.dart';
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
      return _buttonChildren(
          theme, 'assets/images/auth/hive-keychain-logo.png', "Keychain");
    } else if (authType == AuthType.hiveAuth) {
      return _buttonChildren(
          theme, 'assets/images/auth/hiveauth_icon.png', "Hiveauth");
    } else if (authType == AuthType.hiveSign) {
      return _buttonChildren(
          theme, 'assets/images/auth/hive-signer-logo.png', "Hive Signer");
    } else {
      return Text(
        LocaleText.loginWithPostingKey.tr(),
        style: theme.textTheme.bodyMedium,
      );
    }
  }

  Row _buttonChildren(ThemeData theme, String image, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          image,
          height: 30,
        ),
        const Gap(10),
        Text(
          text,
          style: theme.textTheme.bodyMedium,
        )
      ],
    );
  }
}
