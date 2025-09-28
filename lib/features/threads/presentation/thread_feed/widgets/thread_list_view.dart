import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/extensions/ui.dart';
import 'package:waves/core/common/widgets/pagination_loader.dart';
import 'package:waves/core/common/widgets/scroll_end_listener.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/utilities/constants/ui_constants.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/core/routes/routes.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';
import 'package:waves/features/threads/presentation/thread_feed/controller/thread_feed_controller.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/thread_feed_divider.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/thread_tile.dart';

class ThreadListView extends StatelessWidget {
  const ThreadListView({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.read<ThreadFeedController>();
    final double fabBottomOffset =
        16 + MediaQuery.of(context).padding.bottom;

    return Stack(
      children: [
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
                    LocaleText.loadNewContent,
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

        Positioned(
          bottom: fabBottomOffset,
          right: 16,
          child: FloatingActionButton(
            heroTag: 'forYouComposeFab',
            backgroundColor: theme.primaryColor,
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            onPressed: () => _onCreateThread(context, controller),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  void _onCreateThread(
      BuildContext context, ThreadFeedController controller) {
    context.authenticatedAction(action: () {
      context.pushNamed(Routes.addCommentView).then((value) {
        if (value != null && value is ThreadFeedModel) {
          controller.refreshOnRootComment(value);
        }
      });
    });
  }
}
