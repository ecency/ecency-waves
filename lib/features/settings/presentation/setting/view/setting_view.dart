import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/widgets/drawer/drawer_tile.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/utilities/theme/theme_mode.dart';
import 'package:waves/features/settings/presentation/setting/controller/settings_controller.dart';
import 'package:waves/features/settings/presentation/setting/widgets/default_thread_dropdown.dart';
import 'package:waves/features/user/view/user_controller.dart';

class SettingView extends StatelessWidget {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.read<ThemeController>();


    onDeletePress(){
      UserController userController = context.read<UserController>();
      //TODO: add delete api call here
      userController.logOutUser();
    }


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

                 DrawerTile(
                    onTap: onDeletePress,
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
}
