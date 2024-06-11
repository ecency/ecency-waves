import 'package:waves/core/dependency_injection/dependency_injection.dart';
import 'package:waves/features/auth/models/user_auth_model.dart';
import 'package:waves/features/user/repository/user_local_repository.dart';

mixin MultiAccountMixin {
  final UserLocalRepository _repository = getIt<UserLocalRepository>();

  Future<void> addUserAccount(UserAuthModel data) async {
    List<UserAuthModel> allUserAccounts =
        await _repository.readAllUserAccounts();
    if (_isUserAlreadyPresent(allUserAccounts, data)) {
      allUserAccounts
          .removeWhere((element) => element.accountName == data.accountName);
    }
    allUserAccounts.add(data);
    await _repository.writeAllUserAccounts(allUserAccounts);
  }

  bool _isUserAlreadyPresent(List<UserAuthModel> datum, UserAuthModel data) {
    int index = datum.indexWhere((element) {
      return element.accountName == data.accountName;
    });
    return index != -1;
  }
  
  Future<void> onRemove(String accountName, {List<UserAuthModel>? allAccounts}) async {
    List<UserAuthModel> accounts =
        allAccounts ?? await _repository.readAllUserAccounts();
    accounts.removeWhere((element) => element.accountName == accountName);
    await _repository.writeAllUserAccounts(accounts);
  }
}

class MultiAccountProvider with MultiAccountMixin {}
