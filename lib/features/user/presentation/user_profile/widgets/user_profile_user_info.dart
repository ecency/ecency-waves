import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:waves/core/common/widgets/user_image_name.dart';
import 'package:waves/core/utilities/constants/ui_constants.dart';
import 'package:waves/features/user/models/user_model.dart';
import 'package:waves/features/user/presentation/user_profile/widgets/user_profile_info_scroll.dart';
import 'package:waves/features/user/presentation/user_profile/widgets/user_profile_follow_mute_buttons.dart';

class UserProfileUserInfo extends StatelessWidget {
  const UserProfileUserInfo({super.key, required this.data});

  final UserModel data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverMainAxisGroup(
      slivers: [
        _ResponsiveSliverPadding(
          top: 0,
          bottom: 10,
          sliver: SliverAppBar(
            leading: const SizedBox.shrink(),
            leadingWidth: 0,
            floating: true,
            centerTitle: false,
            titleSpacing: 0,
            title: LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  children: [
                    Expanded(
                      child: UserImageName(
                        name: data.name,
                        textStyle: theme.textTheme.bodyMedium,
                        isExpanded: true,
                      ),
                    ),
                    const Gap(12),
                    UserProfileFollowMuteButtons(
                      author: data.name,
                      buttonHeight: 30,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        if (data.postingJsonMetadata?.profile?.about != null)
          _ResponsiveSliverPadding(
            sliver: SliverToBoxAdapter(
              child: Text(
                data.postingJsonMetadata!.profile!.about!,
                style: theme.textTheme.bodySmall!.copyWith(
                  fontWeight: FontWeight.w300,
                  color: theme.primaryColorDark.withOpacity(0.8),
                ),
              ),
            ),
          ),
        _ResponsiveSliverPadding(
          bottom: 15,
          sliver: SliverToBoxAdapter(
            child: UserProfileInfoTile(data: data),
          ),
        ),
      ],
    );
  }
}

class _ResponsiveSliverPadding extends StatelessWidget {
  const _ResponsiveSliverPadding({
    required this.sliver,
    this.top = 0,
    this.bottom = 0,
  });

  final Widget sliver;
  final double top;
  final double bottom;

  static const double _maxContentWidth = 720;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final crossAxisExtent = constraints.crossAxisExtent;
        final horizontalPadding = crossAxisExtent > _maxContentWidth
            ? (crossAxisExtent - _maxContentWidth) / 2
            : kScreenHorizontalPaddingDigit.toDouble();

        return SliverPadding(
          padding: EdgeInsets.only(
            top: top,
            bottom: bottom,
            left: horizontalPadding,
            right: horizontalPadding,
          ),
          sliver: sliver,
        );
      },
    );
  }
}
