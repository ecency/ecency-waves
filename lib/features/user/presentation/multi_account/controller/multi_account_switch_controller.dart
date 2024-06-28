import 'dart:async';

import 'package:flutter/material.dart';
import 'package:waves/core/dependency_injection/dependency_injection.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/auth/models/user_auth_model.dart';
import 'package:waves/features/user/repository/user_local_repository.dart';
import 'package:waves/features/user/mixins/multi_account_mixin.dart';

class MultiAccountController extends ChangeNotifier with MultiAccountMixin {
  final StreamController<UserAuthModel?> _userStreamController =
      getIt<StreamController<UserAuthModel?>>();
  final UserLocalRepository _repository = getIt<UserLocalRepository>();
  List<UserAuthModel> userAccounts = [];

  ViewState viewState = ViewState.loading;

  MultiAccountController({required String currentUserName}) {
    _init(currentUserName);
  }

  void _init(String currentUserName) async {
    userAccounts =
        await _repository.readAllUserAccounts(currentUserName: currentUserName);
    viewState = ViewState.data;
    notifyListeners();
  }

  void onSelect(UserAuthModel data) async {
    await _repository.writeCurrentUser(data);
    _userStreamController.add(data);
  }

  void removeAccount(String accountName) async {
    await super.onRemove(accountName, allAccounts: userAccounts);
    notifyListeners();
  }
}
