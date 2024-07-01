import 'package:flutter/material.dart';
import 'package:waves/core/dependency_injection/dependency_injection.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/models/action_response.dart';
import 'package:waves/core/models/broadcast_model.dart';
import 'package:waves/core/utilities/act.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/auth/models/hive_signer_auth_model.dart';
import 'package:waves/features/auth/models/user_auth_model.dart';
import 'package:waves/features/threads/repository/thread_repository.dart';

class SignTransactionHiveSignerController {
  final ThreadRepository _threadRepository = getIt<ThreadRepository>();

  Future<void> initCommentProcess(
    String comment, {
    required String parentAuthor,
    required String parentPermlink,
    required UserAuthModel<HiveSignerAuthModel> authData,
    required Function(String) onSuccess,
    required VoidCallback onFailure,
    required Function(String) showToast,
  }) async {
    String generatedPermlink = Act.generatePermlink(authData.accountName);
    ActionSingleDataResponse commentResponse =
        await _threadRepository.commentUsingHiveSigner(
      authData.accountName,
      BroadcastModel(
        type: BroadCastType.comment,
        data: CommentBroadCastModel(
            parentAuthor: parentAuthor,
            parentPermlink: parentPermlink,
            username: authData.accountName,
            permlink: generatedPermlink,
            comment: comment),
      ),
    );
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
    required UserAuthModel<HiveSignerAuthModel> authdata,
    required VoidCallback onSuccess,
    required Function(String) showToast,
  }) async {
    ActionSingleDataResponse response =
        await _threadRepository.voteUsingHiveSigner(
      authdata.auth.token,
      BroadcastModel(
          type: BroadCastType.vote,
          data: VoteBroadCastModel(
              voter: authdata.accountName,
              author: author,
              permlink: permlink,
              weight: weight)),
    );
    if (response.isSuccess) {
      showToast(LocaleText.smVoteSuccessMessage);
      onSuccess();
    } else {
      showToast(LocaleText.emVoteFailureMessage);
    }
  }
}
