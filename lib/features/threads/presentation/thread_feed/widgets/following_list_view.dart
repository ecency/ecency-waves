import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/widgets/locale_aware_consumer.dart';
import 'package:waves/core/common/extensions/ui.dart';
import 'package:waves/core/common/widgets/pagination_loader.dart';
import 'package:waves/core/common/widgets/scroll_end_listener.dart';
import 'package:waves/core/routes/routes.dart';
import 'package:waves/core/utilities/constants/ui_constants.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';
import 'package:waves/features/threads/presentation/thread_feed/controller/following_feed_controller.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/thread_feed_divider.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/thread_tile.dart';

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
        LocaleAwareSelector<FollowingFeedController, List<ThreadFeedModel>>(
          selector: (_, c) => c.items,
          builder: (context, items, _) {
            return ScrollEndListener(
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
                          showVoteAndCommentCount: false,
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
            );
          },
        ),
        Positioned(
          bottom: fabBottomOffset,
          right: 16,
          child: FloatingActionButton(
            heroTag: 'followingComposeFab',
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
