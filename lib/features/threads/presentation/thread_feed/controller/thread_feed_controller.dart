import 'package:flutter/foundation.dart';
import 'package:waves/core/dependency_injection/dependency_injection.dart';
import 'package:waves/core/models/action_response.dart';
import 'package:waves/core/providers/bookmark_provider.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/core/utilities/generics/classes/thread.dart';
import 'package:waves/core/utilities/generics/controllers/controller_interface.dart';
import 'package:waves/core/utilities/generics/mixins/pagination_mixin.dart';
import 'package:waves/features/threads/models/post_detail/upvote_model.dart';
import 'package:waves/features/threads/models/thread_feeds/reported/report_reponse.dart';
import 'package:waves/features/threads/models/thread_feeds/reported/thread_info_model.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_bookmark_model.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';
import 'package:waves/features/threads/presentation/thread_feed/view_models/view_model.dart';
import 'package:waves/features/threads/repository/thread_local_repository.dart';
import 'package:waves/features/threads/repository/thread_repository.dart';

class ThreadFeedController extends ChangeNotifier
    with PaginationMixin
    implements ControllerInterface<ThreadFeedModel> {
  final ThreadRepository _repository = getIt<ThreadRepository>();
  final ThreadLocalRepository _localRepository = getIt<ThreadLocalRepository>();
  late ThreadFeedType threadType;
  final AccountPostType _postType = AccountPostType.posts;

  final BookmarkProvider bookmarkProvider =
  BookmarkProvider<ThreadBookmarkModel>(type: BookmarkType.thread);

  String? observer;
  int currentPage = 0;
  bool isDataDisplayedFromServer = false;

  List<ThreadInfo> pages = [];
  @override
  List<ThreadFeedModel> items = [];
  List<ThreadFeedModel> newFeeds = [];

  @override
  ViewState viewState = ViewState.loading;

  ThreadFeedController({required this.observer}) {
    threadType = _localRepository.readDefaultThread();
    super.pageLimit = 10;
    init();
  }

  @override
  Future<void> init() async {
    if (threadType == ThreadFeedType.all) {
      await _loadAllFeedType(threadType);
    } else {
      await _loadSingleFeedType(threadType);
    }
  }

  Future<void> updateObserver(String? newObserver) async {
    observer = newObserver;
    await refresh();
  }

  void dumpAccountPosts(ActionListDataResponse<ThreadFeedModel> r) {
    final list = r.data ?? const <ThreadFeedModel>[];
    debugPrint('success=${r.isSuccess} status=${r.status} err="${r.errorMessage}"');
    debugPrint('count=${list.length}');
    if (list.isNotEmpty) {
      final first = list.first;
      debugPrint('first: ${first.author}/${first.permlink} id=${first.postId}');
    }
  }

  Future<void> _loadSingleFeedType(ThreadFeedType type) async {
    _loadLocalThreads(type);

    final accountPostResponse = await _repository.getAccountPosts(
      _getThreadAccountName(),
      _postType,
      pageLimit,
    );
    dumpAccountPosts(accountPostResponse);

    if (accountPostResponse.isSuccess) {
      final roots = accountPostResponse.data;

      if (roots != null && roots.isNotEmpty) {
        // dedupe
        final seen = <String>{};
        pages = roots
            .map((e) => ThreadInfo(author: e.author, permlink: e.permlink))
            .where((ti) => seen.add('${ti.author}/${ti.permlink}'))
            .toList();

        if (pages.isEmpty) {
          if (items.isEmpty) viewState = ViewState.empty;
          notifyListeners();
          return;
        }

        // fetch discussion for first root
        ActionListDataResponse<ThreadFeedModel> response =
        await _repository.getcomments(
          pages[0].author,
          pages[0].permlink,
          observer,
        );

        // fallback to second root once if needed
        if ((!response.isSuccess) || response.data == null || response.data!.isEmpty) {
          if (pages.length > 1) {
            final alt = await _repository.getcomments(
              pages[1].author,
              pages[1].permlink,
              observer,
            );
            if (alt.isSuccess && alt.data != null && alt.data!.isNotEmpty) {
              response = alt;
              currentPage = 1;
            }
          }
        }

        if (response.isSuccess && response.data != null) {
          if (type == threadType) {
            final raw = response.data!;
            debugPrint('[threads] discussion raw=${raw.length} root=${pages[currentPage].permlink}');

            // top-level filter
            List<ThreadFeedModel> viewItems = filterTopLevelComments(
              pages[currentPage].permlink,
              items: raw,
            );
            debugPrint('[threads] topLevel after filter=${viewItems.length}');

            // SAFETY: if filter nukes everything but raw has data, use raw
            if (viewItems.isEmpty && raw.isNotEmpty) {
              debugPrint('[threads] filter==0; using raw discussion for visibility');
              viewItems = raw;
            }

            // remove reported
            viewItems = Thread.filterReportedThreads(
              items: viewItems,
              reportedThreads: _localRepository.readReportedThreads(),
            );

            viewItems = Thread.filterInvisibleContent(viewItems);

            if (viewItems.isEmpty && viewState != ViewState.data) {
              viewState = ViewState.empty;
            } else if (viewItems.isNotEmpty) {
              _localRepository.writeLocalThreads(viewItems, type);

              // >>> ALWAYS APPLY SERVER DATA <<<
              items = [...viewItems];
              isDataDisplayedFromServer = true;
              _loadNextPageOnFewerResults(type);

              viewState = ViewState.data;
            }
          }
        } else if (items.isEmpty) {
          viewState = ViewState.error;
        }
      } else if (items.isEmpty) {
        viewState = ViewState.empty;
      }
    } else if (items.isEmpty) {
      viewState = ViewState.error;
    }

    debugPrint('[CTRL] viewState=$viewState items=${items.length} page=$currentPage pages=${pages.length}');
    notifyListeners();
  }

  Future<void> _loadAllFeedType(ThreadFeedType type) async {
    try {
      final totalFeeds = await Future.wait<List<ThreadFeedModel>?>(
        [
          _loadFeed(ThreadFeedType.ecency),
          _loadFeed(ThreadFeedType.peakd),
          _loadFeed(ThreadFeedType.liketu),
          _loadFeed(ThreadFeedType.leo),
        ],
      );

      if (totalFeeds.every((list) => list == null)) {
        viewState = ViewState.error;
      } else {
        final singleFeedList =
        totalFeeds.where((list) => list != null).expand((list) => list!).toList();
        if (type == threadType) {
          Thread.sortList(singleFeedList);
          if (singleFeedList.isEmpty) {
            viewState = ViewState.empty;
          } else {
            items = singleFeedList;
            viewState = ViewState.data;
          }
        }
      }
      notifyListeners();
    } catch (e) {
      viewState = ViewState.error;
      notifyListeners();
    }
  }

  Future<List<ThreadFeedModel>?> _loadFeed(ThreadFeedType type) async {
    final postResponse =
    await _repository.getFirstAccountPost(_getThreadAccountName(type: type), _postType, 1);
    if (postResponse.isSuccess && postResponse.data != null) {
      final response = await _repository.getcomments(
        postResponse.data!.author,
        postResponse.data!.permlink,
        observer,
      );
      if (response.isSuccess && response.data != null) {
        final raw = response.data!;
        var filtered = filterTopLevelComments(postResponse.data!.permlink, items: raw);
        if (filtered.isEmpty && raw.isNotEmpty) {
          filtered = raw;
        }
        return Thread.filterInvisibleContent(filtered);
      }
    }
    return null;
  }

  void _loadLocalThreads(ThreadFeedType type) {
    final localThreads = _localRepository.readLocalThreads(type);
    if (localThreads != null && localThreads.isNotEmpty) {
      items = [...localThreads];
      viewState = ViewState.data;
    }
  }

  void loadNewFeeds() {
    items = [...newFeeds];
    isDataDisplayedFromServer = true;
    viewState = ViewState.data;
    _loadNextPageOnFewerResults(threadType);
    newFeeds = [];
    notifyListeners();
  }

  void _loadNextPageOnFewerResults(ThreadFeedType type) {
    if (items.length < 10) {
      loadNextPage(saveLocal: true, type: type);
    }
  }

  Future<void> refreshOnUpvote(int postId, ActiveVoteModel newVote) async {
    final feedIndex = items.indexWhere((e) => e.postId == postId);
    final newFeedIndex = newFeeds.indexWhere((e) => e.postId == postId);
    if (feedIndex != -1) _updateVoteInItems(feedIndex, newVote, items);
    if (newFeeds.isNotEmpty && newFeedIndex != -1) {
      _updateVoteInItems(newFeedIndex, newVote, newFeeds);
    }
    items = [...items];
    newFeeds = [...newFeeds];
    notifyListeners();
    // Allow backend to register the vote before reloading the feed
    await Future.delayed(const Duration(seconds: 5));
    await refresh();
  }

  void refreshOnRootComment(ThreadFeedModel newComment) {
    items = [newComment, ...items];
    if (viewState == ViewState.empty) viewState = ViewState.data;
    if (newFeeds.isNotEmpty) newFeeds = [newComment, ...newFeeds];
    notifyListeners();
  }

  void _updateVoteInItems(
      int feedIndex, ActiveVoteModel newVote, List<ThreadFeedModel> target) {
    final upvotedItem = target[feedIndex];
    final votes = upvotedItem.activeVotes;
    final alteredVotes = votes == null ? [newVote] : [...votes, newVote];
    target.removeAt(feedIndex);
    target.insert(feedIndex, upvotedItem.copyWith(activeVotes: alteredVotes));
  }

  @override
  void loadNextPage({bool saveLocal = false, ThreadFeedType? type}) async {
    type ??= threadType;
    if (!super.isNextPageLoading && isDataDisplayedFromServer) {
      super.isNextPageLoading = true;
      currentPage++;
      if (!super.isPageEnded && currentPage < pages.length) {
        notifyListeners();

        final response = await _repository.getcomments(
          pages[currentPage].author,
          pages[currentPage].permlink,
          observer,
        );

        if (response.isSuccess && response.data != null && type == threadType) {
          final raw = response.data!;
          var newItems = filterTopLevelComments(pages[currentPage].permlink, items: raw);
          if (newItems.isEmpty && raw.isNotEmpty) {
            newItems = raw;
          }
          newItems = Thread.filterInvisibleContent(newItems);
          items = [...items, ...newItems];
          if (saveLocal) _localRepository.writeLocalThreads(items, type);
        }

        super.isNextPageLoading = false;
        notifyListeners();
      } else {
        super.isPageEnded = true;
        notifyListeners();
      }
      super.isNextPageLoading = false;
    }
  }

  Future<bool> reportThread(String author, String permlink) async {
    final response = await _repository.reportThread(author, permlink);
    if (response.isSuccess && response.data!.isSuccess) {
      _localRepository.writeReportedThreads(
          ThreadInfoModel(author: author, permlink: permlink));
      refresh();
      return true;
    } else {
      return false;
    }
  }

  @override
  Future<void> refresh() async {
    if (viewState != ViewState.data) {
      viewState = ViewState.loading;
      notifyListeners();
    }
    _reset();
    await init();
  }

  List<ThreadFeedModel> filterTopLevelComments(String parentPermlink,
      {List<ThreadFeedModel>? items}) {
    final result = items ?? this.items;
    return Thread.filterTopLevelComments(parentPermlink, items: result, depth: 1);
  }

  ThreadInfo? get rootThreadInfo => pages.isNotEmpty ? pages.first : null;

  void onTapFilter(ThreadFeedType type) {
    if (threadType != type) {
      _reset();
      viewState = ViewState.loading;
      threadType = type;
      notifyListeners();
      if (type == ThreadFeedType.all) {
        _loadAllFeedType(type);
      } else {
        _loadSingleFeedType(type);
      }
    }
  }

  void _reset() {
    isDataDisplayedFromServer = false;
    super.isNextPageLoading = false;
    super.isPageEnded = false;
    currentPage = 0;
    pages = [];
    items = [];
    newFeeds = [];
  }

  String _getThreadAccountName({ThreadFeedType? type}) {
    switch (type ?? threadType) {
      case ThreadFeedType.ecency:
        return "ecency.waves";
      case ThreadFeedType.peakd:
        return "peak.snaps";
      case ThreadFeedType.liketu:
        return "liketu.moments";
      case ThreadFeedType.leo:
        return "leothreads";
      case ThreadFeedType.all:
        return "All";
    }
  }
}
