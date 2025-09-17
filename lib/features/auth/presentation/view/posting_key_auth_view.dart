import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/extensions/ui.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/utilities/constants/ui_constants.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/auth/presentation/controller/posting_auth_controller.dart';
import 'package:waves/features/auth/presentation/widgets/auth_button.dart';
import 'package:waves/features/auth/presentation/widgets/auth_textfield.dart';
import 'package:waves/features/user/view/user_controller.dart';

class PostingKeyAuthView extends StatefulWidget {
  const PostingKeyAuthView({super.key});

  @override
  State<PostingKeyAuthView> createState() => _PostingKeyAuthViewState();
}

class _PostingKeyAuthViewState extends State<PostingKeyAuthView> {
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
        title: const Text("PrivateKey Login"),
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
                    hintText: "posting private key",
                    isPassword: true,
                    leading: const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Icon(Icons.key),
                    ),
                    textEditingController: postingKeyController),
                const Gap(20),
                AuthButton(
                    authType: AuthType.postingKey,
                    onTap: onPostingLoginTap,
                    label: "Login"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onPostingLoginTap() async {
    String accountName = accountNameController.text.trim().toLowerCase();
    if (accountName.isEmpty) {
      context.showSnackBar(LocaleText.pleaseEnterTheUsername.tr());
    } else if (context.read<UserController>().isAccountDeleted(accountName)) {
      context.showSnackBar(LocaleText.theAccountDoesntExist.tr());
    } else if (postingKeyController.text.trim().isEmpty) {
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
          Navigator.pop(context);
        },
      );
    }
  }
}
