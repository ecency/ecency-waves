import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:waves/core/common/widgets/buttons/bookmark_button.dart';
import 'package:waves/core/common/widgets/icon_with_text.dart';
import 'package:waves/core/routes/routes.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';
import 'package:waves/features/threads/presentation/thread_feed/controller/thread_feed_controller.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/thread_earnings.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/vote_icon_button.dart';

class InteractionTile extends StatelessWidget {
  const InteractionTile(
      {this.hideCommentInfo = false,
      super.key,
      required this.item,
      this.removeCommentGesture = false});

  final ThreadFeedModel item;
  final bool hideCommentInfo;
  final bool removeCommentGesture;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _extraRow(theme, context);
  }

  Widget _extraRow(ThemeData theme, BuildContext context) {
    final controller = context.read<ThreadFeedController>();
    final bookmarkProvider = controller.bookmarkProvider;
    final iconColor = theme.primaryColorDark.withOpacity(0.8);
    const iconGap = 5.0;
    const borderRadius = BorderRadius.all(Radius.circular(40));
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Row(
        mainAxisAlignment: hideCommentInfo
            ? MainAxisAlignment.start
            : MainAxisAlignment.spaceBetween,
        children: [
          VoteIconButton(
            item: item,
            iconColor: iconColor,
            iconGap: iconGap,
            textStyle: style(theme),
          ),
          gap(),
          ThreadEarnings(
            pendingPayoutvalue: item.pendingPayoutValue,
            iconColor: iconColor,
            iconGap: iconGap,
            textStyle: style(theme),
          ),
          if (!hideCommentInfo) gap(),
          if (!hideCommentInfo)
            IconWithText(
              onTap: () {
                if (!removeCommentGesture) {
                  context.pushNamed(Routes.commentDetailView, extra: item);
                }
                // if (context.read<UserController>().isUserLoggedIn) {
                //   context.pushNamed(
                //     Routes.addCommentView,
                //     queryParameters: {
                //       RouteKeys.accountName: item.author,
                //       RouteKeys.permlink: item.permlink
                //     },
                //   );
                // }
              },
              icon: Icons.comment,
              iconColor: iconColor,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              text: "${item.children ?? 0}",
              iconGap: iconGap,
              textStyle: style(theme),
            ),
          gap(),
          IconWithText(
            onTap: () {
              Share.share(
                  'https://ecency.com/${item.category}/@${item.author}/${item.permlink}');
            },
            borderRadius: borderRadius,
            icon: Icons.share,
            iconColor: iconColor,
          ),
          gap(),
          BookmarkButton(
              borderRadius: borderRadius,
              iconColor: iconColor,
              isBookmarked: bookmarkProvider.isBookmarkPresent(item.idString),
              onAdd: () {
                bookmarkProvider.addBookmark(item.idString, item);
              },
              onRemove: () {
                bookmarkProvider.removeBookmark(item.idString);
              },
              toastType: '${item.author}/${item.permlink}'),
        ],
      ),
    );
  }

  Gap gap() {
    return const Gap(20);
  }

  TextStyle style(ThemeData theme) {
    return theme.textTheme.labelLarge!
        .copyWith(color: theme.primaryColorDark.withOpacity(0.8));
  }
}
