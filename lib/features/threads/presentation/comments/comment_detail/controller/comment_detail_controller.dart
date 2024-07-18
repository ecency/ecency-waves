import 'package:flutter/material.dart';
import 'package:waves/core/dependency_injection/dependency_injection.dart';
import 'package:waves/core/models/action_response.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/core/utilities/generics/classes/thread.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';
import 'package:waves/features/threads/repository/thread_repository.dart';

class CommentDetailController extends ChangeNotifier {
  final ThreadRepository _repository = getIt<ThreadRepository>();

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

  void _init() async {
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
    _init();
  }

  void onCommentAdded(ThreadFeedModel thread) {
    mainThread = mainThread.copyWith(children: mainThread.children! + 1);
    items = [thread, ...items];
    if (viewState == ViewState.empty) {
      viewState = ViewState.data;
    }
    notifyListeners();
  }
}
