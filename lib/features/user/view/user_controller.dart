import 'dart:async';

import 'package:flutter/material.dart';
import 'package:waves/core/dependency_injection/dependency_injection.dart';
import 'package:waves/features/auth/models/user_auth_model.dart';
import 'package:waves/features/user/mixins/multi_account_mixin.dart';
import 'package:waves/features/user/repository/user_local_repository.dart';

class UserController extends ChangeNotifier {
  UserAuthModel? userData;
  final UserLocalRepository _localRepository = getIt<UserLocalRepository>();
  final StreamController<UserAuthModel?> _userSteamController =
      getIt<StreamController<UserAuthModel?>>();
  Stream<UserAuthModel?> get stream => _userSteamController.stream;
  late final StreamSubscription<UserAuthModel?> _userAuthSubscription;

  UserController() {
    _init();
  }

  void _init() async {
    _readUserFromLocal();
    _userAuthSubscription = stream.listen((event) {});
    _userAuthSubscription.onData((data) {
      userData = data;
      notifyListeners();
    });
  }

  bool get isUserLoggedIn {
    return userData != null;
  }

  String? get userName {
    return userData?.accountName;
  }

  String get imageUploadToken {
    return userData!.imageUploadToken;
  }

  bool isAccountDeleted(String accountName) {
    return _localRepository.isAccountDeleted(accountName);
  }

  Future<void> _readUserFromLocal() async {
    userData = await _localRepository.readCurrentUser();
    if (userData != null) notifyListeners();
  }

  Future<void> logOutUser() async {
    if (userData == null) {
      return;
    }

    final String currentAccountName = userData!.accountName;
    final List<UserAuthModel> allAccounts =
        await _localRepository.readAllUserAccounts(
            currentUserName: currentAccountName);

    final List<UserAuthModel> remainingAccounts =
        List<UserAuthModel>.from(allAccounts)
          ..removeWhere((element) => element.accountName == currentAccountName);

    if (remainingAccounts.isEmpty) {
      await Future.wait([
        _localRepository.logOut(),
        MultiAccountProvider()
            .onRemove(currentAccountName, allAccounts: allAccounts)
      ]);
      userData = null;
      _userSteamController.add(null);
      notifyListeners();
      return;
    }

    await MultiAccountProvider()
        .onRemove(currentAccountName, allAccounts: allAccounts);

    final UserAuthModel nextAccount = remainingAccounts.first;
    await _localRepository.writeCurrentUser(nextAccount);
    userData = nextAccount;
    _userSteamController.add(nextAccount);
    notifyListeners();
  }

  bool getTermsAcceptedFlag() {
    return _localRepository.readTermsAcceptedFlag();
  }

  void setTermsAcceptedFlag(bool status) async {
    await _localRepository.writeTermsAcceptedFlag(status);
  }

  @override
  void dispose() {
    _userAuthSubscription.cancel();
    _userSteamController.close();
    super.dispose();
  }
}
