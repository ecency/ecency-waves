import 'package:flutter/material.dart';
import 'package:waves/core/dependency_injection/dependency_injection.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/explore/models/trending_author_model.dart';
import 'package:waves/features/explore/models/trending_tag_model.dart';
import 'package:waves/features/explore/repository/explore_repository.dart';
import 'package:waves/features/settings/repository/settings_repository.dart';

class ExploreController extends ChangeNotifier {
  ExploreController()
      : threadType = getIt<SettingsRepository>().readDefaultThread() {
    _applyCachedState();
    if (!_tagCache.containsKey(threadType)) {
      _loadTags();
    }
  }

  final ExploreRepository _repository = getIt<ExploreRepository>();

  static final Map<ThreadFeedType, _CachedExploreResult<TrendingTagModel>>
      _tagCache = {};
  static final Map<ThreadFeedType, _CachedExploreResult<TrendingAuthorModel>>
      _authorCache = {};

  ThreadFeedType threadType;
  ViewState tagsState = ViewState.loading;
  ViewState authorsState = ViewState.loading;

  List<TrendingTagModel> tags = const <TrendingTagModel>[];
  List<TrendingAuthorModel> authors = const <TrendingAuthorModel>[];

  bool _isLoadingTags = false;
  bool _isLoadingAuthors = false;

  void _applyCachedState() {
    final cachedTags = _tagCache[threadType];
    if (cachedTags != null) {
      tags = cachedTags.data;
      tagsState = cachedTags.state;
    } else {
      tags = const <TrendingTagModel>[];
      tagsState = ViewState.loading;
    }

    final cachedAuthors = _authorCache[threadType];
    if (cachedAuthors != null) {
      authors = cachedAuthors.data;
      authorsState = cachedAuthors.state;
    } else {
      authors = const <TrendingAuthorModel>[];
      authorsState = ViewState.loading;
    }
  }

  Future<void> _loadTags({bool forceRefresh = false}) async {
    if (_isLoadingTags) return;

    final currentType = threadType;
    if (!forceRefresh) {
      final cached = _tagCache[currentType];
      if (cached != null) {
        final previousState = tagsState;
        final previousTags = tags;
        tags = cached.data;
        tagsState = cached.state;
        if (!identical(previousTags, tags) || previousState != tagsState) {
          notifyListeners();
        }
        return;
      }
    } else {
      _tagCache.remove(currentType);
    }

    _isLoadingTags = true;
    tagsState = ViewState.loading;
    notifyListeners();

    try {
      final container = _getContainer(currentType);
      final tagRes = await _repository.getTrendingTags(container);

      if (threadType != currentType) {
        return;
      }

      if (tagRes.isSuccess && tagRes.data != null) {
        final list = tagRes.data!;
        if (list.isEmpty) {
          tags = const <TrendingTagModel>[];
          tagsState = ViewState.empty;
          _tagCache[currentType] = _CachedExploreResult<TrendingTagModel>(
            data: const <TrendingTagModel>[],
            state: ViewState.empty,
          );
        } else {
          final immutableList =
              List<TrendingTagModel>.unmodifiable(List.of(list));
          tags = immutableList;
          tagsState = ViewState.data;
          _tagCache[currentType] = _CachedExploreResult<TrendingTagModel>(
            data: immutableList,
            state: ViewState.data,
          );
        }
      } else {
        tags = const <TrendingTagModel>[];
        tagsState = ViewState.error;
      }
    } finally {
      _isLoadingTags = false;
      if (threadType == currentType) {
        notifyListeners();
      }
    }
  }

  Future<void> loadAuthorsIfNeeded({bool forceRefresh = false}) async {
    if (_isLoadingAuthors) return;

    final currentType = threadType;
    if (!forceRefresh) {
      final cached = _authorCache[currentType];
      if (cached != null) {
        final previousState = authorsState;
        final previousAuthors = authors;
        authors = cached.data;
        authorsState = cached.state;
        if (!identical(previousAuthors, authors) ||
            previousState != authorsState) {
          notifyListeners();
        }
        return;
      }
    } else {
      _authorCache.remove(currentType);
    }

    _isLoadingAuthors = true;
    authorsState = ViewState.loading;
    notifyListeners();

    try {
      final container = _getContainer(currentType);
      final authorRes = await _repository.getTrendingAuthors(container);

      if (threadType != currentType) {
        return;
      }

      if (authorRes.isSuccess && authorRes.data != null) {
        final list = authorRes.data!;
        if (list.isEmpty) {
          authors = const <TrendingAuthorModel>[];
          authorsState = ViewState.empty;
          _authorCache[currentType] =
              const _CachedExploreResult<TrendingAuthorModel>(
            data: <TrendingAuthorModel>[],
            state: ViewState.empty,
          );
        } else {
          final immutableList =
              List<TrendingAuthorModel>.unmodifiable(List.of(list));
          authors = immutableList;
          authorsState = ViewState.data;
          _authorCache[currentType] = _CachedExploreResult<TrendingAuthorModel>(
            data: immutableList,
            state: ViewState.data,
          );
        }
      } else {
        authors = const <TrendingAuthorModel>[];
        authorsState = ViewState.error;
      }
    } finally {
      _isLoadingAuthors = false;
      if (threadType == currentType) {
        notifyListeners();
      }
    }
  }

  void onChangeThreadType(ThreadFeedType type) {
    if (threadType == type) {
      return;
    }

    threadType = type;
    _applyCachedState();
    notifyListeners();

    if (!_tagCache.containsKey(threadType)) {
      _loadTags();
    }
  }

  String _getContainer(ThreadFeedType type) {
    switch (type) {
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

class _CachedExploreResult<T> {
  const _CachedExploreResult({required this.data, required this.state});

  final List<T> data;
  final ViewState state;
}
