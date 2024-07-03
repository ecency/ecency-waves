import 'package:flutter/material.dart';
import 'package:waves/core/dependency_injection/dependency_injection.dart';
import 'package:waves/core/models/action_response.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/user/models/follow_count_model.dart';
import 'package:waves/features/user/models/user_model.dart';
import 'package:waves/features/user/repository/user_repository.dart';

class UserProfileController extends ChangeNotifier {
  final UserRepository _userRepository = getIt<UserRepository>();
  final String accountName;
  UserModel? data;
  ViewState viewState = ViewState.loading;

  UserProfileController({required this.accountName}) {
    _init();
  }

  void _init() async {
    ActionSingleDataResponse<UserModel> response =
        await _userRepository.getAccountInfo(accountName);
    if (response.isSuccess && response.data != null) {
      viewState = ViewState.data;
      data = response.data;
    } else {
      viewState = ViewState.error;
    }
    notifyListeners();
  }

  Future<FollowCountModel> getFollowCount() async {
    ActionSingleDataResponse<FollowCountModel> response =
        await _userRepository.getFollowCount(accountName);
    if (response.isSuccess) {
      return response.data!;
    } else {
      return FollowCountModel(followerCount: 0, followingCount: 0);
    }
  }

  void refresh() {
    viewState = ViewState.loading;
    notifyListeners();
    _init();
  }
}