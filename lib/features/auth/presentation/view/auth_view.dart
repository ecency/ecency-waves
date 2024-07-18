import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:waves/core/common/extensions/platform_navigation.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/routes/routes.dart';
import 'package:waves/core/utilities/act.dart';
import 'package:waves/core/utilities/constants/ui_constants.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/auth/presentation/widgets/auth_button.dart';

class AuthView extends StatelessWidget {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleText.login.tr()),
      ),
      body: SafeArea(
        child: Padding(
          padding: kScreenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthButton(
                  authType: AuthType.postingKey,
                  onTap: () => context.pushNamed(Routes.postingKeyAuthView),
                  label: "Private Key"),
              const Gap(15),
              AuthButton(
                  authType: AuthType.hiveSign,
                  onTap: () => onHiveSignLoginTap(context),
                  label: "Hivesigner"),
              const Gap(15),
              AuthButton(
                authType: AuthType.hiveKeyChain,
                onTap: () => context.pushNamed(Routes.hiveKeyChainAuthView,
                    extra: AuthType.hiveKeyChain),
                label: "HiveKeychain"
              ),
              const Gap(15),
              AuthButton(
                authType: AuthType.hiveAuth,
                onTap: () => context.pushNamed(Routes.hiveKeyChainAuthView,
                    extra: AuthType.hiveAuth),
                label: "HiveAuth"
              ),
              const Spacer(),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: Text("Don't have an account?")),
                  const Gap(10),
                  signUpButton(theme),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  SizedBox signUpButton(ThemeData theme) {
    return SizedBox(
      height: AuthButton.buttonHeight,
      child: ElevatedButton(
        onPressed: () => Act.launchThisUrl("https://ecency.com/signup"),
        style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
            shape: RoundedRectangleBorder(
                side:
                    BorderSide(color: theme.primaryColorDark.withOpacity(0.5)),
                borderRadius: const BorderRadius.all(Radius.circular(40))),
            surfaceTintColor: theme.primaryColorLight,
            backgroundColor: theme.primaryColor),
        child: Text(
          "Sign up",
          style: theme.textTheme.bodyMedium,
        ),
      ),
    );
  }

  void onHiveSignLoginTap(BuildContext context) async {
    context.platformPushNamed(
      Routes.hiveSignView,
    );
  }
}
