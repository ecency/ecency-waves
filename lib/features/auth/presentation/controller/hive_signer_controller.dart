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
    final Uri? uri = Uri.tryParse(url);
    if (uri == null) {
      return null;
    }

    final String scheme = uri.scheme.toLowerCase();
    final String host = uri.host.toLowerCase();
    final bool isLegacyCallback =
        scheme == 'https' && host == 'example.com' && uri.path.contains('callback');
    final bool isAppLinkCallback =
        scheme == 'waves' && host == 'hivesigner-auth';

    if (!isLegacyCallback && !isAppLinkCallback) {
      return null;
    }

    final Map<String, String> parameters = {
      ...uri.queryParameters,
    };

    if ((parameters['access_token'] == null ||
            parameters['username'] == null) &&
        uri.fragment.isNotEmpty) {
      parameters.addAll(Uri.splitQueryString(uri.fragment));
    }

    final String? token = parameters['access_token'];
    final String? username = parameters['username'];

    if (token != null && token.isNotEmpty && username != null && username.isNotEmpty) {
      return HiveSignerHelperModel(username: username, token: token);
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
