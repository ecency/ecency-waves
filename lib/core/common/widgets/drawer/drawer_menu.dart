import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/extensions/platform_navigation.dart';
import 'package:waves/core/common/extensions/ui.dart';
import 'package:waves/core/common/widgets/drawer/drawer_header.dart';
import 'package:waves/core/common/widgets/drawer/drawer_tile.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/routes/routes.dart';
import 'package:waves/core/routes/route_keys.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/settings/repository/settings_repository.dart';
import 'package:waves/features/user/view/user_controller.dart';
import 'package:waves/core/dependency_injection/dependency_injection.dart';
import 'package:waves/features/notifications/presentation/controller/notifications_controller.dart';

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
                        if (isLoggedIn) ...[
                          DrawerTile(
                              onTap: () {
                                Navigator.pop(context);
                                final threadType =
                                    getIt<SettingsRepository>()
                                        .readDefaultThread();
                                context.platformPushNamed(
                                  Routes.userProfileView,
                                  queryParameters: {
                                    RouteKeys.accountName:
                                        userController.userName!,
                                    RouteKeys.threadType:
                                        enumToString(threadType),
                                  },
                                );
                              },
                              text: LocaleText.myWaves,
                              icon: Icons.person),
                          Consumer<NotificationsController>(
                            builder: (context, notificationsController, child) {
                              Widget? trailing;
                              if (notificationsController.unreadCount > 0) {
                                trailing = Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    notificationsController.unreadCount
                                        .toString(),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              }

                              return DrawerTile(
                                onTap: () {
                                  context.popAndPlatformPushNamed(
                                      Routes.notificationsView);
                                },
                                text: LocaleText.notifications,
                                icon: Icons.notifications,
                                trailing: trailing,
                              );
                            },
                          ),
                        ],
                        DrawerTile(
                            onTap: () {
                              context.popAndPlatformPushNamed(
                                  Routes.bookmarksView);
                            },
                            text: LocaleText.bookmarks,
                            icon: Icons.bookmarks),
                        DrawerTile(
                            onTap: () {
                              Navigator.pop(context);
                              context.platformPushNamed(Routes.exploreView);
                            },
                            text: LocaleText.explore,
                            icon: Icons.explore),
                        DrawerTile(
                            onTap: () {
                              context
                                  .popAndPlatformPushNamed(Routes.settingsView);
                            },
                            text: LocaleText.settings,
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
                const Gap(12),
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox.shrink();
                    }
                    final packageInfo = snapshot.data!;
                    final version = packageInfo.version;
                    final buildNumber = packageInfo.buildNumber;
                    final theme = Theme.of(context);
                    return Text(
                      LocaleText.versionInfo(version, buildNumber),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    );
                  },
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
