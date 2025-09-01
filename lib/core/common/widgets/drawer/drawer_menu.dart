import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/extensions/platform_navigation.dart';
import 'package:waves/core/common/extensions/ui.dart';
import 'package:waves/core/common/widgets/drawer/drawer_header.dart';
import 'package:waves/core/common/widgets/drawer/drawer_tile.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/routes/routes.dart';
import 'package:waves/core/routes/route_keys.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/user/view/user_controller.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
          dividerTheme: DividerThemeData(
              thickness: 0.5, color: theme.primaryColorDark.withOpacity(0.4))),
      child: SafeArea(
        child: Container(
          width: 300,
          margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(20),
              ),
              color: theme.colorScheme.tertiary),
          padding: const EdgeInsets.only(top: 30, bottom: 20),
          child: Consumer<UserController>(
              builder: (context, userController, child) {
            final bool isLoggedIn = userController.isUserLoggedIn;
            return Column(
              children: [
                const MyDrawerHeader(),
                const Divider(),
                const Gap(15),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        DrawerTile(
                            onTap: () {
                              Navigator.pop(context);
                              context.platformPushNamed(Routes.exploreView);
                            },
                            text: 'Explore',
                            icon: Icons.explore),
                        if (isLoggedIn)
                          DrawerTile(
                              onTap: () {
                                Navigator.pop(context);
                                context.platformPushNamed(
                                  Routes.userProfileView,
                                  queryParameters: {
                                    RouteKeys.accountName:
                                        userController.userName!,
                                    RouteKeys.threadType:
                                        enumToString(ThreadFeedType.ecency),
                                  },
                                );
                              },
                              text: 'My Waves',
                              icon: Icons.person),
                        DrawerTile(
                            onTap: () {
                              context.popAndPlatformPushNamed(
                                  Routes.bookmarksView);
                            },
                            text: LocaleText.bookmarks,
                            icon: Icons.bookmarks),
                        DrawerTile(
                            onTap: () {
                              context
                                  .popAndPlatformPushNamed(Routes.settingsView);
                            },
                            text: "Settings",
                            icon: Icons.settings),
                        if (isLoggedIn)
                          DrawerTile(
                              onTap: () async {
                                context.showLoader();
                                context
                                    .read<UserController>()
                                    .logOutUser()
                                    .then(
                                  (v) {
                                    context.hideLoader();
                                    Navigator.pop(context);
                                  },
                                );
                              },
                              text: LocaleText.logOut,
                              icon: Icons.logout),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
