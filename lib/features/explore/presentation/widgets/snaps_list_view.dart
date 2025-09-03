import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/widgets/back_to_top_button.dart';
import 'package:waves/core/common/widgets/empty_state.dart';
import 'package:waves/core/common/widgets/loading_state.dart';
import 'package:waves/core/common/widgets/pagination_loader.dart';
import 'package:waves/core/common/widgets/scroll_end_listener.dart';
import 'package:waves/core/common/extensions/ui.dart';
import 'package:waves/core/utilities/constants/ui_constants.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/explore/presentation/snaps/controller/snaps_feed_controller.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/thread_feed_divider.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/thread_tile.dart';

class SnapsListView extends StatefulWidget {
  const SnapsListView({super.key});

  @override
  State<SnapsListView> createState() => _SnapsListViewState();
}

class _SnapsListViewState extends State<SnapsListView> {
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTopButton = false;
  String? _lastErrorMessage;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    final double triggerHeight = MediaQuery.of(context).size.height;
    if (_scrollController.offset > triggerHeight && !_showBackToTopButton) {
      setState(() {
        _showBackToTopButton = true;
      });
    } else if (_scrollController.offset <= triggerHeight && _showBackToTopButton) {
      setState(() {
        _showBackToTopButton = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<SnapsFeedController>();

    return Selector<SnapsFeedController, ViewState>(
      selector: (_, c) => c.viewState,
      builder: (context, state, _) {
        final error =
            context.select<SnapsFeedController, String?>((c) => c.errorMessage);
        if (state == ViewState.loading) {
          return const LoadingState();
        }
        if (state == ViewState.empty) {
          if (error != null && error.isNotEmpty && error != _lastErrorMessage) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) context.showSnackBar(error);
            });
            _lastErrorMessage = error;
          }
          return const Emptystate(text: 'No content found');
        }
        final items =
            context.select<SnapsFeedController, List<ThreadFeedModel>>(
                (c) => c.items);
        return ScrollEndListener(
          loadNextPage: controller.loadNextPage,
          child: Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async {
                  controller.refresh();
                },
                child: ListView.separated(
                  controller: _scrollController,
                  padding: kScreenVerticalPadding,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        ThreadTile(
                          item: items[index],
                          threadType: controller.threadType,
                        ),
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
                ),
              ),
              Positioned(
                // Avoid overlap with the compose FAB
                bottom: 96,
                right: 16,
                child: Visibility(
                  visible: _showBackToTopButton,
                  child: BackToTopButton(
                    onPressed: () {
                      if (_scrollController.hasClients) {
                        _scrollController.animateTo(0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
