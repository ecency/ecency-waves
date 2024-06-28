import 'package:flutter/material.dart';
import 'package:waves/core/common/widgets/images/image_container.dart';
import 'package:waves/features/user/models/user_model.dart';
import 'package:waves/features/user/presentation/user_profile/widgets/user_profile_follow_mute_buttons.dart';
import 'package:waves/features/user/presentation/user_profile/widgets/user_profile_user_info.dart';

class UserProfileViewWidget extends StatefulWidget {
  const UserProfileViewWidget(
      {super.key,
      required this.accountName,
      required this.data,});

  final String accountName;
  final UserModel data;

  @override
  State<UserProfileViewWidget> createState() => _UserProfileViewWidgetState();
}

class _UserProfileViewWidgetState extends State<UserProfileViewWidget> {
  VoidCallback loadNextPageCallback = () {};


  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant UserProfileViewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }


  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverCrossAxisGroup(
              slivers: [
                SliverMainAxisGroup(
                  slivers: [
                    _coverImage(),
                      UserProfileUserInfo(data: widget.data),
                  ],
                ),
              ],
            ),
          ],
        ),
  
      ],
    );
  }

  SliverAppBar _coverImage() {
    return SliverAppBar(
      leading: const SizedBox.shrink(),
      leadingWidth: 0,
      toolbarHeight: 0,
      expandedHeight: 175,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            ImageContainer(
                width: double.infinity,
                url: widget.data.postingJsonMetadata?.profile?.coverImage),
              const Positioned(
                bottom: 10,
                right: 10,
                child: UserProfileFollowMuteButtons(
                  buttonHeight: 30,
                ),
              ),
          ],
        ),
      ),
    );
  }

}
