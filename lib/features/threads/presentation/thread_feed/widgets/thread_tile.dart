import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:waves/core/utilities/constants/ui_constants.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/interaction_tile.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/markdown/thread_markdown.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/thread_user_info_tile.dart';

class ThreadTile extends StatelessWidget {
  const ThreadTile(
      {this.hideCommentInfo = false, super.key, required this.item});

  final ThreadFeedModel item;
  final bool hideCommentInfo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: item.depth < 3
          ? kScreenHorizontalPadding
          : const EdgeInsets.only(
              right: kScreenHorizontalPaddingDigit, left: 52),
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
                ThreadMarkDown(item: item),
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