import 'package:waves/features/auth/models/user_auth_model.dart';
import 'package:waves/core/services/user_local_service.dart';

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
}
