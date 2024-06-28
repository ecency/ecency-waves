import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/widgets/dialog/log_in_dialog.dart';
import 'package:waves/core/common/widgets/icon_with_text.dart';
import 'package:waves/features/threads/models/post_detail/upvote_model.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';
import 'package:waves/features/threads/presentation/thread_feed/controller/thread_feed_controller.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/upvote/upvote_dialog.dart';
import 'package:waves/features/user/view/user_controller.dart';

class VoteIconButton extends StatefulWidget {
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
  State<VoteIconButton> createState() => _VoteIconButtonState();
}

class _VoteIconButtonState extends State<VoteIconButton> {
  late bool isVoted;
  late List<ActiveVoteModel> items;

  @override
  void initState() {
    final userController = context.read<UserController>();
    items = widget.item.activeVotes ?? [];
    isVoted = isVotedByUser(context, userController);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    var userController= Provider.of<UserController>(context);
    isVoted = isVotedByUser(context, userController);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return IconWithText(
      onTap: () => _onTap(
        context,
      ),
      icon: isVoted ? Icons.favorite : Icons.favorite_border_outlined,
      text: "${items.length}",
      iconColor: widget.iconColor,
      iconGap: widget.iconGap,
      borderRadius: const BorderRadius.all(Radius.circular(40)),
      textStyle: widget.textStyle,
    );
  }

  void _onTap(BuildContext rootContext) {
    if (rootContext.read<UserController>().isUserLoggedIn) {
      if (!isVoted) {
        showModalBottomSheet(
          context: rootContext,
          backgroundColor: Colors.transparent,
          builder: (context) {
            return UpvoteDialog(
              onSuccess: (voteModel) {
                if (mounted) {
                  setState(() {
                    items.add(voteModel);
                    isVoted = true;
                    rootContext
                        .read<ThreadFeedController>()
                        .refreshOnUpvote(widget.item.postId, voteModel);
                  });
                }
              },
              author: widget.item.author,
              permlink: widget.item.permlink,
              rootContext: rootContext,
            );
          },
        );
      }
    } else {
      showDialog(
        context: rootContext,
        builder: (context) {
          return const LogInDialog();
        },
      );
    }
  }

  bool isVotedByUser(BuildContext context, UserController userController) {
    if (userController.userName != null &&
        widget.item.activeVotes != null &&
        widget.item.activeVotes!.isNotEmpty) {
      return widget.item.activeVotes!
          .any((vote) => vote.voter == userController.userName);
    }
    return false;
  }
}
