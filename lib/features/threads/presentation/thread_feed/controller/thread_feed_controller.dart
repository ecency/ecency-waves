import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:waves/core/dependency_injection/dependency_injection.dart';
import 'package:waves/core/models/action_response.dart';
import 'package:waves/core/providers/bookmark_provider.dart';
import 'package:waves/core/services/moderation_service.dart';
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
  final ModerationService _moderationService = getIt<ModerationService>();
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

  Set<String> _mutedAuthors = const <String>{};
  bool _hasLoadedMutedAuthors = false;
  bool _shouldForceMutedRefresh = true;

  @override
  ViewState viewState = ViewState.loading;

  ThreadFeedController({required this.observer}) {
    threadType = _localRepository.readDefaultThread();
    super.pageLimit = 10;
    init();
  }

  @override
  Future<void> init() async {
    await _ensureMutedAuthors(forceRefresh: _shouldForceMutedRefresh);
    _shouldForceMutedRefresh = false;
    if (threadType == ThreadFeedType.all) {
      await _loadAllFeedType(threadType);
    } else {
      await _loadSingleFeedType(threadType);
    }
  }

  Future<void> updateObserver(String? newObserver) async {
    observer = newObserver;
    _hasLoadedMutedAuthors = false;
    _shouldForceMutedRefresh = true;
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
    await _ensureMutedAuthors();
    _loadLocalThreads(type);

    final accountPostResponse = await _repository.getAccountPosts(
      _getThreadAccountName(),
      _postType,
      pageLimit,
      observer: observer,
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

        // Ensure the current index is always pointing to a valid entry.
        currentPage = 0;
        final current = _threadInfoAt(currentPage);
        if (current == null) {
          if (items.isEmpty) viewState = ViewState.empty;
          notifyListeners();
          return;
        }

        // fetch discussion for first root
        ActionListDataResponse<ThreadFeedModel> response =
        await _repository.getcomments(
          current.author,
          current.permlink,
          observer,
        );

        // fallback to second root once if needed
        if ((!response.isSuccess) || response.data == null || response.data!.isEmpty) {
          if (pages.length > 1) {
            final altHost = _threadInfoAt(1);
            if (altHost != null) {
              final alt = await _repository.getcomments(
                altHost.author,
                altHost.permlink,
                observer,
              );
            if (alt.isSuccess && alt.data != null && alt.data!.isNotEmpty) {
              response = alt;
              currentPage = 1;
              }
            }
          }
        }

        if (response.isSuccess && response.data != null) {
          if (type == threadType) {
            final raw = response.data!;
            final host = _threadInfoAt(currentPage);
            if (host == null) {
              debugPrint('[threads] discussion skipped: invalid host index=$currentPage pages=${pages.length}');
              return;
            }
            debugPrint('[threads] discussion raw=${raw.length} root=${host.permlink}');

            // top-level filter
            List<ThreadFeedModel> viewItems = filterTopLevelComments(
              host.permlink,
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

            viewItems = Thread.filterInvisibleContent(
              viewItems,
              mutedAuthors: _mutedAuthors,
            );

            if (viewItems.isEmpty) {
              await _localRepository.removeLocalThreads(type);
              items = [];
              isDataDisplayedFromServer = true;
              viewState = ViewState.empty;
            } else {
              await _localRepository.writeLocalThreads(viewItems, type);

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
      await _ensureMutedAuthors();
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
    final postResponse = await _repository.getFirstAccountPost(
      _getThreadAccountName(type: type),
      _postType,
      1,
      observer: observer,
    );
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
        return Thread.filterInvisibleContent(
          filtered,
          mutedAuthors: _mutedAuthors,
        );
      }
    }
    return null;
  }

  void _loadLocalThreads(ThreadFeedType type) {
    final localThreads = _localRepository.readLocalThreads(type);
    if (localThreads == null || localThreads.isEmpty) {
      return;
    }

    final filtered = Thread.filterInvisibleContent(
      localThreads,
      mutedAuthors: _mutedAuthors,
    );
    if (filtered.length != localThreads.length) {
      unawaited(_localRepository.writeLocalThreads(filtered, type));
    }

    if (filtered.isEmpty) {
      final didHaveItems = items.isNotEmpty;
      items = [];
      if (didHaveItems) {
        notifyListeners();
      }
      return;
    }

    final shouldNotify =
        viewState != ViewState.data || !listEquals(items, filtered);

    items = [...filtered];
    viewState = ViewState.data;

    if (shouldNotify) {
      notifyListeners();
    }
  }

  void loadNewFeeds() {
    final filtered = Thread.filterInvisibleContent(
      newFeeds,
      mutedAuthors: _mutedAuthors,
    );
    items = [...filtered];
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
    final host = rootThreadInfo;
    // Only insert the new comment if it targets the same container as the
    // currently viewed feed. This avoids showing newly published posts in the
    // wrong host feed when users publish to a different container.
    if (threadType != ThreadFeedType.all &&
        host != null &&
        (newComment.parentAuthor != host.author ||
            newComment.parentPermlink != host.permlink)) {
      return;
    }
    if (Thread.filterInvisibleContent(
      [newComment],
      mutedAuthors: _mutedAuthors,
    ).isEmpty) {
      return;
    }
    items = [newComment, ...items];
    if (viewState == ViewState.empty) viewState = ViewState.data;
    if (newFeeds.isNotEmpty) newFeeds = [newComment, ...newFeeds];
    notifyListeners();
  }

  void refreshOnCommentUpdated(ThreadFeedModel updated) {
    var didUpdate = false;

    final itemIndex =
        items.indexWhere((e) => e.author == updated.author && e.permlink == updated.permlink);
    if (itemIndex != -1) {
      final updatedItems = [...items];
      updatedItems[itemIndex] = updated;
      items = updatedItems;
      didUpdate = true;
    }

    if (newFeeds.isNotEmpty) {
      final newFeedIndex = newFeeds
          .indexWhere((e) => e.author == updated.author && e.permlink == updated.permlink);
      if (newFeedIndex != -1) {
        final updatedNewFeeds = [...newFeeds];
        updatedNewFeeds[newFeedIndex] = updated;
        newFeeds = updatedNewFeeds;
        didUpdate = true;
      }
    }

    if (didUpdate) {
      notifyListeners();
    }
  }

  void _updateVoteInItems(
      int feedIndex, ActiveVoteModel newVote, List<ThreadFeedModel> target) {
    final upvotedItem = target[feedIndex];
    final votes = upvotedItem.activeVotes ?? [];
    final updatedVotes = [...votes];
    final existingIndex =
        updatedVotes.indexWhere((vote) => vote.voter == newVote.voter);
    if (existingIndex != -1) {
      updatedVotes[existingIndex] = newVote;
    } else {
      updatedVotes.add(newVote);
    }
    target.removeAt(feedIndex);
    target.insert(feedIndex, upvotedItem.copyWith(activeVotes: updatedVotes));
  }

  @override
  void loadNextPage({bool saveLocal = false, ThreadFeedType? type}) async {
    type ??= threadType;
    if (!super.isNextPageLoading && isDataDisplayedFromServer) {
      super.isNextPageLoading = true;
      currentPage++;
        if (!super.isPageEnded && currentPage < pages.length) {
          notifyListeners();

          final host = _threadInfoAt(currentPage);
          if (host == null) {
            super.isNextPageLoading = false;
            notifyListeners();
            return;
          }

          final response = await _repository.getcomments(
            host.author,
            host.permlink,
            observer,
          );

          if (response.isSuccess && response.data != null && type == threadType) {
            final raw = response.data!;
            var newItems = filterTopLevelComments(host.permlink, items: raw);
          if (newItems.isEmpty && raw.isNotEmpty) {
            newItems = raw;
          }
          newItems = Thread.filterInvisibleContent(
            newItems,
            mutedAuthors: _mutedAuthors,
          );
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
    _shouldForceMutedRefresh = true;
    _reset();
    await init();
  }

  bool removeAuthorContent(String author) {
    final filteredItems =
        items.where((element) => element.author != author).toList();
    final filteredNewFeeds =
        newFeeds.where((element) => element.author != author).toList();
    final filteredPages =
        pages.where((element) => element.author != author).toList();

    final didChange = filteredItems.length != items.length ||
        filteredNewFeeds.length != newFeeds.length ||
        filteredPages.length != pages.length;

    if (!didChange) {
      return false;
    }

    items = filteredItems;
    newFeeds = filteredNewFeeds;
    pages = filteredPages;

    if (pages.isEmpty) {
      currentPage = 0;
    } else if (currentPage >= pages.length) {
      currentPage = pages.length - 1;
    }

    if (items.isEmpty) {
      viewState = ViewState.empty;
    }

    notifyListeners();
    return true;
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
    _hasLoadedMutedAuthors = false;
    if (_shouldForceMutedRefresh) {
      _mutedAuthors = const <String>{};
    }
  }

  ThreadInfo? _threadInfoAt(int index) {
    if (index < 0 || index >= pages.length) return null;
    return pages[index];
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
        return "ecency.waves";
    }
  }

  Future<Set<String>> _ensureMutedAuthors({bool forceRefresh = false}) async {
    final normalizedObserver = observer?.trim();
    if (normalizedObserver == null || normalizedObserver.isEmpty) {
      _mutedAuthors = const <String>{};
      _hasLoadedMutedAuthors = true;
      return _mutedAuthors;
    }

    if (!_hasLoadedMutedAuthors || forceRefresh) {
      _mutedAuthors = await _moderationService.loadMutedAccounts(
        normalizedObserver,
        forceRefresh: forceRefresh,
      );
      _hasLoadedMutedAuthors = true;
    }

    return _mutedAuthors;
  }
}
