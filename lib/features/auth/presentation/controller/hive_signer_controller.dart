import 'dart:async';
import 'package:waves/core/dependency_injection/dependency_injection.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/auth/models/hive_signer_auth_model.dart';
import 'package:waves/features/auth/models/hive_signer_helper_model.dart';
import 'package:waves/features/auth/models/user_auth_model.dart';
import 'package:waves/features/user/mixins/multi_account_mixin.dart';
import 'package:waves/features/user/repository/user_local_repository.dart';

class HiveSignerController {
  final UserLocalRepository _userLocalRepository = getIt<UserLocalRepository>();
  final StreamController<UserAuthModel?> _userStreamController =
      getIt<StreamController<UserAuthModel?>>();

  void onLogin(String url,
      {required Function(String) onSuccess,
      required Function(String) onFailure}) {
    HiveSignerHelperModel? data = extractTokenFromUrl(url);
    if (data != null) {
      final username = data.username.toLowerCase();
      if (!_userLocalRepository.isAccountDeleted(username)) {
        _saveToLocal(username, data.token).then((_) => onSuccess(username));
      } else {
        onFailure(LocaleText.theAccountDoesntExist);
      }
    }
  }

  HiveSignerHelperModel? extractTokenFromUrl(String url) {
    if (url.contains("https://example.com/callback")) {
      Uri uri = Uri.parse(url);
      String? token = uri.queryParameters['access_token'];
      String? username = uri.queryParameters['username'];
      print(token);
      if (token != null && username != null) {
        return HiveSignerHelperModel(username: username, token: token);
      }
    }
    return null;
  }

  Future<void> _saveToLocal(String accountName, String token) async {
    UserAuthModel<HiveSignerAuthModel> data = UserAuthModel(
        accountName: accountName.toLowerCase(),
        authType: AuthType.hiveSign,
        imageUploadToken: token,
        auth: HiveSignerAuthModel(token: token));
    await Future.wait([
      _userLocalRepository.writeCurrentUser(data),
      MultiAccountProvider().addUserAccount(data)
    ]);
    _userStreamController.add(data);
  }
}
