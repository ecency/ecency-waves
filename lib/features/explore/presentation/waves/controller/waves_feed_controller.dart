import 'package:flutter/material.dart';
import 'package:waves/core/dependency_injection/dependency_injection.dart';
import 'package:waves/core/models/action_response.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/core/utilities/generics/controllers/controller_interface.dart';
import 'package:waves/core/utilities/generics/mixins/pagination_mixin.dart';
import 'package:waves/core/utilities/generics/classes/thread.dart';
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
  String? observer;

  String? _lastAuthor;
  String? _lastPermlink;

  @override
  List<ThreadFeedModel> items = [];

  @override
  ViewState viewState = ViewState.loading;

  WavesFeedController.tag({
    required this.tag,
    required this.threadType,
    this.observer,
  })  : username = null {
    pageLimit = 20;
    init();
  }

  WavesFeedController.account({
    required this.username,
    required this.threadType,
    this.observer,
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
      waveRes = await _exploreRepository.getTagWaves(
        container,
        tag!,
        limit: pageLimit,
        lastAuthor: _lastAuthor,
        lastPermlink: _lastPermlink,
        observer: observer,
      );
    } else {
      waveRes = await _exploreRepository.getAccountWaves(
        container,
        username!,
        limit: pageLimit,
        lastAuthor: _lastAuthor,
        lastPermlink: _lastPermlink,
        observer: observer,
      );
    }

    if (waveRes.isSuccess && waveRes.data != null) {
      final data = waveRes.data!;
      if (data.isNotEmpty) {
        final filtered = Thread.filterInvisibleContent(data);
        final last = data.last;
        _lastAuthor = last.author;
        _lastPermlink = last.permlink;
        if (filtered.isNotEmpty) {
          items.addAll(filtered);
          viewState = ViewState.data;
        } else if (items.isEmpty) {
          viewState = ViewState.empty;
        }
        if (data.length < pageLimit) {
          isPageEnded = true;
        }
      } else if (items.isEmpty) {
        viewState = ViewState.empty;
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
    notifyListeners();
    init();
  }

  bool removeAuthorContent(String author) {
    final filteredItems =
        items.where((element) => element.author != author).toList();
    if (filteredItems.length == items.length) {
      return false;
    }

    items = filteredItems;
    if (items.isEmpty) {
      viewState = ViewState.empty;
      isPageEnded = true;
      isNextPageLoading = false;
    }
    notifyListeners();
    return true;
  }

  void updateObserver(String? value) {
    if (observer == value) {
      return;
    }
    observer = value;
    refresh();
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

