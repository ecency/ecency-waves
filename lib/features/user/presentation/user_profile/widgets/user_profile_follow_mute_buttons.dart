import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/widgets/buttons/duo_text_buttons.dart';
import 'package:waves/features/threads/presentation/thread_feed/controller/thread_feed_controller.dart';
import 'package:waves/features/user/view/user_controller.dart';
import 'package:waves/features/user/utils/block_user_helper.dart';

class UserProfileFollowMuteButtons extends StatefulWidget {
  const UserProfileFollowMuteButtons({
    super.key,
    this.buttonHeight,
    required this.author,
  });

  final double? buttonHeight;
  final String author;

  @override
  State<UserProfileFollowMuteButtons> createState() =>
      _UserProfileFollowMuteButtonsState();
}

class _UserProfileFollowMuteButtonsState
    extends State<UserProfileFollowMuteButtons> {
  late ThreadFeedController feedController;

  @override
  void didChangeDependencies() {
    feedController = context.read<ThreadFeedController>();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final userName = context.read<UserController>().userName;
    if (userName != null && userName == widget.author) {
      return const SizedBox.shrink();
    }
    return DuoTextButtons(
      buttonHeight: widget.buttonHeight,
      buttonOneText: "Block User",
      buttonOneOnTap: () {
        BlockUserHelper.blockUser(
          context,
          author: widget.author,
          onSuccess: refreshFeeds,
        );
      },
    );
  }

  void refreshFeeds() {
    Future.delayed(const Duration(seconds: 3)).then((_) {
      feedController.refresh();
    });
  }
}
