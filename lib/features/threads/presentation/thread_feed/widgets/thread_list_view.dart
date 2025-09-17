import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/extensions/ui.dart';
import 'package:waves/core/common/widgets/back_to_top_button.dart';
import 'package:waves/core/common/widgets/pagination_loader.dart';
import 'package:waves/core/common/widgets/scroll_end_listener.dart';
import 'package:waves/core/common/widgets/images/user_profile_image.dart';
import 'package:waves/core/utilities/constants/ui_constants.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/core/routes/routes.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';
import 'package:waves/features/threads/presentation/thread_feed/controller/thread_feed_controller.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/thread_feed_divider.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/thread_tile.dart';
import 'package:waves/features/user/view/user_controller.dart';

class ThreadListView extends StatefulWidget {
  const ThreadListView({super.key});

  @override
  State<ThreadListView> createState() => _ThreadListViewState();
}

class _ThreadListViewState extends State<ThreadListView> {
  final ScrollController scrollController = ScrollController();
  bool showBackToTopButton = false;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    final double triggerHeight = MediaQuery.of(context).size.height;
    if (scrollController.offset > triggerHeight && !showBackToTopButton) {
      setState(() {
        showBackToTopButton = true;
      });
    } else if (scrollController.offset <= triggerHeight && showBackToTopButton) {
      setState(() {
        showBackToTopButton = false;
      });
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.read<ThreadFeedController>();
    final double backToTopBottomOffset =
        16 + MediaQuery.of(context).padding.bottom;

    return Stack(
      children: [
        // (Optional) tiny probe to verify item count changes
        Selector<ThreadFeedController, int>(
          selector: (_, c) => c.items.length,
          builder: (_, len, __) {
            debugPrint('[LIST] items.length=$len');
            return const SizedBox.shrink();
          },
        ),

        Selector<ThreadFeedController, List<ThreadFeedModel>>(
          selector: (_, c) => c.items,
          // NOTE: no custom shouldRebuild — rely on new list identity from controller
          builder: (context, items, _) {
            return Column(
              children: [
                // Spacer for the “new content” banner height
                Selector<ThreadFeedController, bool>(
                  selector: (_, c) => c.newFeeds.isNotEmpty,
                  builder: (context, hasNew, _) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: hasNew ? 55 : 0,
                      width: double.infinity,
                    );
                  },
                ),
                _composePrompt(theme, controller),
                Expanded(
                  child: ScrollEndListener(
                    loadNextPage: () =>
                        controller.loadNextPage(type: controller.threadType),
                    child: RefreshIndicator(
                      key: ValueKey(enumToString(controller.threadType)),
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
                              // FIX: provide required pageVisibilityListener
                                PaginationLoader(
                                  pageVisibilityListener: (ctx) => ctx
                                      .select<ThreadFeedController, bool>(
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

        // “Load new content” banner
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Selector<ThreadFeedController, bool>(
            selector: (_, c) => c.newFeeds.isNotEmpty,
            builder: (context, hasNew, _) {
              if (!hasNew) return const SizedBox.shrink();
              return GestureDetector(
                onTap: () {
                  if (scrollController.hasClients) {
                    scrollController.jumpTo(0);
                  }
                  context.read<ThreadFeedController>().loadNewFeeds();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kScreenHorizontalPaddingDigit,
                    vertical: 10,
                  ),
                  color: theme.primaryColor,
                  child: Text(
                    'Load new content',
                    style: theme.textTheme.bodyLarge!.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Back to top button
        Positioned(
          bottom: backToTopBottomOffset,
          right: 16,
          child: Visibility(
            visible: showBackToTopButton,
            child: BackToTopButton(
              onPressed: () {
                if (scrollController.hasClients) {
                  scrollController.animateTo(0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Top input bar encouraging users to publish new content.
  Widget _composePrompt(ThemeData theme, ThreadFeedController controller) {
    final userController = context.read<UserController>();
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: kScreenHorizontalPaddingDigit, vertical: 10),
      child: Row(
        children: [
          UserProfileImage(url: userController.userName),
          const Gap(10),
          Expanded(
            child: GestureDetector(
              onTap: () {
                context.authenticatedAction(action: () {
                  context.pushNamed(Routes.addCommentView).then((value) {
                    if (value != null && value is ThreadFeedModel) {
                      controller.refreshOnRootComment(value);
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
                        "What's happening?",
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
}
