import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/explore/presentation/waves/controller/waves_feed_controller.dart';
import 'package:waves/features/explore/presentation/widgets/waves_list_view.dart';
import 'package:waves/features/explore/presentation/widgets/thread_type_dropdown.dart';

class TagFeedView extends StatelessWidget {
  final String tag;
  final ThreadFeedType threadType;

  const TagFeedView({super.key, required this.tag, required this.threadType});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WavesFeedController.tag(tag: tag, threadType: threadType),
      child: Builder(builder: (context) {
        final controller = context.read<WavesFeedController>();
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
            child: Selector<WavesFeedController, ViewState>(
              selector: (_, c) => c.viewState,
              builder: (context, state, _) {
                if (state == ViewState.loading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state == ViewState.data) {
                  return const WavesListView();
                } else if (state == ViewState.empty) {
                  return Center(child: Text(LocaleText.noDataFound));
                } else {
                  return Center(child: Text(LocaleText.error));
                }
              },
            ),
          ),
        );
      }),
    );
  }
}
