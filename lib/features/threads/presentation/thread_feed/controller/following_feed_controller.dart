import 'package:flutter/material.dart';
import 'package:waves/core/dependency_injection/dependency_injection.dart';
import 'package:waves/core/models/action_response.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/core/utilities/generics/controllers/controller_interface.dart';
import 'package:waves/core/utilities/generics/mixins/pagination_mixin.dart';
import 'package:waves/core/utilities/generics/classes/thread.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';
import 'package:waves/features/threads/presentation/thread_feed/view_models/view_model.dart';
import 'package:waves/features/threads/repository/thread_local_repository.dart';
import 'package:waves/features/threads/repository/thread_repository.dart';

class FollowingFeedController extends ChangeNotifier
    with PaginationMixin
    implements ControllerInterface<ThreadFeedModel> {
  final ThreadRepository _repository = getIt<ThreadRepository>();

  FollowingFeedController({required String? initialObserver})
      : observer = initialObserver,
        threadType = getIt<ThreadLocalRepository>().readDefaultThread(),
        _container = '' {
    _container = _resolveContainer(threadType);
    pageLimit = 20;
    init();
  }

  String? observer;
  ThreadFeedType threadType;
  String? errorMessage;
  String _container;

  String? _lastAuthor;
  String? _lastPermlink;

  @override
  List<ThreadFeedModel> items = [];

  @override
  ViewState viewState = ViewState.loading;

  bool get isUserLoggedIn => observer != null && observer!.isNotEmpty;

  @override
  Future<void> init() async {
    if (!isUserLoggedIn) {
      viewState = ViewState.empty;
      notifyListeners();
      return;
    }
    await _fetchPage();
  }

  Future<void> _fetchPage() async {
    if (!isUserLoggedIn) return;

    final ActionListDataResponse<ThreadFeedModel> response =
        await _repository.getFollowingWaves(
      _container,
      observer!,
      limit: pageLimit,
      lastAuthor: _lastAuthor,
      lastPermlink: _lastPermlink,
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data!;
      if (data.isEmpty) {
        if (items.isEmpty) {
          viewState = ViewState.empty;
        }
        isPageEnded = true;
      } else {
        items = [...items, ...data];
        final last = data.last;
        _lastAuthor = last.author;
        _lastPermlink = last.permlink;
        viewState = ViewState.data;
        if (data.length < pageLimit) {
          isPageEnded = true;
        }
      }
      errorMessage = null;
    } else {
      errorMessage = response.errorMessage.isNotEmpty
          ? response.errorMessage
          : null;
      if (items.isEmpty) {
        viewState = ViewState.error;
      }
      isPageEnded = true;
    }
    notifyListeners();
  }

  @override
  void loadNextPage() async {
    if (isNextPageLoading || isPageEnded || !isUserLoggedIn) return;
    isNextPageLoading = true;
    notifyListeners();
    await _fetchPage();
    isNextPageLoading = false;
    notifyListeners();
  }

  @override
  Future<void> refresh() async {
    _reset();
    if (!isUserLoggedIn) {
      viewState = ViewState.empty;
      notifyListeners();
      return;
    }
    viewState = ViewState.loading;
    notifyListeners();
    await _fetchPage();
  }

  Future<void> updateObserver(String? newObserver) async {
    if (observer == newObserver) return;
    observer = newObserver;
    await refresh();
  }

  void updateThreadType(ThreadFeedType type, {String? container}) {
    final nextContainer = _resolveContainer(type, container: container);
    if (threadType == type && _container == nextContainer) {
      return;
    }

    threadType = type;
    _container = nextContainer;
    refresh();
  }

  void _reset() {
    items = [];
    _lastAuthor = null;
    _lastPermlink = null;
    errorMessage = null;
    isPageEnded = false;
    isNextPageLoading = false;
  }

  static String _resolveContainer(ThreadFeedType type, {String? container}) {
    final candidate = (container ?? Thread.getThreadAccountName(type: type)).trim();
    if (candidate.isEmpty || candidate.toLowerCase() == 'all') {
      return Thread.getThreadAccountName(type: ThreadFeedType.ecency);
    }
    return candidate;
  }
}
