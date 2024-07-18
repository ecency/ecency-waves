import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/threads/models/thread_feeds/reported/thread_info_model.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';

class Thread {
  static ThreadFeedType defaultThreadType = ThreadFeedType.ecency;

  static void sortList(List<ThreadFeedModel> list, {bool isAscending = false}) {
    list.sort((a, b) {
      var bTime = isAscending ? a.created : b.created;
      var aTime = isAscending ? b.created : a.created;
      if (aTime.isAfter(bTime)) {
        return -1;
      } else if (bTime.isAfter(aTime)) {
        return 1;
      } else {
        return 0;
      }
    });
  }

  static List<ThreadFeedModel> filterTopLevelComments(String parentPermlink,
      {required List<ThreadFeedModel> items, required int depth}) {
    List<ThreadFeedModel> result = items;
    result = result
        .where((element) =>
            element.depth == depth && element.parentPermlink == parentPermlink)
        .toList();
    sortList(result, isAscending: false);
    return result;
  }

  static List<ThreadFeedModel> filterReportedThreads({
    required List<ThreadFeedModel> items,
    required List<ThreadInfoModel> reportedThreads,
  }) {
    List<ThreadFeedModel> result = items.where((element) {
      return !reportedThreads.any((reported) =>
          reported.author == element.author &&
          reported.permlink == element.permlink);
    }).toList();

    sortList(result, isAscending: false);
    return result;
  }

  static String getThreadImage({required ThreadFeedType type}) {
    switch (type) {
      case ThreadFeedType.ecency:
        return "assets/images/waves.png";
      case ThreadFeedType.liketu:
        return "assets/images/logo/liketu_logo.png";
      case ThreadFeedType.leo:
        return "assets/images/logo/inleo_logo.jpg";
      case ThreadFeedType.dbuzz:
        return "assets/images/logo/buzz_logo.jpg";
      case ThreadFeedType.all:
        return "assets/images/waves.png";
    }
  }

  static String gethreadName({required ThreadFeedType type}) {
    switch (type) {
      case ThreadFeedType.ecency:
        return "Waves";
      case ThreadFeedType.liketu:
        return "Moments";
      case ThreadFeedType.leo:
        return "Threads";
      case ThreadFeedType.dbuzz:
        return "Buzz";
      case ThreadFeedType.all:
        return "All";
    }
  }
}
