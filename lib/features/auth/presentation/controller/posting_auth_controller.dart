import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:waves/core/dependency_injection/dependency_injection.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/models/action_response.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/auth/models/posting_auth_model.dart';
import 'package:waves/features/auth/models/user_auth_model.dart';
import 'package:waves/features/auth/repository/auth_repository.dart';
import 'package:waves/features/user/mixins/multi_account_mixin.dart';
import 'package:waves/features/user/repository/user_local_repository.dart';

class PostingAuthController extends ChangeNotifier {
  final AuthRepository _authRepository = getIt<AuthRepository>();
  final UserLocalRepository _userLocalRepository = getIt<UserLocalRepository>();
  final StreamController<UserAuthModel?> _userStreamController =
      getIt<StreamController<UserAuthModel?>>();

  Future<void> validatePostingKey(String accountName,
      {required Function(String) showToast,
      required String postingKey,
      required VoidCallback onSuccess,
      required VoidCallback showLoader,
      required VoidCallback hideLoader}) async {
    showLoader();
    ActionSingleDataResponse response =
        await _authRepository.validatePostingKey(accountName, postingKey);
    ActionSingleDataResponse<String> proofResponse = await _authRepository
        .getImageUploadProofWithPostingKey(accountName, postingKey);
    if (response.isSuccess && proofResponse.isSuccess) {
      await _saveToLocal(accountName, postingKey, proofResponse.data!);
      showToast(LocaleText.smPostingLoginMessage);
      hideLoader();
      onSuccess();
    } else {
      showToast(response.errorMessage);
      hideLoader();
    }
  }

  Future<void> _saveToLocal(
      String accountName, String postingKey, String token) async {
    UserAuthModel<PostingAuthModel> data = UserAuthModel(
        accountName: accountName,
        authType: AuthType.postingKey,
        imageUploadToken: token,
        auth: PostingAuthModel(postingKey: postingKey,));
    await Future.wait([
      _userLocalRepository.writeCurrentUser(data),
      MultiAccountProvider().addUserAccount(data)
    ]);
    _userStreamController.add(data);
  }
}
