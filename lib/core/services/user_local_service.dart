import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/auth/models/hive_auth_model.dart';
import 'package:waves/features/auth/models/posting_auth_model.dart';
import 'package:waves/features/auth/models/user_auth_model.dart';

class UserLocalService {
  static const String _currentUserAccountStorageKey = 'currentUserAccount';
  static const String _allUserAccountsStorageKey = 'allUserAccounts';
  final FlutterSecureStorage _secureStorage;

  UserLocalService({required FlutterSecureStorage secureStorage})
      : _secureStorage = secureStorage;

  Future<UserAuthModel?> readCurrentUser() async {
    String? jsonString =
        await _secureStorage.read(key: _currentUserAccountStorageKey);
    if (jsonString != null) {
      AuthType type = UserAuthModel.authTypeFromJsonString(jsonString);
      if (type == AuthType.hiveAuth || type == AuthType.hiveKeyChain) {
        return UserAuthModel<HiveAuthModel>.fromJsonString(jsonString);
      } else {
        return UserAuthModel<PostingAuthModel>.fromJsonString(jsonString);
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
      List jsonStringList =
          UserAuthModel.fromRawJsonList(userJsonData);
      List<UserAuthModel> data = jsonStringList.map((element) {
        AuthType type = UserAuthModel.authTypeFromMap(element);
        if (type == AuthType.hiveAuth || type == AuthType.hiveKeyChain) {
          return UserAuthModel<HiveAuthModel>.fromJson(element);
        } else {
          return UserAuthModel<PostingAuthModel>.fromJson(element);
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
    UserAuthModel currentUser =
        data.firstWhere((element) => element.accountName == currentUserName);
    data.removeWhere((element) => element.accountName == currentUserName);
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
}
