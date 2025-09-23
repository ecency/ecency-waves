import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:waves/core/common/extensions/ui.dart';
import 'package:waves/core/common/widgets/empty_state.dart';
import 'package:waves/core/common/widgets/images/user_profile_image.dart';
import 'package:waves/core/common/widgets/loading_state.dart';
import 'package:waves/core/dependency_injection/dependency_injection.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/providers/bookmark_provider.dart';
import 'package:waves/core/routes/routes.dart';
import 'package:waves/core/utilities/constants/ui_constants.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_bookmark_model.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';
import 'package:waves/features/threads/repository/thread_repository.dart';

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
                    onTap: () async {
                      context.showLoader();
                      final repo = getIt<ThreadRepository>();
                      final response = await repo.getcomments(
                          item.author, item.permlink, null);
                      if (!context.mounted) {
                        return;
                      }
                      context.hideLoader();
                      if (response.isSuccess &&
                          response.data != null &&
                          response.data!.isNotEmpty) {
                        final ThreadFeedModel target = response.data!
                            .firstWhere(
                                (element) =>
                                    element.author == item.author &&
                                    element.permlink == item.permlink,
                                orElse: () => response.data!.first);
                        context.pushNamed(Routes.commentDetailView, extra: target);
                      } else {
                        context.showSnackBar(LocaleText.somethingWentWrong);
                      }
                    },
                  );
                });
          } else {
            return Emptystate(text: LocaleText.noBookmarksFound);
          }
        } else {
          return const LoadingState();
        }
      },
    );
  }
}
