import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/extensions/platform_navigation.dart';
import 'package:waves/core/common/extensions/ui.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/routes/route_keys.dart';
import 'package:waves/core/routes/routes.dart';
import 'package:waves/core/utilities/constants/ui_constants.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/auth/presentation/widgets/auth_button.dart';
import 'package:waves/features/auth/presentation/widgets/auth_textfield.dart';
import 'package:waves/features/user/view/user_controller.dart';

class HiveKeyChainAuthView extends StatefulWidget {
  const HiveKeyChainAuthView({super.key, required this.authType});

  final AuthType authType;

  @override
  State<HiveKeyChainAuthView> createState() => _HiveKeyChainAuthViewState();
}

class _HiveKeyChainAuthViewState extends State<HiveKeyChainAuthView> {
  final TextEditingController accountNameController = TextEditingController();

  @override
  void dispose() {
    accountNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          "${widget.authType == AuthType.hiveAuth ? "HiveAuth" : "HiveKeyChain"} Login",
          minFontSize: 16,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: kScreenPadding,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthTextField(
                    hintText: LocaleText.username,
                    textEditingController: accountNameController),
                const Gap(20),
                if (widget.authType == AuthType.hiveKeyChain)
                  AuthButton(
                      authType: AuthType.hiveKeyChain,
                      onTap: () => onHiveAuthLoginTap(AuthType.hiveKeyChain),
                      label: "HiveKeychain"),
                if (widget.authType == AuthType.hiveAuth)
                  AuthButton(
                      authType: AuthType.hiveAuth,
                      onTap: () => onHiveAuthLoginTap(AuthType.hiveAuth),
                      label: "HiveAuth"),
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
      context.showSnackBar(LocaleText.pleaseEnterTheUsername);
    } else if (context.read<UserController>().isAccountDeleted(accountName)) {
      context.showSnackBar(LocaleText.theAccountDoesntExist);
    } else {
      if (type == AuthType.hiveKeyChain) {
        context.platformPushNamed(Routes.hiveAuthTransactionView,
            queryParameters: {
              RouteKeys.accountName: accountName,
              RouteKeys.isHiveKeyChainLogin: 'true'
            });
      } else if (type == AuthType.hiveAuth) {
        context.platformPushNamed(Routes.hiveAuthTransactionView,
            queryParameters: {
              RouteKeys.accountName: accountName,
              RouteKeys.isHiveKeyChainLogin: 'false'
            });
      }
    }
  }
}
