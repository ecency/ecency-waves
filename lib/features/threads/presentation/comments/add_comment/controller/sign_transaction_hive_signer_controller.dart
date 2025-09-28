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
    required List<String> imageLinks,
    List<String>? baseTags,
    String? metadataApp,
    String? metadataFormat,
    String? existingPermlink,
  }) async {
    try {
      final String generatedPermlink =
          (existingPermlink?.isNotEmpty ?? false)
              ? existingPermlink!
              : Act.generatePermlink(authData.accountName);
      String commentWithImages = Act.commentWithImages(comment, imageLinks);
      final List<String> tags = Act.compileTags(
        comment,
        baseTags: baseTags,
        parentPermlink: parentPermlink,
      );
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
              comment: commentWithImages,
              tags: tags,
              app: metadataApp,
              format: metadataFormat),
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
    int weight, {
    required String author,
    required String permlink,
    required UserAuthModel<HiveSignerAuthModel> authdata,
    required VoidCallback onSuccess,
    required Function(String) showToast,
  }) async {
    final int sanitizedWeight = weight.clamp(-10000, 10000).toInt();
    ActionSingleDataResponse response = await _threadRepository
        .broadcastTransactionUsingHiveSigner<VoteBroadCastModel>(
      authdata.auth.token,
      BroadcastModel(
          type: BroadCastType.vote,
          data: VoteBroadCastModel(
              voter: authdata.accountName,
              author: author,
              permlink: permlink,
              weight: sanitizedWeight)),
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
      showToast("User has been blocked successfully");
      onSuccess();
    } else {
      showToast("Blocking the user failed");
      onFailure();
    }
  }

  Future<void> initFollowProcess({
    required String author,
    required bool follow,
    required UserAuthModel<HiveSignerAuthModel> authdata,
    required VoidCallback onSuccess,
    required VoidCallback onFailure,
    required Function(String) showToast,
  }) async {
    final response = await _threadRepository
        .broadcastTransactionUsingHiveSigner<FollowBroadcastModel>(
      authdata.auth.token,
      BroadcastModel(
        type: BroadCastType.custom_json,
        data: FollowBroadcastModel(
          username: authdata.accountName,
          author: author,
          follow: follow,
        ),
      ),
    );

    if (response.isSuccess) {
      final successMessage = follow
          ? "User followed successfully"
          : "User unfollowed successfully";
      showToast(successMessage);
      onSuccess();
    } else {
      final failureMessage = response.errorMessage.isNotEmpty
          ? response.errorMessage
          : (follow
              ? "Unable to follow user"
              : "Unable to unfollow user");
      showToast(failureMessage);
      onFailure();
    }
  }

  Future<void> initTransferProcess({
    required String recipient,
    required double amount,
    required String assetSymbol,
    required String memo,
    required UserAuthModel<HiveSignerAuthModel> authdata,
    required VoidCallback onSuccess,
    required Function(String) showToast,
  }) async {
    final formattedAmount = amount.toStringAsFixed(3);
    ActionSingleDataResponse response = await _threadRepository
        .broadcastTransactionUsingHiveSigner<TransferBroadcastModel>(
      authdata.auth.token,
      BroadcastModel(
        type: BroadCastType.transfer,
        data: TransferBroadcastModel(
          from: authdata.accountName,
          to: recipient,
          amount: formattedAmount,
          assetSymbol: assetSymbol,
          memo: memo,
        ),
      ),
    );
    if (response.isSuccess) {
      showToast(LocaleText.smTipSuccessMessage);
      onSuccess();
    } else {
      final error = response.errorMessage.isNotEmpty
          ? response.errorMessage
          : LocaleText.emTipFailureMessage;
      showToast(error);
    }
  }
}
