import 'package:flutter/material.dart';
import 'package:waves/core/dependency_injection/dependency_injection.dart';
import 'package:waves/core/models/action_response.dart';
import 'package:waves/core/services/moderation_service.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/core/utilities/generics/classes/thread.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';
import 'package:waves/features/threads/repository/thread_repository.dart';

class CommentDetailController extends ChangeNotifier {
  final ThreadRepository _repository = getIt<ThreadRepository>();
  final ModerationService _moderationService = getIt<ModerationService>();

  final String author;
  final String permlink;
  final String? observer;
  ThreadFeedModel mainThread;

  List<ThreadFeedModel> items = [];
  ViewState viewState = ViewState.loading;

  CommentDetailController({required this.mainThread, required this.observer})
      : author = mainThread.author,
        permlink = mainThread.permlink {
    _init();
  }

  Set<String> _mutedAuthors = const <String>{};
  bool _hasLoadedMutedAuthors = false;
  bool _shouldForceMutedRefresh = true;

  Future<void> _init() async {
    await _loadMutedAuthors(forceRefresh: _shouldForceMutedRefresh);
    _shouldForceMutedRefresh = false;

    ActionListDataResponse<ThreadFeedModel> response =
        await _repository.getcomments(author, permlink, observer);
    if (response.isSuccess) {
      if (response.data!.isNotEmpty) {
        List<ThreadFeedModel>? thread = response.data!
            .where((e) => e.author == author && e.permlink == permlink)
            .toList();
        if (thread.isNotEmpty) {
          mainThread = thread.first;
          response.data!.remove(thread.first);
        }
        items = response.data!;
        items = Thread.filterTopLevelComments(permlink,
            items: items, depth: mainThread.depth + 1);
        items = Thread.filterInvisibleContent(
          items,
          mutedAuthors: _mutedAuthors,
        );
        if (items.isNotEmpty) {
          viewState = ViewState.data;
        } else {
          viewState = ViewState.empty;
        }
      } else {
        viewState = ViewState.empty;
      }
    } else {
      viewState = ViewState.error;
    }
    notifyListeners();
  }

  void refresh() {
    viewState = ViewState.loading;
    notifyListeners();
    _hasLoadedMutedAuthors = false;
    _shouldForceMutedRefresh = true;
    _init();
  }

  void onCommentAdded(ThreadFeedModel thread) {
    mainThread = mainThread.copyWith(children: mainThread.children! + 1);
    final visibleItems = Thread.filterInvisibleContent(
      [thread],
      mutedAuthors: _mutedAuthors,
    );
    if (visibleItems.isEmpty) {
      notifyListeners();
      return;
    }
    items = [visibleItems.first, ...items];
    if (viewState == ViewState.empty) {
      viewState = ViewState.data;
    }
    notifyListeners();
  }

  void onCommentUpdated(ThreadFeedModel thread) {
    if (thread.author == mainThread.author &&
        thread.permlink == mainThread.permlink) {
      mainThread = thread;
      notifyListeners();
      return;
    }

    final index =
        items.indexWhere((e) => e.author == thread.author && e.permlink == thread.permlink);
    if (index != -1) {
      final updatedItems = [...items];
      updatedItems[index] = thread;
      items = updatedItems;
      notifyListeners();
    }
  }

  Future<Set<String>> _loadMutedAuthors({bool forceRefresh = false}) async {
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
