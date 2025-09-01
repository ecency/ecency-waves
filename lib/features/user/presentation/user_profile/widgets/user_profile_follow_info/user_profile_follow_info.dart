import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/widgets/text_box.dart';
import 'package:waves/core/utilities/constants/ui_constants.dart';
import 'package:waves/features/user/models/follow_count_model.dart';
import 'package:waves/features/user/presentation/user_profile/controller/user_profile_controller.dart';

class FollowInfo extends StatelessWidget {
  const FollowInfo({
    super.key,
    required this.direction,
    required this.accountName,
  });

  final Axis direction;
  final String accountName;

  @override
  Widget build(BuildContext context) {
    final controller = context.read<UserProfileController>();
    return FutureBuilder<FollowCountModel>(
      future: controller.getFollowCount(),
      builder: (context, snapshot) {
        FollowCountModel? data = snapshot.data;
        return direction == Axis.vertical
            ? Column(
                children: children(data, context),
              )
            : Row(
                children: children(data, context),
              );
      },
    );
  }

  List<Widget> children(FollowCountModel? data, BuildContext context) {
    return [
      TextBox(
        showBorder: true,
        mainAxisAlignment: MainAxisAlignment.center,
        borderRadius: 40,
        padding: const EdgeInsets.symmetric(
            horizontal: kScreenHorizontalPaddingDigit, vertical: 6),
        backgroundColor: Colors.transparent,
        text: "Followers ${data?.followerCount ?? 0}",
      ),
      const Gap(10),
      TextBox(
        showBorder: true,
        mainAxisAlignment: MainAxisAlignment.center,
        borderRadius: 40,
        padding: const EdgeInsets.symmetric(
            horizontal: kScreenHorizontalPaddingDigit, vertical: 6),
        backgroundColor: Colors.transparent,
        text: "Following ${data?.followingCount ?? 0}",
      ),
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 15),
        child: Divider(),
      ),
    ];
  }
}
