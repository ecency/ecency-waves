import 'dart:async';

import 'package:flutter/material.dart';
import 'package:waves/core/dependency_injection/dependency_injection.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/search/models/search_tag_model.dart';
import 'package:waves/features/search/models/search_user_model.dart';
import 'package:waves/features/search/repository/search_repository.dart';
import 'package:waves/features/settings/repository/settings_repository.dart';

class SearchViewController extends ChangeNotifier {
  final SearchRepository _repository = getIt<SearchRepository>();
  final ThreadFeedType threadType =
      getIt<SettingsRepository>().readDefaultThread();

  final TextEditingController queryController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  ViewState usersState = ViewState.empty;
  ViewState tagsState = ViewState.empty;

  List<SearchUserModel> users = [];
  List<SearchTagModel> tags = [];

  String _query = '';
  Timer? _debounce;
  int _requestId = 0;

  SearchViewController() {
    queryController.addListener(() {
      onQueryChanged(queryController.text);
    });
  }

  bool get hasQuery => _query.isNotEmpty;

  void onQueryChanged(String value) {
    final trimmed = value.trim();
    if (trimmed == _query) {
      return;
    }
    _query = trimmed;
    _debounce?.cancel();
    if (_query.isEmpty) {
      _resetResults();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _performSearch(_query);
    });
  }

  Future<void> _performSearch(String query) async {
    final currentId = ++_requestId;
    usersState = ViewState.loading;
    tagsState = ViewState.loading;
    notifyListeners();

    try {
      final usersFuture = _repository.searchUsers(query);
      final tagsFuture = _repository.searchTags(query);

      final usersResponse = await usersFuture;
      final tagsResponse = await tagsFuture;

      if (currentId != _requestId) {
        return;
      }

      if (usersResponse.isSuccess && usersResponse.data != null) {
        users = usersResponse.data!;
        usersState = users.isEmpty ? ViewState.empty : ViewState.data;
      } else {
        users = [];
        usersState = ViewState.error;
      }

      if (tagsResponse.isSuccess && tagsResponse.data != null) {
        tags = tagsResponse.data!
            .where((element) => element.name.isNotEmpty)
            .toList();
        tagsState = tags.isEmpty ? ViewState.empty : ViewState.data;
      } else {
        tags = [];
        tagsState = ViewState.error;
      }
    } catch (_) {
      if (currentId != _requestId) {
        return;
      }
      users = [];
      tags = [];
      usersState = ViewState.error;
      tagsState = ViewState.error;
    }
    notifyListeners();
  }

  void _resetResults() {
    users = [];
    tags = [];
    usersState = ViewState.empty;
    tagsState = ViewState.empty;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    queryController.dispose();
    focusNode.dispose();
    super.dispose();
  }
}
