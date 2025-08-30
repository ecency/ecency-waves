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

  Future<void> initCommentProcess(String comment,
      {required String parentAuthor,
      required String parentPermlink,
      required UserAuthModel<HiveSignerAuthModel> authData,
      required Function(String) onSuccess,
      required VoidCallback onFailure,
      required Function(String) showToast,
      required List<String> imageLinks}) async {
    try {
      String generatedPermlink = Act.generatePermlink(authData.accountName);
      String commentWithImages = Act.commentWithImages(comment, imageLinks);
      ActionSingleDataResponse commentResponse = await _threadRepository
          .broadcastTransactionUsingHiveSigner<CommentBroadCastModel>(
        authData.auth.token,
        BroadcastModel(
          type: BroadCastType.comment,
          data: CommentBroadCastModel(
              parentAuthor: parentAuthor,
              parentPermlink: parentPermlink,
              username: authData.accountName,
              permlink: generatedPermlink,
              comment: commentWithImages),
        ),
      );
      if (commentResponse.isSuccess) {
        showToast(
          commentResponse.errorMessage.isNotEmpty
              ? commentResponse.errorMessage
              : LocaleText.smCommentPublishMessage,
        );
        onSuccess(generatedPermlink);
      } else {
        showToast(
          commentResponse.errorMessage.isNotEmpty
              ? commentResponse.errorMessage
              : LocaleText.emCommentDeclineMessage,
        );
        onFailure();
      }
    } catch (e) {
      showToast(e.toString());
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
    ActionSingleDataResponse response = await _threadRepository
        .broadcastTransactionUsingHiveSigner<VoteBroadCastModel>(
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

  Future<void> initPollVoteProcess({
    required String pollId,
    required List<int> choices,
    required UserAuthModel<HiveSignerAuthModel> authdata,
    required VoidCallback onSuccess,
    required Function(String) showToast,
  }) async {
    ActionSingleDataResponse response = await _threadRepository
        .broadcastTransactionUsingHiveSigner<PollVoteBroadcastModel>(
      authdata.auth.token,
      BroadcastModel(
          type: BroadCastType.vote,
          data: PollVoteBroadcastModel(
            username: authdata.accountName,
            pollId: pollId,
            choices: choices,
          )),
    );
    if (response.isSuccess) {
      showToast(LocaleText.smVoteSuccessMessage);
      onSuccess();
    } else {
      showToast(LocaleText.emVoteFailureMessage);
    }
  }

  Future<void> initMuteProcess({
    required String author,
    required UserAuthModel<HiveSignerAuthModel> authdata,
    required VoidCallback onSuccess,
    required VoidCallback onFailure,
    required Function(String) showToast,
  }) async {
    ActionSingleDataResponse response = await _threadRepository
        .broadcastTransactionUsingHiveSigner<MuteBroadcastModel>(
      authdata.auth.token,
      BroadcastModel(
        type: BroadCastType.custom_json,
        data: MuteBroadcastModel(
          username: authdata.accountName,
          author: author,
        ),
      ),
    );
    if (response.isSuccess) {
      showToast("User is muted successfully");
      onSuccess();
    } else {
      showToast("Mute operation is failed");
      onFailure();
    }
  }
}
