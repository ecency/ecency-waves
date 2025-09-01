import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/explore/presentation/snaps/controller/snaps_feed_controller.dart';
import 'package:waves/features/explore/presentation/widgets/snaps_list_view.dart';
import 'package:waves/features/explore/presentation/widgets/thread_type_dropdown.dart';

class TagFeedView extends StatelessWidget {
  final String tag;
  final ThreadFeedType threadType;

  const TagFeedView({super.key, required this.tag, required this.threadType});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SnapsFeedController.tag(tag: tag, threadType: threadType),
      child: Builder(builder: (context) {
        final controller = context.read<SnapsFeedController>();
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Text('#$tag'),
                const Spacer(),
                ThreadTypeDropdown(
                  value: controller.threadType,
                  onChanged: controller.updateThreadType,
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: Selector<SnapsFeedController, ViewState>(
              selector: (_, c) => c.viewState,
              builder: (context, state, _) {
                if (state == ViewState.loading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state == ViewState.data) {
                  return const SnapsListView();
                } else if (state == ViewState.empty) {
                  return const Center(child: Text('No Data found'));
                } else {
                  return const Center(child: Text('Error'));
                }
              },
            ),
          ),
        );
      }),
    );
  }
}
