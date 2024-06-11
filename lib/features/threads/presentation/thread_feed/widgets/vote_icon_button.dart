import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/widgets/icon_with_text.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/upvote/upvote_dialog.dart';
import 'package:waves/features/user/view/user_controller.dart';

class VoteIconButton extends StatelessWidget {
  const VoteIconButton(
      {super.key,
      required this.item,
      this.iconColor,
      this.textStyle,
      this.iconGap});

  final ThreadFeedModel item;
  final Color? iconColor;
  final TextStyle? textStyle;
  final double? iconGap;

  @override
  Widget build(BuildContext context) {
    return IconWithText(
      onTap: () => _onTap(context),
      icon: Icons.favorite,
      text: "${item.activeVotes?.length ?? 0}",
      iconColor: iconColor,
      iconGap: iconGap,
      borderRadius: const BorderRadius.all(Radius.circular(40)),
      textStyle: textStyle,
    );
  }

  void _onTap(BuildContext rootContext) {
    if (rootContext.read<UserController>().isUserLoggedIn) {
      showModalBottomSheet(
        context: rootContext,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return UpvoteDialog(author: item.author, permlink: item.permlink,rootContext: rootContext,);
        },
      );
    }
  }
}
