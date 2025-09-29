import 'package:waves/core/locales/locale_text.dart';
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

  static bool isHidden(ThreadFeedModel entry) {
    return (entry.netRshares ?? 0) < -7000000000 &&
        (entry.activeVotes?.length ?? 0) > 3;
  }

  static bool isMuted(ThreadFeedModel entry) {
    return entry.stats?.gray ?? false;
  }

  static bool isObserverHidden(ThreadFeedModel entry) {
    return entry.stats?.hide ?? false;
  }

  static bool isLowReputation(ThreadFeedModel entry) {
    return (entry.authorReputation ?? 0) < 0;
  }

  /// Removes any items that should not appear in feed views, such as entries
  /// flagged by curators (`netRshares` threshold), muted content reported by
  /// the API via `stats.gray`, observer-specific hides exposed through
  /// `stats.hide`, authors with very low reputation scores, or accounts the
  /// logged-in observer muted manually. The optional [mutedAuthors] parameter
  /// expects a lower-cased set of account names gathered from the observer's
  /// mute list.
  static List<ThreadFeedModel> filterInvisibleContent(
    List<ThreadFeedModel> items, {
    Set<String>? mutedAuthors,
  }) {
    return items
        .where((e) =>
            !(isHidden(e) ||
                isMuted(e) ||
                isObserverHidden(e) ||
                isLowReputation(e) ||
                ((mutedAuthors?.contains(e.author.toLowerCase()) ?? false))))
        .toList();
  }

  static String getThreadImage({required ThreadFeedType type}) {
    switch (type) {
      case ThreadFeedType.ecency:
        return "assets/images/waves.png";
      case ThreadFeedType.peakd:
        return "assets/images/logo/peakd_logo.png";
      case ThreadFeedType.liketu:
        return "assets/images/logo/liketu_logo.png";
      case ThreadFeedType.leo:
        return "assets/images/logo/inleo_logo.jpg";
      case ThreadFeedType.all:
        return "assets/images/waves.png";
    }
  }

  static String gethreadName({required ThreadFeedType type}) {
    switch (type) {
      case ThreadFeedType.ecency:
        return LocaleText.threadTypeEcency;
      case ThreadFeedType.peakd:
        return LocaleText.threadTypePeakd;
      case ThreadFeedType.liketu:
        return LocaleText.threadTypeLiketu;
      case ThreadFeedType.leo:
        return LocaleText.threadTypeLeo;
      case ThreadFeedType.all:
        return LocaleText.threadTypeAll;
    }
  }

  /// Returns the container account name for a given [ThreadFeedType].
  ///
  /// This is used when publishing new root content to decide which
  /// host/container the post should be sent to.
  static String getThreadAccountName({required ThreadFeedType type}) {
    switch (type) {
      case ThreadFeedType.ecency:
        return 'ecency.waves';
      case ThreadFeedType.peakd:
        return 'peak.snaps';
      case ThreadFeedType.liketu:
        return 'liketu.moments';
      case ThreadFeedType.leo:
        return 'leothreads';
      case ThreadFeedType.all:
        return 'ecency.waves';
    }
  }
}
