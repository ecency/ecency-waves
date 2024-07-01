import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:waves/core/common/widgets/images/user_profile_image.dart';
import 'package:waves/core/routes/route_keys.dart';
import 'package:waves/core/routes/routes.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';

class ThreadUserInfoTile extends StatelessWidget {
  const ThreadUserInfoTile({
    super.key,
    required this.item,
  });

  final ThreadFeedModel item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var timeInString = timeago.format(item.created);
    return Row(
      children: [
        UserProfileImage(
          onTap: () => _pushToUserProfile(context),
          url: item.author,
          verticalPadding: 0,
        ),
        const Gap(
          8,
        ),
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _pushToUserProfile(context),
                  child: Text(
                    item.author,
                    style: theme.textTheme.bodyMedium!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const Gap(
                12,
              ),
              Text(
                timeInString,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: theme.textTheme.labelLarge!
                    .copyWith(color: theme.primaryColorDark.withOpacity(0.8)),
              ),
            ],
          ),
        )
      ],
    );
  }

  Future<Object?> _pushToUserProfile(BuildContext context) {
    return context.pushNamed(Routes.userProfileView,
        queryParameters: {RouteKeys.accountName: item.author});
  }
}
