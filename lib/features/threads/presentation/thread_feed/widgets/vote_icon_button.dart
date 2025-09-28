import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/extensions/ui.dart';
import 'package:gap/gap.dart';
import 'package:waves/core/common/widgets/inkwell_wrapper.dart';
import 'package:waves/features/threads/models/post_detail/upvote_model.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';
import 'package:waves/features/threads/presentation/thread_feed/controller/thread_feed_controller.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/upvote/upvote_dialog.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/upvote/voters_dialog.dart';
import 'package:waves/features/user/view/user_controller.dart';

class VoteIconButton extends StatefulWidget {
  const VoteIconButton(
      {super.key,
      required this.item,
      this.iconColor,
      this.textStyle,
      this.iconGap,
      this.showCount = true});

  final ThreadFeedModel item;
  final Color? iconColor;
  final TextStyle? textStyle;
  final double? iconGap;
  final bool showCount;

  @override
  State<VoteIconButton> createState() => _VoteIconButtonState();
}

class _VoteIconButtonState extends State<VoteIconButton> {
  late bool isVoted;
  late List<ActiveVoteModel> items;
  late ThemeData theme;

  @override
  void initState() {
    final userController = context.read<UserController>();
    items = widget.item.activeVotes ?? [];
    isVoted = isVotedByUser(context, userController);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    theme = Theme.of(context);
    var userController = Provider.of<UserController>(context);
    isVoted = isVotedByUser(context, userController);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final iconColor =
        isVoted ? theme.primaryColor : widget.iconColor ?? theme.primaryColorDark.withOpacity(0.9);
    final textWidget = Text(
      "${items.length}",
      style: widget.textStyle ??
          theme.textTheme.labelLarge!
              .copyWith(color: iconColor),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWellWrapper(
          borderRadius: const BorderRadius.all(Radius.circular(40)),
          onTap: () => _onTap(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Icon(
              isVoted ? Icons.favorite : Icons.favorite_border_outlined,
              size: 20,
              color: iconColor,
            ),
          ),
        ),
        if (widget.showCount && items.isNotEmpty)
          Gap(widget.iconGap ?? 5),
        if (widget.showCount)
          items.isNotEmpty
              ? InkWellWrapper(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  onTap: () => _showVoters(context),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: textWidget,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4, vertical: 4),
                  child: textWidget,
                )
      ],
    );
  }

  void _onTap(BuildContext rootContext) {
    rootContext.authenticatedAction(action: () {
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
                  });
                  rootContext
                      .read<ThreadFeedController>()
                      .refreshOnUpvote(widget.item.postId, voteModel);
                }
              },
              author: widget.item.author,
              permlink: widget.item.permlink,
              rootContext: rootContext,
            );
          },
        );
      }
    });
  }

  void _showVoters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => VotersDialog(voters: items),
    );
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
