import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/extensions/ui.dart';
import 'package:waves/core/common/widgets/drawer/drawer_tile.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/utilities/theme/theme_mode.dart';
import 'package:waves/features/settings/presentation/setting/controller/settings_controller.dart';
import 'package:waves/features/settings/presentation/setting/widgets/default_thread_dropdown.dart';
import 'package:waves/features/settings/presentation/setting/widgets/delete_account_dialog.dart';
import 'package:waves/features/user/view/user_controller.dart';

class SettingView extends StatelessWidget {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.read<ThemeController>();

    return Provider(
      create: (context) => SettingsController(),
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Settings"),
          ),
          body: SafeArea(
              child: SingleChildScrollView(
            child: Column(
              children: [
                DrawerTile(
                    onTap: () {
                      themeController.toggleTheme();
                    },
                    text: themeController.isLightTheme()
                        ? LocaleText.darkMode
                        : LocaleText.lightMode,
                    icon: themeController.isLightTheme()
                        ? Icons.dark_mode
                        : Icons.light_mode),
                const DrawerTile(
                  text: "Default Feed",
                  icon: Icons.help_outline,
                  trailing: DefaultThreadDropdown(),
                ),
                if (context.read<UserController>().isUserLoggedIn)
                  DrawerTile(
                    onTap: () => onDeletePress(context),
                    text: LocaleText.deleteAccount,
                    icon: Icons.delete_forever,
                    color: Colors.red[600],
                  ),
              ],
            ),
          )),
        );
      },
    );
  }

  onDeletePress(BuildContext context) {
    UserController userController = context.read<UserController>();
    SettingsController controller = context.read<SettingsController>();
    showDialog(
        context: context,
        builder: (_) {
          return DeleteAccountDialog(
            onDelete: () {
              context.showLoader();
              controller
                  .deleteAccount(userController.userName!)
                  .then((response) {
                if (context.mounted) {
                  context.hideLoader();
                  if (response.isSuccess) {
                    context
                        .showSnackBar("Account has been deleted successfully");
                    userController.logOutUser();
                    context.pop();
                  } else {
                    context.showSnackBar(response.errorMessage);
                  }
                }
              });
            },
          );
        });
    // userController.logOutUser();
  }
}
