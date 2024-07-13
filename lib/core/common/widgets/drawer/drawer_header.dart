import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/extensions/platform_navigation.dart';
import 'package:waves/core/common/widgets/images/user_profile_image.dart';
import 'package:waves/core/common/widgets/inkwell_wrapper.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/routes/routes.dart';
import 'package:waves/core/utilities/constants/ui_constants.dart';
import 'package:waves/features/user/presentation/multi_account/view/multi_account_dialog_view.dart';
import 'package:waves/features/user/view/user_controller.dart';

class MyDrawerHeader extends StatelessWidget {
  const MyDrawerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userController = context.read<UserController>();
    final bool isLoggedIn = userController.isUserLoggedIn;
    return InkWellWrapper(
      isStackWrapper: !isLoggedIn,
      onTap: () {
        if (userController.userData == null) {
          context.popAndPlatformPushNamed(Routes.authView);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: kScreenHorizontalPaddingDigit),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
                child: UserProfileImage(
                    defaultIconSize: 50,
                    radius: 40,
                    url: userController.userData?.accountName ?? "")),
            Center(
              child: !isLoggedIn
                  ? _headerText(LocaleText.login, theme)
                  : Padding(
                      padding: const EdgeInsets.only(left: 14.0),
                      child: InkWellWrapper(
                        onTap: () => _openMultiAccountDialog(context),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: _headerText(
                                  userController.userData!.accountName,
                                  theme),
                            ),
                            const Gap(8),
                            const Icon(Icons.arrow_drop_down)
                          ],
                        ),
                      ),
                    ),
            ),
            const Gap(15),
          ],
        ),
      ),
    );
  }

  void _openMultiAccountDialog(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => const MultiAccountDialog(),
    );
  }

  Text _headerText(String text, ThemeData theme) {
    return Text(
      text,
      style: theme.textTheme.bodyLarge,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
