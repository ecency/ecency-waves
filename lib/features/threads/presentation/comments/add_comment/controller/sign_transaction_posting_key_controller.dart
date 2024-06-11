import 'package:flutter/material.dart';
import 'package:waves/core/dependency_injection/dependency_injection.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/models/action_response.dart';
import 'package:waves/core/utilities/act.dart';
import 'package:waves/features/auth/models/posting_auth_model.dart';
import 'package:waves/features/auth/models/user_auth_model.dart';
import 'package:waves/features/threads/repository/thread_repository.dart';

class SignTransactionPostingKeyController {
  final ThreadRepository _threadRepository = getIt<ThreadRepository>();

  Future<void> initCommentProcess(
    String comment, {
    required String author,
    required String parentPermlink,
    required UserAuthModel<PostingAuthModel> authdata,
    required Function(String) onSuccess,
    required Function(String) showToast,
  }) async {
    String generatedPermlink = Act.generatePermlink(authdata.accountName);
    ActionSingleDataResponse<String> commentResponse =
        await _threadRepository.commentOnContent(authdata.accountName, author,
            parentPermlink,generatedPermlink, comment, authdata.auth.postingKey, null, null);
    if (commentResponse.isSuccess) {
      showToast(LocaleText.smCommentPublishMessage);
      onSuccess(generatedPermlink);
    } else {
      showToast(LocaleText.emCommentDeclineMessage);
    }
  }

  Future<void> initVoteProcess(
    double weight, {
    required String author,
    required String permlink,
    required UserAuthModel<PostingAuthModel> authdata,
    required VoidCallback onSuccess,
    required Function(String) showToast,
  }) async {
    ActionSingleDataResponse<String> commentResponse =
        await _threadRepository.votecontent(authdata.accountName, author,
            permlink, weight, authdata.auth.postingKey, null, null);
    if (commentResponse.isSuccess) {
      showToast(LocaleText.smVoteSuccessMessage);
      onSuccess();
    } else {
      showToast(LocaleText.emVoteFailureMessage);
    }
  }
}
