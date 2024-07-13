import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:waves/core/utilities/act.dart';
import 'package:waves/features/user/models/user_model.dart';
import 'package:waves/features/user/presentation/user_profile/widgets/user_profile_follow_info/user_profile_follow_info.dart';
import 'package:waves/features/user/presentation/user_profile/widgets/user_profile_info_scroll_template.dart';
import 'package:waves/features/user/presentation/user_profile/widgets/user_profile_info_scroll_tile.dart';

class UserProfileInfoTile extends StatelessWidget {
  const UserProfileInfoTile({
    super.key,
    required this.data,
  });

  final UserModel data;

  @override
  Widget build(BuildContext context) {
    return UserProfileInfoScrollTemplate(
      children: [
        FollowInfo(
          direction: Axis.horizontal,
          accountName: data.name,
        ),
        if (data.location != null && data.location!.isNotEmpty)
          UserProfileInfoScrollTile(
            icon: Icons.location_on,
            text: data.location!,
          ),
        if (data.website != null && data.website!.isNotEmpty)
          UserProfileInfoScrollTile(
            onTap: () => Act.launchThisUrl(data.website!),
            icon: Icons.public,
            text: data.website!,
          ),
        UserProfileInfoScrollTile(
          icon: Icons.event,
          text: DateFormat('d MMMM, yyyy').format(data.created),
        ),
      ],
    );
  }
}
