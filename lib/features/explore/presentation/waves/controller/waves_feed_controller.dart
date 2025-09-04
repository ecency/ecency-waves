import 'package:flutter/material.dart';
import 'package:waves/core/dependency_injection/dependency_injection.dart';
import 'package:waves/core/models/action_response.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/core/utilities/generics/controllers/controller_interface.dart';
import 'package:waves/core/utilities/generics/mixins/pagination_mixin.dart';
import 'package:waves/features/explore/repository/explore_repository.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';
import 'package:waves/features/threads/presentation/thread_feed/view_models/view_model.dart';

class WavesFeedController extends ChangeNotifier
    with PaginationMixin
    implements ControllerInterface<ThreadFeedModel> {
  final ExploreRepository _exploreRepository = getIt<ExploreRepository>();

  final String? tag;
  final String? username;
  ThreadFeedType threadType;
  String? errorMessage;

  String? _lastAuthor;
  String? _lastPermlink;

  @override
  List<ThreadFeedModel> items = [];

  @override
  ViewState viewState = ViewState.loading;

  WavesFeedController.tag({
    required this.tag,
    required this.threadType,
  })  : username = null {
    pageLimit = 20;
    init();
  }

  WavesFeedController.account({
    required this.username,
    required this.threadType,
  })  : tag = null {
    pageLimit = 20;
    init();
  }

  @override
  Future<void> init() async {
    await _fetchPage();
  }

  Future<void> _fetchPage() async {
    final container = _getContainer();
    ActionListDataResponse<ThreadFeedModel> waveRes;
    if (tag != null) {
      waveRes = await _exploreRepository.getTagWaves(container, tag!,
          limit: pageLimit, lastAuthor: _lastAuthor, lastPermlink: _lastPermlink);
    } else {
      waveRes = await _exploreRepository.getAccountWaves(container, username!,
          limit: pageLimit, lastAuthor: _lastAuthor, lastPermlink: _lastPermlink);
    }

    if (waveRes.isSuccess && waveRes.data != null && waveRes.data!.isNotEmpty) {
      items.addAll(waveRes.data!);
      final last = waveRes.data!.last;
      _lastAuthor = last.author;
      _lastPermlink = last.permlink;
      viewState = ViewState.data;
      if (waveRes.data!.length < pageLimit) {
        isPageEnded = true;
      }
    } else {
      if (items.isEmpty) {
        viewState = ViewState.empty;
      }
      errorMessage = waveRes.errorMessage.isNotEmpty
          ? waveRes.errorMessage
          : null;
      isPageEnded = true;
    }
    notifyListeners();
  }

  @override
  void loadNextPage() async {
    if (isNextPageLoading || isPageEnded) return;
    isNextPageLoading = true;
    notifyListeners();
    await _fetchPage();
    isNextPageLoading = false;
    notifyListeners();
  }

  @override
  void refresh() {
    items = [];
    _lastAuthor = null;
    _lastPermlink = null;
    errorMessage = null;
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

