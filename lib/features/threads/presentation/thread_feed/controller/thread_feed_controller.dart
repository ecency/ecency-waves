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

  Future<void> _loadSingleFeedType(ThreadFeedType type) async {
    _loadLocalThreads(type);
    ActionListDataResponse<ThreadFeedModel> accountPostResponse =
        await _repository.getAccountPosts(
            _getThreadAccountName(), _postType, pageLimit);
    if (accountPostResponse.isSuccess) {
      if (accountPostResponse.data != null &&
          accountPostResponse.data!.isNotEmpty) {
        pages = accountPostResponse.data!
            .map((e) => ThreadInfo(author: e.author, permlink: e.permlink))
            .toList();
        super.pageLimit = pages.length;
        ActionListDataResponse<ThreadFeedModel> response =
            await _repository.getcomments(
                accountPostResponse.data!.first.author,
                accountPostResponse.data!.first.permlink,
                observer);
        if (response.isSuccess && response.data != null) {
          if (type == threadType) {
            List<ThreadFeedModel> items = response.data!;
            items = filterTopLevelComments(
                accountPostResponse.data!.first.permlink,
                items: items);
            items = Thread.filterReportedThreads(
                items: items,
                reportedThreads: _localRepository.readReportedThreads());

            if (items.isEmpty && viewState != ViewState.data) {
              viewState = ViewState.empty;
            } else if (items.isNotEmpty) {
              _localRepository.writeLocalThreads(items, type);
              if (this.items.isEmpty) {
                this.items = items;
                isDataDisplayedFromServer = true;
                _loadNextPageOnFewerResults(type);
              } else if (this.items.first.identifier !=
                  items.first.identifier) {
                newFeeds = [...items];
                notifyListeners();
              } else {
                isDataDisplayedFromServer = true;
                this.items = [...items];
                _loadNextPageOnFewerResults(type);
              }

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

    notifyListeners();
  }

  Future<void> _loadAllFeedType(ThreadFeedType type) async {
    try {
      List<List<ThreadFeedModel>?> totalFeeds = await Future.wait([
        _loadFeed(ThreadFeedType.ecency),
        _loadFeed(ThreadFeedType.peakd),
        _loadFeed(ThreadFeedType.liketu),
        _loadFeed(ThreadFeedType.leo),
        _loadFeed(ThreadFeedType.dbuzz),
      ]);

      if (totalFeeds.every((list) => list == null)) {
        viewState = ViewState.error;
      } else {
        List<ThreadFeedModel> singleFeedList = totalFeeds
            .where((list) => list != null)
            .expand((list) => list!)
            .toList();
        if (type == threadType) {
          Thread.sortList(singleFeedList);
          if (totalFeeds.isEmpty) {
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
    ActionSingleDataResponse<ThreadFeedModel> postResponse = await _repository
        .getFirstAccountPost(_getThreadAccountName(type: type), _postType, 1);
    if (postResponse.isSuccess) {
      ActionListDataResponse<ThreadFeedModel> response =
          await _repository.getcomments(
              postResponse.data!.author, postResponse.data!.permlink, observer);
      if (response.isSuccess) {
        return filterTopLevelComments(postResponse.data!.permlink,
            items: response.data);
      }
    }
    return null;
  }

  void _loadLocalThreads(ThreadFeedType type) {
    List<ThreadFeedModel>? localThreads =
        _localRepository.readLocalThreads(type);
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

  void refreshOnUpvote(int postId, ActiveVoteModel newVote) {
    int feedIndex = items.indexWhere((e) => e.postId == postId);
    int newFeedIndex = newFeeds.indexWhere((e) => e.postId == postId);
    if (feedIndex != -1) {
      _updateVoteInItems(feedIndex, newVote, items);
    }
    if (newFeeds.isNotEmpty && newFeedIndex != -1) {
      _updateVoteInItems(newFeedIndex, newVote, newFeeds);
    }
    items = [...items];
    newFeeds = [...newFeeds];
    notifyListeners();
  }

  void refreshOnRootComment(ThreadFeedModel newComment) {
    items = [newComment, ...items];
    if (viewState == ViewState.empty) {
      viewState = ViewState.data;
    }
    if (newFeeds.isNotEmpty) {
      newFeeds = [newComment, ...newFeeds];
    }
    notifyListeners();
  }

  void _updateVoteInItems(
      int feedIndex, ActiveVoteModel newVote, List<ThreadFeedModel> items) {
    ThreadFeedModel upvotedItem = items[feedIndex];
    List<ActiveVoteModel>? votes = upvotedItem.activeVotes;
    List<ActiveVoteModel> alteredVotes =
        votes == null ? [newVote] : [...votes, newVote];
    items.removeAt(feedIndex);
    items.insert(feedIndex, upvotedItem.copyWith(activeVotes: alteredVotes));
  }

  @override
  void loadNextPage({bool saveLocal = false, ThreadFeedType? type}) async {
    type ??= threadType;
    if (!super.isNextPageLoading && isDataDisplayedFromServer) {
      super.isNextPageLoading = true;
      currentPage++;
      if (!super.isPageEnded && currentPage < pages.length) {
        notifyListeners();
        ActionListDataResponse<ThreadFeedModel> response =
            await _repository.getcomments(pages[currentPage].author,
                pages[currentPage].permlink, observer);
        if (response.isSuccess && response.data != null && type == threadType) {
          List<ThreadFeedModel> newItems = filterTopLevelComments(
              pages[currentPage].permlink,
              items: response.data);
          items = [...items, ...newItems];
          if (saveLocal) {
            _localRepository.writeLocalThreads(items, type);
          }
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
    ActionSingleDataResponse<ReportResponse> response =
        await _repository.reportThread(author, permlink);
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
    List<ThreadFeedModel> result = items ?? this.items;
    return Thread.filterTopLevelComments(parentPermlink,
        items: result, depth: 1);
  }

  ThreadInfo? get rootThreadInfo {
    if (pages.isNotEmpty) {
      return pages.first;
    }
    return null;
  }

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
      case ThreadFeedType.dbuzz:
        return "dbuzz";
      case ThreadFeedType.all:
        return "All";
    }
  }
}
