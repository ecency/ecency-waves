import 'package:flutter/material.dart';
import 'package:waves/core/common/widgets/dialog/dialog_template.dart';
import 'package:waves/core/utilities/enum.dart';

class UserProfileFollowInfoListDialog extends StatelessWidget {
  const UserProfileFollowInfoListDialog(
      {super.key,
      required this.count,
      required this.accountName,
      required this.type});

  final int count;
  final String accountName;
  final FollowType type;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return DialogTemplate(
      title: type == FollowType.followers
          ? "Followers ($count)"
          : "Following ($count)",
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 750),
        child: SizedBox(
          height: screenHeight - 100,
          width: 750,
          child: SizedBox.shrink()
          //  UserFollowInfoListWidget(
          //   accountName: accountName,
          //   type: type,
          //   removeScaffold: true,
          //   count: count,
          //   screenWidth: 750,
          // ),
        ),
      ),
    );
  }
}
