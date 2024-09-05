import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/widgets/dialog/log_in_dialog.dart';
import 'package:waves/core/common/widgets/empty_state.dart';
import 'package:waves/core/common/widgets/images/user_profile_image.dart';
import 'package:waves/core/common/widgets/loading_state.dart';
import 'package:waves/core/common/widgets/server_error.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/routes/route_keys.dart';
import 'package:waves/core/routes/routes.dart';
import 'package:waves/core/utilities/constants/ui_constants.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_json_meta_data/thread_json_meta_data.dart';
import 'package:waves/features/threads/presentation/comments/comment_detail/controller/comment_detail_controller.dart';
import 'package:waves/features/threads/presentation/comments/comment_detail/widgets/tag_scroll.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/interaction_tile.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/markdown/thread_markdown.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/post_poll/post_poll.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/thread_feed_divider.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/thread_tile.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/thread_user_info_tile.dart';
import 'package:waves/features/user/view/user_controller.dart';

class CommentDetailView extends StatelessWidget {
  const CommentDetailView({super.key, required this.item});

  final ThreadFeedModel item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userController = context.read<UserController>();
    return ChangeNotifierProvider(
      create: (context) => CommentDetailController(
          mainThread: item, observer: userController.userName),
      builder: (context, child) {
        return Selector<CommentDetailController, ThreadFeedModel>(
          selector: (_, myType) => myType.mainThread,
          builder: (context, item, child) {
            return SafeArea(
              child: Scaffold(
                appBar: AppBar(
                  title: const Text("Post"),
                ),
                bottomNavigationBar: _bottomBar(theme, item),
                body: SafeArea(
                  child: Padding(
                    padding: kScreenVerticalPadding,
                    child: CustomScrollView(
                      slivers: [
                        _mainThread(item, userController, context, theme),
                        _comments()
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Selector<CommentDetailController, ViewState> _comments() {
    return Selector<CommentDetailController, ViewState>(
      selector: (_, myType) => myType.viewState,
      builder: (context, state, child) {
        if (state == ViewState.data) {
          return Selector<CommentDetailController, List<ThreadFeedModel>>(
            shouldRebuild: (previous, next) =>
                previous != next || previous.length != next.length,
            selector: (_, myType) => myType.items,
            builder: (context, replies, child) {
              return SliverList.separated(
                  itemCount: replies.length,
                  itemBuilder: (context, index) {
                    final ThreadFeedModel reply = replies[index];
                    return ThreadTile(
                      item: reply,
                      hideCommentInfo: true,
                    );
                  },
                  separatorBuilder: (context, index) =>
                      replies[index].children == 0
                          ? const ThreadFeedDivider()
                          : const Gap(15));
            },
          );
        } else if (state == ViewState.empty) {
          return const Emptystate(
            hideIcon: true,
            text: "No Replies found",
            isSliver: true,
          );
        } else if (state == ViewState.error) {
          return const ErrorState(
            isSliver: true,
          );
        } else {
          return const LoadingState(
            isSliver: true,
          );
        }
      },
    );
  }

  SliverPadding _mainThread(ThreadFeedModel item, UserController userController,
      BuildContext context, ThemeData theme) {
    return SliverPadding(
      padding:
          const EdgeInsets.symmetric(horizontal: kScreenHorizontalPaddingDigit),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ThreadUserInfoTile(item: item),
            const Gap(15),
            ThreadMarkDown(item: item),
            item.jsonMetadata?.contentType == ContentType.poll ? PostPoll(item: item) : Container() ,
            if (item.jsonMetadata?.tags != null &&
                item.jsonMetadata!.tags!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(
                  top: 10,
                ),
                child: TagScroll(tags: item.jsonMetadata!.tags!),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Row(
                children: [
                  UserProfileImage(url: userController.userName),
                  const Gap(10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await _onAddComment(userController, context, item);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        decoration: BoxDecoration(
                            color: theme.colorScheme.tertiaryContainer,
                            border:
                                Border.all(color: theme.colorScheme.tertiary),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20))),
                        child: Text("${LocaleText.addAComment}..."),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Container _bottomBar(ThemeData theme, ThreadFeedModel item) {
    return Container(
        color: theme.scaffoldBackgroundColor,
        padding: const EdgeInsets.symmetric(
            horizontal: kScreenHorizontalPaddingDigit, vertical: 10),
        child: InteractionTile(
          item: item,
          removeCommentGesture: true,
        ));
  }

  Future<void> _onAddComment(UserController userController,
      BuildContext context, ThreadFeedModel item) async {
    if (!userController.isUserLoggedIn) {
      showDialog(
        context: context,
        builder: (context) {
          return const LogInDialog();
        },
      );
    } else {
      context.pushNamed(
        Routes.addCommentView,
        queryParameters: {
          RouteKeys.accountName: item.author,
          RouteKeys.permlink: item.permlink,
          RouteKeys.depth: item.depth.toString()
        },
      ).then((data) {
        if (data != null && data is ThreadFeedModel) {
          context.read<CommentDetailController>().onCommentAdded(data);
        }
      });
    }
  }
}
