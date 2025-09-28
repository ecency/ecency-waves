import 'package:flutter/material.dart';
import 'package:waves/core/dependency_injection/dependency_injection.dart';
import 'package:waves/core/models/action_response.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/user/models/follow_user_item_model.dart';
import 'package:waves/features/user/repository/user_repository.dart';

class FollowListController extends ChangeNotifier {
  FollowListController({
    required this.accountName,
    required this.followType,
  }) {
    _loadInitial();
  }

  final String accountName;
  final FollowType followType;
  final UserRepository _userRepository = getIt<UserRepository>();

  ViewState viewState = ViewState.loading;
  final List<FollowUserItemModel> items = [];
  bool isLoadingMore = false;
  bool hasMore = true;
  static const int _pageLimit = 20;
  String? _lastUser;

  Future<void> _loadInitial() async {
    viewState = ViewState.loading;
    hasMore = true;
    _lastUser = null;
    items.clear();
    notifyListeners();

    final response = await _fetch();
    if (response.isSuccess) {
      final data = response.data ?? [];
      if (data.isEmpty) {
        viewState = ViewState.empty;
        hasMore = false;
      } else {
        items.addAll(data);
        _lastUser = items.last.name;
        viewState = ViewState.data;
        if (data.length < _pageLimit) {
          hasMore = false;
        }
      }
    } else {
      viewState = ViewState.error;
    }
    notifyListeners();
  }

  Future<ActionListDataResponse<FollowUserItemModel>> _fetch({
    bool isLoadMore = false,
  }) {
    final start = isLoadMore ? _lastUser : null;
    if (followType == FollowType.followers) {
      return _userRepository.getFollowers(
        accountName,
        start: start,
        limit: _pageLimit,
      );
    } else {
      return _userRepository.getFollowing(
        accountName,
        start: start,
        limit: _pageLimit,
      );
    }
  }

  Future<void> loadMore() async {
    if (!hasMore || isLoadingMore || viewState != ViewState.data) {
      return;
    }
    isLoadingMore = true;
    notifyListeners();

    final response = await _fetch(isLoadMore: true);
    if (response.isSuccess) {
      final data = response.data ?? [];
      if (data.isEmpty) {
        hasMore = false;
      } else {
        items.addAll(data);
        _lastUser = items.last.name;
        if (data.length < _pageLimit) {
          hasMore = false;
        }
      }
    } else {
      hasMore = false;
    }
    isLoadingMore = false;
    notifyListeners();
  }

  Future<void> refresh() => _loadInitial();

  String get title =>
      followType == FollowType.followers ? 'Followers' : 'Following';
}
