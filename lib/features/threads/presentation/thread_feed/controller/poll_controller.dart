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
      ActionSingleDataResponse<PollModel> response =
          await fetchPoll(author, permlink);
      if (response.isSuccess && response.data != null) {
        String pollKey = _getLocalPollKey(author, permlink);
        PollModel? data = response.data;
        if (data != null) {
          _pollMap[pollKey] = data;
        }
      }
    } catch (error) {
      _errorMessage = 'Error: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> castVote(
      String author, String permlink, List<int> selection) async {
    print("cast vote for $author $permlink using choice $selection");

    String pollKey = _getLocalPollKey(author, permlink);
    PollModel? poll = _pollMap[pollKey];

    if (userData == null) {
      return false;
    }

    if (poll == null) {
      return false;
    }

    bool status = await Future.delayed(const Duration(seconds: 2), () => true);

    if (status) {
      //TOOD: update poll model with update vote
      poll.injectPollVoteCache(userData!.accountName, selection);
      notifyListeners();
    }
    return status;
  }

  List<int> userVotedIds(String author, String permlink) =>
      _pollMap[_getLocalPollKey(author, permlink)]
          ?.userVotedIds(userData!.accountName) ??
      [];

  PollModel? getPollData(String author, String permlink) =>
      _pollMap[_getLocalPollKey(author, permlink)];

  _getLocalPollKey(String author, String permlink) {
    return "$author/$permlink";
  }
}
