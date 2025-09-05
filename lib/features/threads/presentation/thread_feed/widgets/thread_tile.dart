import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:waves/core/routes/routes.dart';
import 'package:waves/core/utilities/constants/ui_constants.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/core/dependency_injection/dependency_injection.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_json_meta_data/thread_json_meta_data.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/interaction_tile.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/markdown/thread_markdown.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/post_poll/post_poll.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/thread_user_info_tile.dart';
import 'package:waves/features/threads/repository/thread_repository.dart';

class ThreadTile extends StatelessWidget {
  const ThreadTile(
      {this.hideCommentInfo = false,
      this.threadType = ThreadFeedType.ecency,
      super.key,
      required this.item});

  final ThreadFeedModel item;
  final bool hideCommentInfo;
  final ThreadFeedType threadType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kScreenHorizontalPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ThreadUserInfoTile(
            item: item,
          ),
          const Gap(
            8,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 48.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                    onTap: () async {
                      ThreadFeedModel target = item;
                      if (item.pendingPayoutValue == null ||
                          item.pendingPayoutValue.toString().isEmpty) {
                        final repo = getIt<ThreadRepository>();
                        final res = await repo.getcomments(
                            item.author, item.permlink, null);
                        if (res.isSuccess && res.data != null) {
                          final fetched = res.data!
                              .firstWhere(
                                  (e) =>
                                      e.author == item.author &&
                                      e.permlink == item.permlink,
                                  orElse: () => item);
                          target = fetched;
                        }
                      }
                      // ignore: use_build_context_synchronously
                      context.pushNamed(Routes.commentDetailView, extra: target);
                    },
                    child: ThreadMarkDown(item: item, threadType: threadType)),
                item.jsonMetadata?.contentType == ContentType.poll ? PostPoll(item: item) : Container() ,
                const Gap(20),
                InteractionTile(
                  item: item,
                  hideCommentInfo: hideCommentInfo,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
