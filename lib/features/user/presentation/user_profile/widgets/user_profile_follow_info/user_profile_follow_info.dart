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
        if (direction == Axis.vertical) {
          return Column(
            children: [
              ..._buildStats(data, withGap: true),
              _buildDivider(Axis.vertical),
            ],
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 520;
            final hasTightHeight =
                constraints.hasBoundedHeight && constraints.maxHeight <= 40;
            final useColumnLayout = isWide && !hasTightHeight;
            final stats = _buildStats(data, withGap: !useColumnLayout);

            if (useColumnLayout) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: stats,
                  ),
                  _buildDivider(Axis.vertical),
                ],
              );
            }

            return Row(
              children: [
                ...stats,
                _buildDivider(Axis.horizontal),
              ],
            );
          },
        );
      },
    );
  }

  List<Widget> _buildStats(
    FollowCountModel? data, {
    required bool withGap,
  }) {
    final stats = <Widget>[
      TextBox(
        showBorder: true,
        mainAxisAlignment: MainAxisAlignment.center,
        borderRadius: 40,
        padding: const EdgeInsets.symmetric(
            horizontal: kScreenHorizontalPaddingDigit, vertical: 6),
        backgroundColor: Colors.transparent,
        text: "Followers ${data?.followerCount ?? 0}",
      ),
      TextBox(
        showBorder: true,
        mainAxisAlignment: MainAxisAlignment.center,
        borderRadius: 40,
        padding: const EdgeInsets.symmetric(
            horizontal: kScreenHorizontalPaddingDigit, vertical: 6),
        backgroundColor: Colors.transparent,
        text: "Following ${data?.followingCount ?? 0}",
      ),
    ];

    if (!withGap) {
      return stats;
    }

    return [
      stats[0],
      const Gap(10),
      stats[1],
    ];
  }

  Widget _buildDivider(Axis orientation) {
    if (orientation == Axis.horizontal) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: SizedBox(
          height: 20,
          child: VerticalDivider(),
        ),
      );
    }

    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 15),
      child: Divider(),
    );
  }
}
