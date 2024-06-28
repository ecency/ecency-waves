import 'package:flutter/material.dart';
import 'package:waves/core/common/widgets/user_image_name.dart';
import 'package:waves/core/utilities/constants/ui_constants.dart';
import 'package:waves/features/user/models/user_model.dart';
import 'package:waves/features/user/presentation/user_profile/widgets/user_profile_info_scroll.dart';

class UserProfileUserInfo extends StatelessWidget {
  const UserProfileUserInfo({super.key, required this.data});

  final UserModel data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverMainAxisGroup(slivers: [
      SliverPadding(
        padding: const EdgeInsets.only(top: 0, bottom: 10),
        sliver: SliverAppBar(
          leading: const SizedBox.shrink(),
          leadingWidth: 0,
          floating: true,
          backgroundColor: theme.colorScheme.tertiaryContainer,
          title: UserImageName(
            name: data.name,
            textStyle: theme.textTheme.bodyMedium,
          ),
        ),
      ),
      if (data.postingJsonMetadata?.profile?.about != null)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: kScreenHorizontalPaddingDigit),
            child: Text(
              data.postingJsonMetadata!.profile!.about!,
              style: theme.textTheme.bodySmall!.copyWith(
                  fontWeight: FontWeight.w300,
                  color: theme.primaryColorDark.withOpacity(0.8)),
            ),
          ),
        ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: UserProfileInfoTile(data: data),
        ),
      ),
    ]);
  }
}
