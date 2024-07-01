import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:waves/core/common/extensions/platform_navigation.dart';
import 'package:waves/core/common/extensions/ui.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/routes/route_keys.dart';
import 'package:waves/core/routes/routes.dart';
import 'package:waves/core/utilities/constants/ui_constants.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/auth/presentation/controller/posting_auth_controller.dart';
import 'package:waves/features/auth/presentation/widgets/auth_button.dart';
import 'package:waves/features/auth/presentation/widgets/auth_textfield.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  final TextEditingController accountNameController = TextEditingController();
  final TextEditingController postingKeyController = TextEditingController();
  final PostingAuthController postingAuthController = PostingAuthController();

  @override
  void dispose() {
    accountNameController.dispose();
    postingAuthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(LocaleText.login.tr()),
      ),
      body: SafeArea(
        child: Padding(
          padding: kScreenPadding,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthTextField(
                    hintText: LocaleText.username.tr(),
                    textEditingController: accountNameController),
                const Gap(15),
                AuthTextField(
                    hintText: LocaleText.postingKey.tr(),
                    isPassword: true,
                    leading: const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Icon(Icons.key),
                    ),
                    textEditingController: postingKeyController),
                const Gap(20),
                AuthButton(
                    authType: AuthType.postingKey, onTap: onPostingLoginTap),
                const Gap(15),
                AuthButton(
                    authType: AuthType.hiveSign, onTap: onHiveSignLoginTap),
                const Gap(15),
                AuthButton(
                  authType: AuthType.hiveKeyChain,
                  onTap: () => onHiveAuthLoginTap(AuthType.hiveKeyChain),
                ),
                const Gap(15),
                AuthButton(
                  authType: AuthType.hiveAuth,
                  onTap: () => onHiveAuthLoginTap(AuthType.hiveAuth),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onHiveAuthLoginTap(AuthType type) {
    String accountName = accountNameController.text.trim().toLowerCase();
    if (accountName.isEmpty) {
      context.showSnackBar(LocaleText.pleaseEnterTheUsername.tr());
    } else {
      if (type == AuthType.hiveKeyChain) {
        context.platformPushNamed(Routes.hiveAuthView, queryParameters: {
          RouteKeys.accountName: accountName,
          RouteKeys.isHiveKeyChainLogin: 'true'
        });
      } else if (type == AuthType.hiveAuth) {
        context.platformPushNamed(Routes.hiveAuthView, queryParameters: {
          RouteKeys.accountName: accountName,
          RouteKeys.isHiveKeyChainLogin: 'false'
        });
      }
    }
  }

  void onHiveSignLoginTap() async {
    context.platformPushNamed(
      Routes.hiveSignView,
    );
  }

  void onPostingLoginTap() async {
    String accountName = accountNameController.text.trim().toLowerCase();
    if (accountName.isEmpty) {
      context.showSnackBar(LocaleText.pleaseEnterTheUsername.tr());
    }else if(postingKeyController.text.trim().isEmpty){
      context.showSnackBar(LocaleText.pleaseEnterThePostingKey.tr());
    } else {
      await postingAuthController.validatePostingKey(
        postingKey: postingKeyController.text.trim(),
        showLoader: () => context.showLoader(),
        hideLoader: () => context.hideLoader(),
        accountName,
        showToast: (message) {
          context.showSnackBar(message);
        },
        onSuccess: () {
          Navigator.pop(context);
        },
      );
    }
  }
}
