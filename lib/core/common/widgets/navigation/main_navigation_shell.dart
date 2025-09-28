import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/extensions/platform_navigation.dart';
import 'package:waves/core/routes/routes.dart';
import 'package:waves/features/notifications/presentation/controller/notifications_controller.dart';
import 'package:waves/features/user/view/user_controller.dart';

class MainNavigationShell extends StatelessWidget {
  const MainNavigationShell({
    super.key,
    required this.state,
    required this.child,
  });

  final GoRouterState state;
  final Widget child;

  static const List<_NavigationDestination> _destinations = [
    _NavigationDestination(
      routeName: Routes.initialView,
      location: '/',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
    ),
    _NavigationDestination(
      routeName: Routes.searchView,
      location: '/${Routes.searchView}',
      icon: Icons.search_outlined,
      activeIcon: Icons.search,
    ),
    _NavigationDestination(
      routeName: Routes.exploreView,
      location: '/${Routes.exploreView}',
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore,
    ),
    _NavigationDestination(
      routeName: Routes.notificationsView,
      location: '/${Routes.notificationsView}',
      icon: Icons.notifications_none_outlined,
      activeIcon: Icons.notifications,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoggedIn =
        context.select<UserController, bool>((controller) => controller.isUserLoggedIn);
    final unreadCount = context.select<NotificationsController, int>(
      (controller) => controller.unreadCount,
    );
    final location = state.uri.path;
    var currentIndex =
        _destinations.indexWhere((destination) => destination.location == location);

    if (currentIndex < 0) {
      currentIndex = 0;
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        selectedItemColor: theme.primaryColor,
        unselectedItemColor: theme.iconTheme.color,
        onTap: (index) {
          final destination = _destinations[index];

          if (destination.routeName == Routes.notificationsView && !isLoggedIn) {
            context.platformPushNamed(Routes.authView);
            return;
          }

          if (destination.location != location) {
            context.goNamed(destination.routeName);
          }
        },
        items: _destinations.map((destination) {
          final isNotifications = destination.routeName == Routes.notificationsView;
          final iconWidget = isNotifications
              ? _NotificationNavIcon(
                  iconData: destination.icon,
                  unreadCount: unreadCount,
                )
              : Icon(destination.icon);
          final activeIconWidget = isNotifications
              ? _NotificationNavIcon(
                  iconData: destination.activeIcon,
                  unreadCount: unreadCount,
                )
              : Icon(destination.activeIcon);

          return BottomNavigationBarItem(
            icon: iconWidget,
            activeIcon: activeIconWidget,
            label: destination.label,
          );
        }).toList(),
      ),
    );
  }
}

class _NavigationDestination {
  const _NavigationDestination({
    required this.routeName,
    required this.location,
    required this.icon,
    required this.activeIcon,
    this.label = '',
  });

  final String routeName;
  final String location;
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class _NotificationNavIcon extends StatelessWidget {
  const _NotificationNavIcon({
    required this.iconData,
    required this.unreadCount,
  });

  final IconData iconData;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(iconData);

    if (unreadCount <= 0) {
      return icon;
    }

    final theme = Theme.of(context);
    final text = unreadCount > 99 ? '99+' : unreadCount.toString();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        icon,
        Positioned(
          right: -8,
          top: -4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: theme.scaffoldBackgroundColor,
                width: 1,
              ),
            ),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            child: Center(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ) ??
                    TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
