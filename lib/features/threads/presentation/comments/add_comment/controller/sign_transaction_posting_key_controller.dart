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
    required UserAuthModel<PostingAuthModel> authData,
    required Function(String) onSuccess,
    required VoidCallback onFailure,
    required Function(String) showToast,
    required List<String> imageLinks,
  }) async {
    String generatedPermlink = Act.generatePermlink(authData.accountName);
    String commentWithImages = Act.commentWithImages(comment, imageLinks);
    ActionSingleDataResponse<String> commentResponse =
        await _threadRepository.commentOnContent(
            authData.accountName,
            author,
            parentPermlink,
            generatedPermlink,
            commentWithImages,
            authData.auth.postingKey,
            null,
            null);
    if (commentResponse.isSuccess) {
      showToast(LocaleText.smCommentPublishMessage);
      onSuccess(generatedPermlink);
    } else {
      showToast(LocaleText.emCommentDeclineMessage);
      onFailure();
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

  Future<void> initPollVoteProcess({
    required String pollId,
    required List<int> choices,
    required UserAuthModel<PostingAuthModel> authdata,
    required VoidCallback onSuccess,
    required Function(String) showToast,
  }) async {

    ActionSingleDataResponse<String> pollVoteResponse =
        await _threadRepository.castPollVote(authdata.accountName, pollId,
            choices, authdata.auth.postingKey, null, null);
    if (pollVoteResponse.isSuccess) {
      showToast(LocaleText.smVoteSuccessMessage);
      onSuccess();
    } else {
      showToast(LocaleText.emVoteFailureMessage);
    }
  }

  Future<void> initMuteProcess({
    required String author,
    required UserAuthModel<PostingAuthModel> authdata,
    required VoidCallback onSuccess,
    required VoidCallback onFailure,
    required Function(String) showToast,
  }) async {
    ActionSingleDataResponse<String> response =
        await _threadRepository.muteUser(
            authdata.accountName, author, authdata.auth.postingKey, null, null);
    if (response.isSuccess) {
      showToast("User is muted successfully");
      onSuccess();
    } else {
      showToast("Mute operation is failed");
      onFailure();
    }
  }
}
