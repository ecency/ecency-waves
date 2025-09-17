import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/extensions/platform_navigation.dart';
import 'package:waves/core/common/widgets/drawer/drawer_menu.dart';
import 'package:waves/core/common/widgets/empty_state.dart';
import 'package:waves/core/common/widgets/loading_state.dart';
import 'package:waves/core/common/widgets/server_error.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/routes/routes.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/threads/presentation/thread_feed/controller/thread_feed_controller.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/drop_down_filter.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/thread_list_view.dart';

class ThreadFeedView extends StatelessWidget {
  const ThreadFeedView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.read<ThreadFeedController>();
    final theme = Theme.of(context);
    return Scaffold(
        drawer: const DrawerMenu(),
        appBar: AppBar(
          backgroundColor: theme.cardColor,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          title: DropDownFilter(onChanged: (type) {
            controller.onTapFilter(type);
          }),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'Search',
              onPressed: () {
                context.platformPushNamed(Routes.searchView);
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Selector<ThreadFeedController, ViewState>(
            selector: (_, provider) => provider.viewState,
            builder: (context, value, child) {
              if (value == ViewState.data) {
                return ThreadListView();
              } else if (value == ViewState.empty) {
                return Emptystate(
                    icon: Icons.hourglass_empty,
                    text: LocaleText.noThreadsFound.tr());
              } else if (value == ViewState.error) {
                return ErrorState(
                  showRetryButton: true,
                  onTapRetryButton: () => controller.refresh(),
                );
              } else {
                return const LoadingState();
              }
            },
          ),
        ));
  }
}
