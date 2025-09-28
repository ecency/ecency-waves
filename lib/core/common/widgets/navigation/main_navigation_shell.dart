import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/extensions/platform_navigation.dart';
import 'package:waves/core/routes/routes.dart';
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
      item: BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: '',
      ),
    ),
    _NavigationDestination(
      routeName: Routes.searchView,
      location: '/${Routes.searchView}',
      item: BottomNavigationBarItem(
        icon: Icon(Icons.search_outlined),
        activeIcon: Icon(Icons.search),
        label: '',
      ),
    ),
    _NavigationDestination(
      routeName: Routes.exploreView,
      location: '/${Routes.exploreView}',
      item: BottomNavigationBarItem(
        icon: Icon(Icons.explore_outlined),
        activeIcon: Icon(Icons.explore),
        label: '',
      ),
    ),
    _NavigationDestination(
      routeName: Routes.notificationsView,
      location: '/${Routes.notificationsView}',
      item: BottomNavigationBarItem(
        icon: Icon(Icons.notifications_none_outlined),
        activeIcon: Icon(Icons.notifications),
        label: '',
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoggedIn =
        context.select<UserController, bool>((controller) => controller.isUserLoggedIn);
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
        items: _destinations.map((destination) => destination.item).toList(),
      ),
    );
  }
}

class _NavigationDestination {
  const _NavigationDestination({
    required this.routeName,
    required this.location,
    required this.item,
  });

  final String routeName;
  final String location;
  final BottomNavigationBarItem item;
}
