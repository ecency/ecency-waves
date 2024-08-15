

import 'package:flutter/material.dart';
import 'package:waves/core/models/action_response.dart';
import 'package:waves/core/services/poll_service/poll_api.dart';
import 'package:waves/core/services/poll_service/poll_model.dart';
import 'package:waves/features/auth/models/user_auth_model.dart';

class PollController with ChangeNotifier {
  UserAuthModel? userData;

  bool _isLoading = false;
  final Map<String, PollModel> _pollMap = {};

  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  PollController({required this.userData});

  updateUserData(UserAuthModel? user) {
    userData = user;
  }

  Future<void> fetchPollData(String author, String permlink) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate a network request
      ActionSingleDataResponse<PollModel> response = await fetchPoll(author, permlink);
      if(response.isSuccess && response.data != null){
        String pollKey = _getLocalPollKey(author, permlink);
        _pollMap[pollKey] = response.data!;
      }
    } catch (error) {
      _errorMessage = 'Error: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  PollModel? getPollData(String author, String permlink) => _pollMap[_getLocalPollKey(author, permlink)];

  _getLocalPollKey (String author, String permlink){
    return "$author/$permlink";
  }

}