import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';
import 'package:waves/features/threads/presentation/thread_feed/controller/thread_feed_controller.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/thread_feed_divider.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/thread_tile.dart';

class ThreadListView extends StatelessWidget {
  const ThreadListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<ThreadFeedController, List<ThreadFeedModel>>(
      shouldRebuild: (previous, next) {
        return previous != next || previous.length != next.length;
      },
      selector: (_, myType) => myType.items,
      builder: (context, items, child) {
        return ListView.separated(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return ThreadTile(item: items[index]);
          },
          separatorBuilder: (context, index) {
            return const ThreadFeedDivider();
          },
        );
      },
    );
  }
}
