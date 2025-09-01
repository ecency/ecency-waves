import 'package:flutter/material.dart';
import 'package:waves/core/dependency_injection/dependency_injection.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/explore/models/trending_author_model.dart';
import 'package:waves/features/explore/models/trending_tag_model.dart';
import 'package:waves/features/explore/repository/explore_repository.dart';

class ExploreController extends ChangeNotifier {
  final ExploreRepository _repository = getIt<ExploreRepository>();

  ThreadFeedType threadType = ThreadFeedType.ecency;
  ViewState tagsState = ViewState.loading;
  ViewState authorsState = ViewState.loading;

  List<TrendingTagModel> tags = [];
  List<TrendingAuthorModel> authors = [];

  ExploreController() {
    loadData();
  }

  Future<void> loadData() async {
    tagsState = ViewState.loading;
    authorsState = ViewState.loading;
    notifyListeners();

    final container = _getContainer();
    final tagRes = await _repository.getTrendingTags(container);
    if (tagRes.isSuccess && tagRes.data != null && tagRes.data!.isNotEmpty) {
      tags = tagRes.data!;
      tagsState = ViewState.data;
    } else {
      tags = [];
      tagsState = ViewState.error;
    }

    final authorRes = await _repository.getTrendingAuthors(container);
    if (authorRes.isSuccess && authorRes.data != null &&
        authorRes.data!.isNotEmpty) {
      authors = authorRes.data!;
      authorsState = ViewState.data;
    } else {
      authors = [];
      authorsState = ViewState.error;
    }
    notifyListeners();
  }

  void onChangeThreadType(ThreadFeedType type) {
    if (threadType != type) {
      threadType = type;
      loadData();
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
