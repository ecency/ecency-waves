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
        Selector<ThreadFeedController, List<ThreadFeedModel>>(
          shouldRebuild: (previous, next) {
            return previous != next || previous.length != next.length;
          },
          selector: (_, myType) => myType.items,
          builder: (context, items, child) {
            return Column(
              children: [
                Selector<ThreadFeedController, List<ThreadFeedModel>>(
                  shouldRebuild: (previous, next) {
                    return previous != next || previous.length != next.length;
                  },
                  selector: (_, myType) => myType.newFeeds,
                  builder: (context, items, child) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: items.isNotEmpty ? 55 : 0,
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
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              ThreadTile(item: items[index]),
                              if (index == items.length - 1)
                                PaginationLoader(
                                  pageVisibilityListener: (context) => context
                                      .select<ThreadFeedController, bool>(
                                          (value) => value.isNextPageLoading),
                                ),
                            ],
                          );
                        },
                        separatorBuilder: (context, index) {
                          return const ThreadFeedDivider();
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _newFeedsPopUpWidget(theme),
        )
      ],
    );
  }

  Selector<ThreadFeedController, List<ThreadFeedModel>> _newFeedsPopUpWidget(
      ThemeData theme) {
    return Selector<ThreadFeedController, List<ThreadFeedModel>>(
      shouldRebuild: (previous, next) {
        return previous != next || previous.length != next.length;
      },
      selector: (_, myType) => myType.newFeeds,
      builder: (context, items, child) {
        if (items.isNotEmpty) {
          return GestureDetector(
            onTap: () {
              if (scrollController.hasClients) {
                scrollController.jumpTo(0);
              }
              context.read<ThreadFeedController>().loadNewFeeds();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: kScreenHorizontalPaddingDigit, vertical: 10),
              decoration: BoxDecoration(color: theme.primaryColor),
              child: Text(
                "Load new content",
                style: theme.textTheme.bodyLarge!.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold),
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
