import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/extensions/platform_navigation.dart';
import 'package:waves/core/common/widgets/drawer/drawer_menu.dart';
import 'package:waves/core/common/widgets/empty_state.dart';
import 'package:waves/core/common/widgets/loading_state.dart';
import 'package:waves/core/common/widgets/server_error.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/routes/routes.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/notifications/presentation/controller/notifications_controller.dart';
import 'package:waves/features/threads/presentation/thread_feed/controller/thread_feed_controller.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/drop_down_filter.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/thread_list_view.dart';
import 'package:waves/features/user/view/user_controller.dart';

class ThreadFeedView extends StatelessWidget {
  const ThreadFeedView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.read<ThreadFeedController>();
    final isLoggedIn =
        context.select<UserController, bool>((c) => c.isUserLoggedIn);
    final theme = Theme.of(context);
    return Scaffold(
        drawer: const DrawerMenu(),
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          title: DropDownFilter(onChanged: (type) {
            controller.onTapFilter(type);
          }),
          actions: [
            if (isLoggedIn)
              Consumer<NotificationsController>(
                builder: (context, notificationsController, child) {
                  final theme = Theme.of(context);
                  final unread = notificationsController.unreadCount;
                  return IconButton(
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          Icons.notifications_none_outlined,
                          color: theme.primaryColor,
                        ),
                        if (unread > 0)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.primaryColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                unread > 99 ? '99+' : unread.toString(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    tooltip: LocaleText.notifications,
                    onPressed: () {
                      context.platformPushNamed(Routes.notificationsView);
                    },
                  );
                },
              ),
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: LocaleText.search,
              onPressed: () {
                context.platformPushNamed(Routes.searchView);
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Selector<ThreadFeedController, ViewState>(
            selector: (_, provider) => provider.viewState,
            builder: (context, value, child) {
              if (value == ViewState.data) {
                return ThreadListView();
              } else if (value == ViewState.empty) {
                return Emptystate(
                    icon: Icons.hourglass_empty,
                    text: LocaleText.noThreadsFound);
              } else if (value == ViewState.error) {
                return ErrorState(
                  showRetryButton: true,
                  onTapRetryButton: () => controller.refresh(),
                );
              } else {
                return const LoadingState();
              }
            },
          ),
        ));
  }
}
