import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/extensions/ui.dart';
import 'package:waves/core/common/widgets/pagination_loader.dart';
import 'package:waves/core/common/widgets/scroll_end_listener.dart';
import 'package:waves/core/common/widgets/images/user_profile_image.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/routes/routes.dart';
import 'package:waves/core/utilities/constants/ui_constants.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';
import 'package:waves/features/threads/presentation/thread_feed/controller/following_feed_controller.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/thread_feed_divider.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/thread_tile.dart';
import 'package:waves/features/user/view/user_controller.dart';

class FollowingListView extends StatelessWidget {
  const FollowingListView({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.read<FollowingFeedController>();
    final double fabBottomOffset =
        16 + MediaQuery.of(context).padding.bottom;

    return Stack(
      children: [
        Selector<FollowingFeedController, List<ThreadFeedModel>>(
          selector: (_, c) => c.items,
          builder: (context, items, _) {
            return Column(
              children: [
                _composePrompt(context, theme, controller),
                Expanded(
                  child: ScrollEndListener(
                    loadNextPage: controller.loadNextPage,
                    child: RefreshIndicator(
                      onRefresh: controller.refresh,
                      child: ListView.separated(
                        padding: kScreenVerticalPadding,
                        controller: scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              ThreadTile(
                                item: items[index],
                                threadType: controller.threadType,
                              ),
                              if (index == items.length - 1)
                                PaginationLoader(
                                  pageVisibilityListener: (ctx) => ctx
                                      .select<FollowingFeedController, bool>(
                                          (c) => c.isNextPageLoading),
                                ),
                            ],
                          );
                        },
                        separatorBuilder: (_, __) => const ThreadFeedDivider(),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        Positioned(
          bottom: fabBottomOffset,
          right: 16,
          child: FloatingActionButton(
            heroTag: 'followingComposeFab',
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            onPressed: () => _onCreateThread(context, controller),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Widget _composePrompt(BuildContext context, ThemeData theme,
      FollowingFeedController controller) {
    final userController = context.read<UserController>();
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: kScreenHorizontalPaddingDigit, vertical: 10),
      child: Row(
        children: [
          UserProfileImage(url: userController.userName),
          Gap(10),
          Expanded(
            child: GestureDetector(
              onTap: () {
                context.authenticatedAction(action: () {
                  context.pushNamed(Routes.addCommentView).then((value) {
                    if (value != null && value is ThreadFeedModel) {
                      controller.refresh();
                    }
                  });
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiaryContainer,
                  border: Border.all(color: theme.colorScheme.tertiary),
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        LocaleText.whatsHappening,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onTertiaryContainer,
                        ),
                      ),
                    ),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.add,
                        size: 18,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onCreateThread(
      BuildContext context, FollowingFeedController controller) {
    context.authenticatedAction(action: () {
      context.pushNamed(Routes.addCommentView).then((value) {
        if (value != null && value is ThreadFeedModel) {
          controller.refresh();
        }
      });
    });
  }
}
