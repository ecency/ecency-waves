import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/widgets/images/user_profile_image.dart';
import 'package:waves/core/locales/timeago_localizations.dart';
import 'package:waves/core/routes/route_keys.dart';
import 'package:waves/core/routes/routes.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/explore/presentation/waves/controller/waves_feed_controller.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';
import 'package:waves/features/threads/presentation/thread_feed/controller/thread_feed_controller.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/thread_pop_up_menu.dart';

class ThreadUserInfoTile extends StatelessWidget {
  const ThreadUserInfoTile({
    super.key,
    required this.item,
  });

  final ThreadFeedModel item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var timeInString = formatRelativeTime(context, item.created);
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
                  child: Row(
                children: [
                  Flexible(
                    child: GestureDetector(
                      onTap: () => _pushToUserProfile(context),
                      child: Text(
                        item.author,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const Gap(10),
                  Text(
                    timeInString,
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: theme.textTheme.labelLarge!.copyWith(
                        color: theme.primaryColorDark.withOpacity(0.8)),
                  ),
                ],
              )),
              const Gap(
                12,
              ),
              ThreadPopUpMenu(
                item: item,
              )
            ],
          ),
        )
      ],
    );
  }

  Future<Object?> _pushToUserProfile(BuildContext context) {
    ThreadFeedType threadType;
    try {
      threadType = context.read<WavesFeedController>().threadType;
    } catch (_) {
      threadType = context.read<ThreadFeedController>().threadType;
    }

    final params = {
      RouteKeys.accountName: item.author,
    };
    if (threadType != ThreadFeedType.all) {
      params[RouteKeys.threadType] = enumToString(threadType);
    }

    return context.pushNamed(
      Routes.userProfileView,
      queryParameters: params,
    );
  }
}
