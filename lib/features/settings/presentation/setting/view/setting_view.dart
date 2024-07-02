import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/widgets/drawer/drawer_tile.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/utilities/theme/theme_mode.dart';
import 'package:waves/features/settings/presentation/setting/controller/settings_controller.dart';
import 'package:waves/features/settings/presentation/setting/widgets/default_thread_dropdown.dart';

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
                 DrawerTile(
                  text: "Default Wave",
                  icon: Icons.help_outline,
                  trailing: DefaultThreadDropdown(),
                )
              ],
            ),
          )),
        );
      },
    );
  }
}
