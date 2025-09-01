import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/widgets/pagination_loader.dart';
import 'package:waves/core/common/widgets/scroll_end_listener.dart';
import 'package:waves/core/utilities/constants/ui_constants.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';
import 'package:waves/features/threads/presentation/thread_feed/controller/thread_feed_controller.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/thread_feed_divider.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/thread_tile.dart';

class ThreadListView extends StatefulWidget {
  const ThreadListView({super.key});

  @override
  State<ThreadListView> createState() => _ThreadListViewState();
}

class _ThreadListViewState extends State<ThreadListView> {
  final ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.read<ThreadFeedController>();

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
      ],
    );
  }
}
