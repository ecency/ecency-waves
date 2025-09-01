import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/widgets/pagination_loader.dart';
import 'package:waves/core/common/widgets/scroll_end_listener.dart';
import 'package:waves/core/utilities/constants/ui_constants.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/thread_feed_divider.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/thread_tile.dart';
import 'package:waves/features/explore/presentation/snaps/controller/snaps_feed_controller.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';

class SnapsListView extends StatefulWidget {
  const SnapsListView({super.key});

  @override
  State<SnapsListView> createState() => _SnapsListViewState();
}

class _SnapsListViewState extends State<SnapsListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<SnapsFeedController>();

    return ScrollEndListener(
      loadNextPage: controller.loadNextPage,
      child: RefreshIndicator(
        onRefresh: () async {
          controller.refresh();
        },
        child: Selector<SnapsFeedController, List<ThreadFeedModel>>(
          selector: (_, c) => c.items,
          builder: (context, items, _) {
            return ListView.separated(
              controller: _scrollController,
              padding: kScreenVerticalPadding,
              itemCount: items.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    ThreadTile(item: items[index]),
                    if (index == items.length - 1)
                      PaginationLoader(
                        pageVisibilityListener: (ctx) => ctx
                            .select<SnapsFeedController, bool>(
                                (c) => c.isNextPageLoading),
                      ),
                  ],
                );
              },
              separatorBuilder: (_, __) => const ThreadFeedDivider(),
            );
          },
        ),
      ),
    );
  }
}
