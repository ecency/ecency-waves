import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/auth/models/hive_auth_model.dart';
import 'package:waves/features/auth/models/hive_signer_auth_model.dart';
import 'package:waves/features/auth/models/posting_auth_model.dart';
import 'package:waves/features/auth/models/user_auth_model.dart';

class UserLocalService {
  static const String _currentUserAccountStorageKey = 'currentUserAccount';
  static const String _allUserAccountsStorageKey = 'allUserAccounts';
  static const String _termsAcceptedFlagKey = 'termsAcceptedFlag';
  static const String _termsAcceptanceGateKey = 'termsAcceptanceGate';
  static const String _deletedAccountsKey = 'deletedAccounts';

  final FlutterSecureStorage _secureStorage;
  final GetStorage _getStorage;

  UserLocalService(
      {required FlutterSecureStorage secureStorage,
      required final GetStorage getStorage})
      : _secureStorage = secureStorage,
        _getStorage = getStorage;

  Future<void> cleanup() async {
    await _secureStorage.delete(key: _currentUserAccountStorageKey);
    await _secureStorage.delete(key: _allUserAccountsStorageKey);
  }

  Future<UserAuthModel?> readCurrentUser() async {
    String? jsonString =
        await _secureStorage.read(key: _currentUserAccountStorageKey);
    if (jsonString != null) {
      AuthType type = UserAuthModel.authTypeFromJsonString(jsonString);
      if (type == AuthType.hiveAuth || type == AuthType.hiveKeyChain) {
        return UserAuthModel<HiveAuthModel>.fromJsonString(jsonString);
      } else if (type == AuthType.postingKey || type == AuthType.ecency) {
        return UserAuthModel<PostingAuthModel>.fromJsonString(jsonString);
      } else {
        return UserAuthModel<HiveSignerAuthModel>.fromJsonString(jsonString);
      }
    }
    return null;
  }

  Future<void> writeCurrentUser(UserAuthModel user) async {
    await _secureStorage.write(
        key: _currentUserAccountStorageKey, value: user.toJsonString());
  }

  Future<List<UserAuthModel>> readAllUserAccounts(
      String? currentUserName) async {
    String? userJsonData =
        await _secureStorage.read(key: _allUserAccountsStorageKey);
    if (userJsonData != null) {
      List jsonStringList = UserAuthModel.fromRawJsonList(userJsonData);
      List<UserAuthModel> data = jsonStringList.map((element) {
        AuthType type = UserAuthModel.authTypeFromMap(element);
        if (type == AuthType.hiveAuth || type == AuthType.hiveKeyChain) {
          return UserAuthModel<HiveAuthModel>.fromJson(element);
        } else if (type == AuthType.postingKey || type == AuthType.ecency) {
          return UserAuthModel<PostingAuthModel>.fromJson(element);
        } else {
          return UserAuthModel<HiveSignerAuthModel>.fromJson(element);
        }
      }).toList();
      if (data.isNotEmpty && currentUserName != null) {
        _sortCurrentUserToTop(data, currentUserName);
      }
      return data;
    }
    return [];
  }

  void _sortCurrentUserToTop(List<UserAuthModel> data, String currentUserName) {
    final int index =
        data.indexWhere((element) => element.accountName == currentUserName);
    if (index <= 0) {
      // Either the account is already first or it does not exist in the list.
      return;
    }

    final UserAuthModel currentUser = data.removeAt(index);
    data.insert(0, currentUser);
  }

  Future<void> writeAllUserAccounts(List<UserAuthModel> accounts) async {
    await _secureStorage.write(
        key: _allUserAccountsStorageKey,
        value: UserAuthModel.toRawJsonList(accounts));
  }

  Future<void> logOut() async {
    await _secureStorage.delete(key: _currentUserAccountStorageKey);
  }

  Future<void> writeTermsAcceptedFlag(bool status) async {
    await _getStorage.write(_termsAcceptedFlagKey, status);
  }

  bool readTermsAcceptedFlag() {
    bool? data = _getStorage.read(_termsAcceptedFlagKey);
    return data ?? false;
  }

  Future<void> writeTermsAcceptanceGateVersion(String gateVersion) async {
    await _getStorage.write(_termsAcceptanceGateKey, gateVersion);
  }

  String? readTermsAcceptanceGateVersion() {
    return _getStorage.read<String>(_termsAcceptanceGateKey);
  }

  List<String> readDeletedAccounts() {
    String? data = _getStorage.read(_deletedAccountsKey);
    if (data != null) {
      return List<String>.from(json.decode(data));
    }
    return [];
  }

  Future<void> writeDeleteAccount(String accountName) async {
    List<String> deletedAccounts = [...readDeletedAccounts(), accountName];
    await _getStorage.write(_deletedAccountsKey, json.encode(deletedAccounts));
  }
}
