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

  Future<void> _readUserFromLocal() async {
    userData = await _localRepository.readCurrentUser();
    if (userData != null) notifyListeners();
  }

  Future<void> logOutUser() async {
    await Future.wait([
      _localRepository.logOut(),
      MultiAccountProvider().onRemove(userData!.accountName)
    ]);
    _userSteamController.add(null);
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
