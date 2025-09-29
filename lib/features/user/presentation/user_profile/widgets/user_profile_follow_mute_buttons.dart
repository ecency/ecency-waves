import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/widgets/buttons/duo_text_buttons.dart';
import 'package:waves/core/dependency_injection/dependency_injection.dart';
import 'package:waves/features/explore/presentation/waves/controller/waves_feed_controller.dart';
import 'package:waves/features/threads/presentation/thread_feed/controller/following_feed_controller.dart';
import 'package:waves/features/threads/presentation/thread_feed/controller/thread_feed_controller.dart';
import 'package:waves/features/user/repository/user_repository.dart';
import 'package:waves/features/user/utils/block_user_helper.dart';
import 'package:waves/features/user/utils/follow_user_helper.dart';
import 'package:waves/features/user/view/user_controller.dart';

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
  final UserRepository _userRepository = getIt<UserRepository>();
  bool _isLoadingRelationship = false;
  bool _isUpdatingFollow = false;
  bool _isUpdatingBlock = false;
  bool _isFollowing = false;
  bool _isBlocked = false;
  String? _viewer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    feedController = context.read<ThreadFeedController>();
    final userController = Provider.of<UserController>(context);
    final nextViewer = userController.userName;
    if (_viewer != nextViewer) {
      _viewer = nextViewer;
      if (nextViewer == null || nextViewer == widget.author) {
        _resetRelationshipState();
      } else {
        _loadRelationship(nextViewer);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewer = _viewer;
    if (viewer != null && viewer == widget.author) {
      return const SizedBox.shrink();
    }

    final bool disableBlockButton =
        _isLoadingRelationship || _isUpdatingBlock || viewer == widget.author;
    final bool disableFollowButton =
        _isLoadingRelationship || _isUpdatingFollow || _isBlocked || viewer == widget.author;
    final bool isFollowing = _isFollowing;
    final followLabel = isFollowing ? "Unfollow" : "Follow";
    final blockLabel = _isBlocked ? "Unblock" : "Block";

    return DuoTextButtons(
      buttonHeight: widget.buttonHeight,
      buttonOneText: blockLabel,
      buttonOneOnTap: _onBlockPressed,
      buttonOneEnabled: !disableBlockButton,
      buttonOneLoading: _isUpdatingBlock,
      buttonTwoText: followLabel,
      buttonTwoOnTap: disableFollowButton ? null : _onFollowPressed,
      buttonTwoEnabled: !disableFollowButton,
      buttonTwoLoading: _isUpdatingFollow,
    );
  }

  void _removeAuthorFromFeeds() {
    feedController.removeAuthorContent(widget.author);

    try {
      context
          .read<FollowingFeedController>()
          .removeAuthorContent(widget.author);
    } catch (_) {}

    try {
      context.read<WavesFeedController>().removeAuthorContent(widget.author);
    } catch (_) {}
  }

  void _refreshFollowingFeed() {
    try {
      unawaited(context.read<FollowingFeedController>().refresh());
    } catch (_) {}
  }

  Future<void> _loadRelationship(String viewer) async {
    setState(() {
      _isLoadingRelationship = true;
    });
    final response = await _userRepository.fetchAccountRelationship(
      viewer,
      widget.author,
    );
    if (!mounted) {
      return;
    }
    final previousBlocked = _isBlocked;
    setState(() {
      _isLoadingRelationship = false;
      if (response.isSuccess && response.data != null) {
        _isFollowing = response.data!.isFollowing;
        _isBlocked = response.data!.isBlocked;
      }
    });
    if (!mounted) {
      return;
    }
    if (_isBlocked) {
      _removeAuthorFromFeeds();
    } else if (previousBlocked && !_isBlocked) {
      feedController.refresh();
    }
  }

  void _resetRelationshipState() {
    if (!mounted) return;
    setState(() {
      _isFollowing = false;
      _isBlocked = false;
      _isLoadingRelationship = false;
      _isUpdatingFollow = false;
      _isUpdatingBlock = false;
    });
  }

  void _onFollowPressed() {
    final shouldFollow = !_isFollowing;
    setState(() {
      _isUpdatingFollow = true;
    });

    FollowUserHelper.toggleFollow(
      context,
      author: widget.author,
      follow: shouldFollow,
      onSuccess: () {
        if (!mounted) return;
        setState(() {
          _isUpdatingFollow = false;
          _isFollowing = shouldFollow;
        });
        _refreshFollowingFeed();
      },
      onFailure: () {
        if (!mounted) return;
        setState(() {
          _isUpdatingFollow = false;
        });
        final viewer = _viewer;
        if (viewer != null && viewer != widget.author) {
          _loadRelationship(viewer);
        }
      },
    );
  }

  void _onBlockPressed() {
    final viewer = _viewer;
    if (viewer == null || viewer == widget.author) {
      return;
    }

    final shouldBlock = !_isBlocked;
    setState(() {
      _isUpdatingBlock = true;
    });

    BlockUserHelper.toggleBlock(
      context,
      author: widget.author,
      block: shouldBlock,
      onSuccess: () {
        if (!mounted) return;
        setState(() {
          _isUpdatingBlock = false;
          _isBlocked = shouldBlock;
          if (shouldBlock) {
            _isFollowing = false;
          }
        });
        if (shouldBlock) {
          _removeAuthorFromFeeds();
        } else {
          feedController.refresh();
        }
      },
      onFailure: () {
        if (!mounted) return;
        setState(() {
          _isUpdatingBlock = false;
        });
        final viewerName = _viewer;
        if (viewerName != null && viewerName != widget.author) {
          _loadRelationship(viewerName);
        }
      },
    );
  }
}
