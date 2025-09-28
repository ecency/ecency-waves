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
import 'package:waves/features/threads/presentation/thread_feed/controller/following_feed_controller.dart';
import 'package:waves/features/threads/presentation/thread_feed/controller/thread_feed_controller.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/drop_down_filter.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/following_list_view.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/thread_list_view.dart';
import 'package:waves/features/user/view/user_controller.dart';

class ThreadFeedView extends StatefulWidget {
  const ThreadFeedView({
    super.key,
  });

  @override
  State<ThreadFeedView> createState() => _ThreadFeedViewState();
}

class _ThreadFeedViewState extends State<ThreadFeedView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final ScrollController _forYouScrollController;
  late final ScrollController _followingScrollController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _forYouScrollController = ScrollController();
    _followingScrollController = ScrollController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _forYouScrollController.dispose();
    _followingScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final forYouController = context.read<ThreadFeedController>();
    final followingController = context.read<FollowingFeedController>();
    final isLoggedIn =
        context.select<UserController, bool>((c) => c.isUserLoggedIn);

    return Scaffold(
      drawer: const DrawerMenu(),
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: DropDownFilter(onChanged: (type) {
          forYouController.onTapFilter(type);
          followingController.updateThreadType(type);
        }),
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            final isReselected = _tabController.index == index;
            if (!isReselected) return;

            if (index == 0 && _forYouScrollController.hasClients) {
              _forYouScrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            } else if (index == 1 &&
                isLoggedIn &&
                _followingScrollController.hasClients) {
              _followingScrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          },
          tabs: [
            Tab(text: LocaleText.forYou),
            Tab(text: LocaleText.following),
          ],
        ),
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
        child: TabBarView(
          controller: _tabController,
          children: [
            _ForYouTab(scrollController: _forYouScrollController),
            _FollowingTab(
              scrollController: _followingScrollController,
            ),
          ],
        ),
      ),
    );
  }
}

class _ForYouTab extends StatelessWidget {
  const _ForYouTab({required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final controller = context.read<ThreadFeedController>();
    return Selector<ThreadFeedController, ViewState>(
      selector: (_, provider) => provider.viewState,
      builder: (context, value, child) {
        if (value == ViewState.data) {
          return ThreadListView(scrollController: scrollController);
        } else if (value == ViewState.empty) {
          return Emptystate(
            icon: Icons.hourglass_empty,
            text: LocaleText.noThreadsFound,
          );
        } else if (value == ViewState.error) {
          return ErrorState(
            showRetryButton: true,
            onTapRetryButton: () => controller.refresh(),
          );
        } else {
          return const LoadingState();
        }
      },
    );
  }
}

class _FollowingTab extends StatelessWidget {
  const _FollowingTab({required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final isLoggedIn =
        context.select<UserController, bool>((c) => c.isUserLoggedIn);
    if (!isLoggedIn) {
      return const _LoginPrompt();
    }

    final controller = context.read<FollowingFeedController>();
    return Selector<FollowingFeedController, ViewState>(
      selector: (_, provider) => provider.viewState,
      builder: (context, value, child) {
        if (value == ViewState.data) {
          return FollowingListView(scrollController: scrollController);
        } else if (value == ViewState.empty) {
          return Emptystate(
            icon: Icons.hourglass_empty,
            text: LocaleText.noThreadsFound,
          );
        } else if (value == ViewState.error) {
          return ErrorState(
            showRetryButton: true,
            onTapRetryButton: () => controller.refresh(),
          );
        } else {
          return const LoadingState();
        }
      },
    );
  }
}

class _LoginPrompt extends StatelessWidget {
  const _LoginPrompt();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_alt_outlined,
              size: 64,
              color: theme.primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              LocaleText.pleaseLoginFirst,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                context.platformPushNamed(Routes.authView);
              },
              child: Text(LocaleText.login),
            ),
          ],
        ),
      ),
    );
  }
}
