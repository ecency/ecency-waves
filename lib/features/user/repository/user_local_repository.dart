import 'package:waves/core/services/user_local_service.dart';
import 'package:waves/features/auth/models/user_auth_model.dart';

class UserLocalRepository {
  final UserLocalService _localService;

  UserLocalRepository({required UserLocalService localService})
      : _localService = localService;

  Future<UserAuthModel?> readCurrentUser() async {
    return await _localService.readCurrentUser();
  }

  Future<void> writeCurrentUser(UserAuthModel user) async {
    return await _localService.writeCurrentUser(user);
  }

  Future<void> logOut() async {
    return await _localService.logOut();
  }

  Future<List<UserAuthModel>> readAllUserAccounts(
      {String? currentUserName}) async {
    return await _localService.readAllUserAccounts(currentUserName);
  }

  Future<void> writeAllUserAccounts(List<UserAuthModel> accounts) async {
    return await _localService.writeAllUserAccounts(accounts);
  }

  bool readTermsAcceptedFlag() {
    return _localService.readTermsAcceptedFlag();
  }

  Future<void> writeTermsAcceptedFlag(bool status) async {
    return await _localService.writeTermsAcceptedFlag(status);
  }

  Future<void> writeTermsAcceptanceGateVersion(String gateVersion) async {
    return await _localService.writeTermsAcceptanceGateVersion(gateVersion);
  }

  String? readTermsAcceptanceGateVersion() {
    return _localService.readTermsAcceptanceGateVersion();
  }

  List<String> readDeletedAccounts() {
    return _localService.readDeletedAccounts();
  }

  Future<void> writeDeleteAccount(String accountName) async {
    return await _localService.writeDeleteAccount(accountName);
  }

  bool isAccountDeleted(String accountName) {
    return readDeletedAccounts().any((e) => e == accountName);
  }
}
