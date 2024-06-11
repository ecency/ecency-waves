import 'package:flutter/foundation.dart';
import 'package:waves/core/dependency_injection/dependency_injection.dart';
import 'package:waves/core/models/action_response.dart';
import 'package:waves/core/providers/bookmark_provider.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/core/utilities/generics/controllers/controller_interface.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_bookmark_model.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';
import 'package:waves/features/threads/repository/thread_repository.dart';

class ThreadFeedController extends ChangeNotifier
    implements ControllerInterface<ThreadFeedModel> {
  final ThreadRepository _repository = getIt<ThreadRepository>();
  ThreadFeedType threadType = ThreadFeedType.all;
  final AccountPostType _postType = AccountPostType.posts;
  final BookmarkProvider bookmarkProvider =
      BookmarkProvider<ThreadBookmarkModel>(type: BookmarkType.thread);
  @override
  List<ThreadFeedModel> items = [];

  @override
  ViewState viewState = ViewState.loading;

  ThreadFeedController() {
    init();
  }

  @override
  void init() async {
    if (threadType == ThreadFeedType.all) {
      _loadAllFeedType(threadType);
    } else {
      _loadSingleFeedType(threadType);
    }
  }

  void _loadSingleFeedType(ThreadFeedType type) async {
    ActionSingleDataResponse<ThreadFeedModel> accountPostResponse =
        await _repository.getFirstAccountPost(gethreadName(), _postType, 1);
    if (accountPostResponse.isSuccess) {
      ActionListDataResponse<ThreadFeedModel> response =
          await _repository.getcomments(accountPostResponse.data!.author,
              accountPostResponse.data!.permlink);
      if (response.isSuccess && response.data != null) {
        if (type == threadType) {
          items = response.data!;
          items = filterTopLevelComments(accountPostResponse.data!.permlink);
          if (items.isEmpty) {
            viewState = ViewState.empty;
          } else {
            viewState = ViewState.data;
          }
        }
      } else {
        viewState = ViewState.error;
      }
    } else {
      viewState = ViewState.error;
    }

    notifyListeners();
  }

  void _loadAllFeedType(ThreadFeedType type) async {
    try {
      List<List<ThreadFeedModel>?> totalFeeds = await Future.wait([
        _loadFeed(ThreadFeedType.ecency),
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
          ThreadFeedModel.sortList(singleFeedList);
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
        .getFirstAccountPost(gethreadName(type: type), _postType, 1);
    if (postResponse.isSuccess) {
      ActionListDataResponse<ThreadFeedModel> response = await _repository
          .getcomments(postResponse.data!.author, postResponse.data!.permlink);
      if (response.isSuccess) {
        return filterTopLevelComments(postResponse.data!.permlink,
            items: response.data);
      }
    }
    return null;
  }

  @override
  void loadNextPage() {
    // TODO: implement loadNextPage
  }

  @override
  void refresh() {
    viewState = ViewState.loading;
    notifyListeners();
    init();
  }

  List<ThreadFeedModel> filterTopLevelComments(String parentPermlink,
      {List<ThreadFeedModel>? items}) {
    List<ThreadFeedModel> result = items ?? this.items;
    result = result
        .where((element) =>
            element.depth == 1 && element.parentPermlink == parentPermlink)
        .toList();
    ThreadFeedModel.sortList(result, isAscending: false);
    return result;
  }

  void onTapFilter(ThreadFeedType type) {
    if (threadType != type) {
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

  String gethreadName({ThreadFeedType? type}) {
    switch (type ?? threadType) {
      case ThreadFeedType.ecency:
        return "ecency.waves";
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
