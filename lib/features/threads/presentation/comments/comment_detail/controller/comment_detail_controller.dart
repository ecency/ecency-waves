import 'package:flutter/material.dart';
import 'package:waves/core/dependency_injection/dependency_injection.dart';
import 'package:waves/core/models/action_response.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';
import 'package:waves/features/threads/repository/thread_repository.dart';

class CommentDetailController extends ChangeNotifier {
  final ThreadRepository _repository = getIt<ThreadRepository>();

  final String author;
  final String permlink;
  ThreadFeedModel mainThread;

  List<ThreadFeedModel> items = [];
  ViewState viewState = ViewState.loading;

  CommentDetailController({
    required this.mainThread,
  })  : author = mainThread.author,
        permlink = mainThread.permlink {
    _init();
  }

  void _init() async {
    ActionListDataResponse<ThreadFeedModel> response =
        await _repository.getcomments(author, permlink);
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
        items = refactorComments(items, permlink);
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

  List<ThreadFeedModel> refactorComments(
      List<ThreadFeedModel> content, String parentPermlink) {
    List<ThreadFeedModel> refactoredComments = [];
    var newContent = List<ThreadFeedModel>.from(content);
    for (var e in newContent) {
      e = e.copyWith(visited: false);
    }
    ThreadFeedModel.sortList(newContent);
    refactoredComments.addAll(
        newContent.where((e) => e.parentPermlink == parentPermlink).toList());
    while (refactoredComments.where((e) => e.visited == false).isNotEmpty) {
      var firstComment =
          refactoredComments.where((e) => e.visited == false).first;
      var indexOfFirstElement = refactoredComments.indexOf(firstComment);
      if (firstComment.children != 0) {
        List<ThreadFeedModel> children = newContent
            .where((e) => e.parentPermlink == firstComment.permlink)
            .toList();
        children.sort((a, b) {
          var aTime = b.created;
          var bTime = a.created;
          if (aTime.isAfter(bTime)) {
            return -1;
          } else if (bTime.isAfter(aTime)) {
            return 1;
          } else {
            return 0;
          }
        });
        refactoredComments.insertAll(indexOfFirstElement + 1, children);
      }
      int index =
          refactoredComments.indexWhere((element) => element == firstComment);
      refactoredComments[index] = firstComment.copyWith(visited: true);
    }
    return refactoredComments;
  }

  void onCommentAdded(ThreadFeedModel thread) {
    mainThread = mainThread.copyWith(children: mainThread.children! + 1);
    items = [...items, thread];
    items = refactorComments(items, permlink);
    if (viewState == ViewState.empty) {
      viewState = ViewState.data;
    }
    notifyListeners();
  }
}
