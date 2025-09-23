import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/widgets/back_to_top_button.dart';
import 'package:waves/core/common/widgets/empty_state.dart';
import 'package:waves/core/common/widgets/loading_state.dart';
import 'package:waves/core/common/widgets/pagination_loader.dart';
import 'package:waves/core/common/widgets/scroll_end_listener.dart';
import 'package:waves/core/common/extensions/ui.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/utilities/constants/ui_constants.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/explore/presentation/waves/controller/waves_feed_controller.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/thread_feed_divider.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/thread_tile.dart';

class WavesListView extends StatefulWidget {
  const WavesListView({super.key, this.scrollController});

  final ScrollController? scrollController;

  @override
  State<WavesListView> createState() => _WavesListViewState();
}

class _WavesListViewState extends State<WavesListView> {
  late ScrollController _scrollController;
  late bool _ownsController;
  bool _showBackToTopButton = false;
  String? _lastErrorMessage;

  @override
  void initState() {
    super.initState();
    _configureScrollController(widget.scrollController);
  }

  void _configureScrollController(ScrollController? controller) {
    _ownsController = controller == null;
    _scrollController = controller ?? ScrollController();
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
  void didUpdateWidget(covariant WavesListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      _scrollController.removeListener(_scrollListener);
      if (_ownsController) {
        _scrollController.dispose();
      }
      _configureScrollController(widget.scrollController);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    if (_ownsController) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<WavesFeedController>();
    final double backToTopBottomOffset =
        16 + MediaQuery.of(context).padding.bottom;

    return Selector<WavesFeedController, ViewState>(
      selector: (_, c) => c.viewState,
      builder: (context, state, _) {
        final error =
            context.select<WavesFeedController, String?>((c) => c.errorMessage);
        if (error != null && error.isNotEmpty && error != _lastErrorMessage) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) context.showSnackBar(error);
          });
          _lastErrorMessage = error;
        }
        if (state == ViewState.loading) {
          return const LoadingState();
        }
        if (state == ViewState.empty) {
          return Emptystate(text: LocaleText.noContentFound);
        }
        final items =
            context.select<WavesFeedController, List<ThreadFeedModel>>(
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
                          showVoteAndComment: false,
                        ),
                        if (index == items.length - 1)
                          PaginationLoader(
                            pageVisibilityListener: (ctx) => ctx
                                .select<WavesFeedController, bool>(
                                    (c) => c.isNextPageLoading),
                          ),
                      ],
                    );
                  },
                  separatorBuilder: (_, __) => const ThreadFeedDivider(),
                ),
              ),
              Positioned(
                bottom: backToTopBottomOffset,
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
