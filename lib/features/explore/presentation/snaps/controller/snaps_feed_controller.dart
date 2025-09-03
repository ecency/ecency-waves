import 'dart:async';
import 'package:flutter/material.dart';
import 'package:waves/core/dependency_injection/dependency_injection.dart';
import 'package:waves/core/models/action_response.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/core/utilities/generics/controllers/controller_interface.dart';
import 'package:waves/core/utilities/generics/mixins/pagination_mixin.dart';
import 'package:waves/features/explore/repository/explore_repository.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';
import 'package:waves/features/threads/repository/thread_repository.dart';
import 'package:waves/features/threads/presentation/thread_feed/view_models/view_model.dart';

class SnapsFeedController extends ChangeNotifier
    with PaginationMixin
    implements ControllerInterface<ThreadFeedModel> {
  final ExploreRepository _exploreRepository = getIt<ExploreRepository>();
  final ThreadRepository _threadRepository = getIt<ThreadRepository>();

  final String? tag;
  final String? username;
  final String? observer;
  ThreadFeedType threadType;
  String? errorMessage;

  final Set<String> _snapKeys = {};
  // Holds container root posts that are scanned for user content.
  final List<ThreadFeedModel> _roots = [];
  int _rootIndex = 0;
  String? _lastRootAuthor;
  String? _lastRootPermlink;
  bool _isFallback = false;

  @override
  List<ThreadFeedModel> items = [];

  @override
  ViewState viewState = ViewState.loading;

  SnapsFeedController.tag({
    required this.tag,
    required this.threadType,
    this.observer,
  })  : username = null {
    pageLimit = 5;
    init();
  }

  SnapsFeedController.account({
    required this.username,
    required this.threadType,
    this.observer,
  })  : tag = null {
    pageLimit = 5;
    init();
  }

  @override
  Future<void> init() async {
    final container = _getContainer();
    ActionListDataResponse<ThreadInfo> snapRes;
    if (tag != null) {
      snapRes = await _exploreRepository.getTagSnaps(container, tag!);
    } else {
      snapRes = await _exploreRepository.getAccountSnaps(container, username!);
    }

    if (snapRes.isSuccess && snapRes.data != null && snapRes.data!.isNotEmpty) {
      _snapKeys.addAll(
          snapRes.data!.map((e) => '${e.author}/${e.permlink}'));
      await _loadCurrentPage();
    } else {
      errorMessage = snapRes.errorMessage.isNotEmpty
          ? snapRes.errorMessage
          : null;
      if (username != null) {
        _isFallback = true;
        notifyListeners();
        unawaited(_loadFallbackPage());
      } else {
        viewState = ViewState.empty;
        notifyListeners();
      }
    }
  }

  Future<void> _ensureRoots() async {
    if (_rootIndex < _roots.length) return;
    // Fetch the most recent container posts to match snaps against
    // replies within those threads.
    const fetchLimit = 20;
    final rootRes = await _threadRepository.getAccountPosts(
      _getContainer(),
      AccountPostType.posts,
      fetchLimit,
      lastAuthor: _lastRootAuthor,
      lastPermlink: _lastRootPermlink,
    );

    if (rootRes.isSuccess && rootRes.data != null && rootRes.data!.isNotEmpty) {
      // Deduplicate by author/permlink across existing and newly fetched roots.
      final seen = _roots.map((e) => '${e.author}/${e.permlink}').toSet();
      final newRoots = rootRes.data!
          .where((e) => seen.add('${e.author}/${e.permlink}'))
          .toList();
      if (newRoots.isNotEmpty) {
        _roots.addAll(newRoots);
        _lastRootAuthor = _roots.last.author;
        _lastRootPermlink = _roots.last.permlink;
      } else {
        // No additional container posts to scan, so stop requesting more.
        isPageEnded = true;
      }
    } else {
      isPageEnded = true;
    }
  }

  Future<void> _loadCurrentPage() async {
    if (_snapKeys.isEmpty) {
      isPageEnded = true;
      viewState = items.isEmpty ? ViewState.empty : ViewState.data;
      notifyListeners();
      return;
    }

    int added = 0;
    while (added < pageLimit && _snapKeys.isNotEmpty && !isPageEnded) {
      await _ensureRoots();
      if (_rootIndex >= _roots.length) break;

      final root = _roots[_rootIndex++];
      final rootKey = '${root.author}/${root.permlink}';
      if (_snapKeys.remove(rootKey)) {
        items.add(root);
        added++;
      }

      if (added < pageLimit && _snapKeys.isNotEmpty) {
        final res = await _threadRepository.getcomments(
          root.author,
          root.permlink,
          observer,
        );
        if (res.isSuccess && res.data != null && res.data!.isNotEmpty) {
          // Scan the full comment tree so snaps that appear as replies are not
          // missed. `getcomments` may return nested replies, so instead of
          // filtering only top-level comments, walk every entry and match on
          // author/permlink pairs returned by the Peakd snaps API.
          for (final t in res.data!) {
            final key = '${t.author}/${t.permlink}';
            if (_snapKeys.remove(key)) {
              items.add(t);
              added++;
              if (added >= pageLimit) break;
            }
          }
        }
      }
    }

    if (_snapKeys.isEmpty) {
      isPageEnded = true;
    }
    viewState = items.isEmpty ? ViewState.empty : ViewState.data;
    notifyListeners();
  }

  Future<void> _loadFallbackPage() async {
    int added = 0;
    while (added < pageLimit && !isPageEnded) {
      await _ensureRoots();
      if (_rootIndex >= _roots.length) break;

      final root = _roots[_rootIndex++];

      if (root.author == username) {
        items.add(root);
        added++;
        if (added >= pageLimit) continue;
      }

      final res = await _threadRepository.getcomments(
        root.author,
        root.permlink,
        observer,
      );
      if (res.isSuccess && res.data != null && res.data!.isNotEmpty) {
        for (final t in res.data!) {
          if (t.author == username) {
            items.add(t);
            added++;
            if (added >= pageLimit) break;
          }
        }
      }
    }

    viewState = items.isEmpty ? ViewState.empty : ViewState.data;
    if (_rootIndex >= _roots.length) {
      isPageEnded = true;
    }
    notifyListeners();
  }

  @override
  void loadNextPage() async {
    if (isNextPageLoading || isPageEnded) return;
    isNextPageLoading = true;
    notifyListeners();
    if (_isFallback) {
      await _loadFallbackPage();
    } else {
      await _loadCurrentPage();
    }
    isNextPageLoading = false;
    notifyListeners();
  }

  @override
  void refresh() {
    items = [];
    _snapKeys.clear();
    _roots.clear();
    _rootIndex = 0;
    _lastRootAuthor = null;
    _lastRootPermlink = null;
    errorMessage = null;
    _isFallback = false;
    isPageEnded = false;
    viewState = ViewState.loading;
    init();
  }

  void updateThreadType(ThreadFeedType type) {
    if (threadType != type) {
      threadType = type;
      refresh();
    }
  }

  String _getContainer() {
    switch (threadType) {
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

