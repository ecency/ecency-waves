import 'package:flutter/material.dart';
import 'package:waves/core/common/widgets/empty_state.dart';
import 'package:waves/core/common/widgets/images/user_profile_image.dart';
import 'package:waves/core/common/widgets/loading_state.dart';
import 'package:waves/core/providers/bookmark_provider.dart';
import 'package:waves/core/utilities/constants/ui_constants.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_bookmark_model.dart';

class ThreadBookmarkWidget extends StatelessWidget {
  const ThreadBookmarkWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    BookmarkProvider bookmarkProvider =
        BookmarkProvider<ThreadBookmarkModel>(type: BookmarkType.thread);
    return FutureBuilder<List<ThreadBookmarkModel>>(
      future: bookmarkProvider.getBookmarks(),
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            snapshot.connectionState == ConnectionState.done) {
          List<ThreadBookmarkModel> items = snapshot.data!;
          if (items.isNotEmpty) {
            return ListView.builder(
                padding: kScreenVerticalPadding,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  ThreadBookmarkModel item = items[index];
                  return ListTile(
                    leading: UserProfileImage(url: item.author),
                    title: Text(
                      "${item.author}/${item.permlink}",
                      style: theme.textTheme.bodyMedium,
                    ),
                  );
                });
          } else {
            return const Emptystate(text: "No bookmarks found");
          }
        } else {
          return const LoadingState();
        }
      },
    );
  }
}
