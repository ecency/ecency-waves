import 'package:flutter/material.dart';
import 'package:waves/core/dependency_injection/dependency_injection.dart';
import 'package:waves/core/models/action_response.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/core/utilities/generics/classes/thread.dart';
import 'package:waves/core/utilities/generics/controllers/controller_interface.dart';
import 'package:waves/core/utilities/generics/mixins/pagination_mixin.dart';
import 'package:waves/features/explore/repository/explore_repository.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';
import 'package:waves/features/threads/presentation/thread_feed/view_models/view_model.dart';
import 'package:waves/features/threads/repository/thread_repository.dart';

class SnapsFeedController extends ChangeNotifier
    with PaginationMixin
    implements ControllerInterface<ThreadFeedModel> {
  final ExploreRepository _exploreRepository = getIt<ExploreRepository>();
  final ThreadRepository _threadRepository = getIt<ThreadRepository>();

  final String? tag;
  final String? username;
  final String? observer;
  ThreadFeedType threadType;

  final Set<String> _snapKeys = {};
  final List<ThreadInfo> _roots = [];
  int _rootIndex = 0;
  String? _lastRootAuthor;
  String? _lastRootPermlink;

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
      _snapKeys
          .addAll(snapRes.data!.map((e) => '${e.author}/${e.permlink}'));
      await _loadCurrentPage();
    } else {
      viewState = ViewState.empty;
      notifyListeners();
    }
  }

  Future<void> _ensureRoots() async {
    if (_rootIndex < _roots.length) return;

    final rootRes = await _threadRepository.getAccountPosts(
      _getContainer(),
      AccountPostType.posts,
      pageLimit,
      lastAuthor: _lastRootAuthor,
      lastPermlink: _lastRootPermlink,
    );

    if (rootRes.isSuccess && rootRes.data != null && rootRes.data!.isNotEmpty) {
      final seen = <String>{};
      final newRoots = rootRes.data!
          .map((e) => ThreadInfo(author: e.author, permlink: e.permlink))
          .where((ti) => seen.add('${ti.author}/${ti.permlink}'))
          .toList();
      if (newRoots.isNotEmpty) {
        _roots.addAll(newRoots);
        _lastRootAuthor = _roots.last.author;
        _lastRootPermlink = _roots.last.permlink;
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
      final res = await _threadRepository.getcomments(
        root.author,
        root.permlink,
        observer,
      );
      if (res.isSuccess && res.data != null && res.data!.isNotEmpty) {
        final threads = Thread.filterTopLevelComments(
          root.permlink,
          items: res.data!,
          depth: 1,
        );
        for (final t in threads) {
          final key = '${t.author}/${t.permlink}';
          if (_snapKeys.remove(key)) {
            items.add(t);
            added++;
            if (added >= pageLimit) break;
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

  @override
  void loadNextPage() async {
    if (isNextPageLoading || isPageEnded) return;
    isNextPageLoading = true;
    notifyListeners();
    await _loadCurrentPage();
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
      case ThreadFeedType.dbuzz:
        return 'dbuzz';
      case ThreadFeedType.all:
        return 'ecency.waves';
    }
  }
}

