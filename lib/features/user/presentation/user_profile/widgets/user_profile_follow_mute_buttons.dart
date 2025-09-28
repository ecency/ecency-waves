import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/widgets/buttons/duo_text_buttons.dart';
import 'package:waves/core/dependency_injection/dependency_injection.dart';
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
  bool _isFetchingFollow = false;
  bool _isUpdatingFollow = false;
  bool _isFollowing = false;
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
        _setFollowState(false, isFetching: false);
      } else {
        _loadFollowState(nextViewer);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewer = _viewer;
    if (viewer != null && viewer == widget.author) {
      return const SizedBox.shrink();
    }

    final bool disableFollowButton =
        _isFetchingFollow || _isUpdatingFollow || viewer == widget.author;
    final bool isFollowing = _isFollowing;
    final followLabel = isFollowing ? "Unfollow User" : "Follow User";

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
      buttonTwoText: followLabel,
      buttonTwoOnTap: disableFollowButton ? null : _onFollowPressed,
      buttonTwoEnabled: !disableFollowButton,
      buttonTwoLoading: _isUpdatingFollow,
    );
  }

  void refreshFeeds() {
    Future.delayed(const Duration(seconds: 3)).then((_) {
      feedController.refresh();
    });
  }

  Future<void> _loadFollowState(String viewer) async {
    setState(() {
      _isFetchingFollow = true;
    });
    final response = await _userRepository.fetchFollowRelationship(
      viewer,
      widget.author,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _isFetchingFollow = false;
      if (response.isSuccess) {
        _isFollowing = response.data ?? false;
      }
    });
  }

  void _setFollowState(bool value, {required bool isFetching}) {
    if (!mounted) return;
    if (_isFollowing == value && _isFetchingFollow == isFetching) {
      if (!isFetching) {
        _isUpdatingFollow = false;
      }
      return;
    }
    setState(() {
      _isFollowing = value;
      _isFetchingFollow = isFetching;
      if (!isFetching) {
        _isUpdatingFollow = false;
      }
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
        refreshFeeds();
      },
      onFailure: () {
        if (!mounted) return;
        setState(() {
          _isUpdatingFollow = false;
        });
        final viewer = _viewer;
        if (viewer != null && viewer != widget.author) {
          _loadFollowState(viewer);
        }
      },
    );
  }
}
