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
    List<String>? baseTags,
    String? existingPermlink,
  }) async {
    try {
      final String generatedPermlink =
          (existingPermlink?.isNotEmpty ?? false)
              ? existingPermlink!
              : Act.generatePermlink(authData.accountName);
      String commentWithImages = Act.commentWithImages(comment, imageLinks);
      List<String> tags = Act.compileTags(
        comment,
        baseTags: baseTags,
        parentPermlink: parentPermlink,
      );
      ActionSingleDataResponse<String> commentResponse =
          await _threadRepository.commentOnContent(
              authData.accountName,
              author,
              parentPermlink,
              generatedPermlink,
              commentWithImages,
              tags,
              authData.auth.postingKey,
              null,
              null);
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
    required UserAuthModel<PostingAuthModel> authdata,
    required VoidCallback onSuccess,
    required Function(String) showToast,
  }) async {
    final int sanitizedWeight = weight.clamp(-10000, 10000).toInt();
    ActionSingleDataResponse<String> commentResponse =
        await _threadRepository.votecontent(authdata.accountName, author,
            permlink, sanitizedWeight, authdata.auth.postingKey, null, null);
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
    required UserAuthModel<PostingAuthModel> authdata,
    required VoidCallback onSuccess,
    required VoidCallback onFailure,
    required Function(String) showToast,
  }) async {
    ActionSingleDataResponse<String> response =
        await _threadRepository.setFollowStatus(
            authdata.accountName,
            author,
            follow,
            authdata.auth.postingKey,
            null,
            null);
    if (response.isSuccess) {
      showToast(follow
          ? "User has been followed successfully"
          : "User has been unfollowed successfully");
      onSuccess();
    } else {
      showToast(follow
          ? "Following the user failed"
          : "Unfollowing the user failed");
      onFailure();
    }
  }

  Future<void> initFollowProcess({
    required String author,
    required bool follow,
    required UserAuthModel<PostingAuthModel> authdata,
    required VoidCallback onSuccess,
    required VoidCallback onFailure,
    required Function(String) showToast,
  }) async {
    ActionSingleDataResponse<String> response =
        await _threadRepository.updateFollowStatus(
            authdata.accountName,
            author,
            follow,
            authdata.auth.postingKey,
            null,
            null);
    if (response.isSuccess) {
      showToast(follow
          ? "User has been followed successfully"
          : "User has been unfollowed successfully");
      onSuccess();
    } else {
      showToast(follow
          ? "Following the user failed"
          : "Unfollowing the user failed");
      onFailure();
    }
  }

  Future<void> initFollowProcess({
    required String author,
    required bool follow,
    required UserAuthModel<PostingAuthModel> authdata,
    required VoidCallback onSuccess,
    required VoidCallback onFailure,
    required Function(String) showToast,
  }) async {
    ActionSingleDataResponse<String> response =
        await _threadRepository.setFollowStatus(
            authdata.accountName,
            author,
            follow,
            authdata.auth.postingKey,
            null,
            null);
    if (response.isSuccess) {
      showToast(follow
          ? "User has been followed successfully"
          : "User has been unfollowed successfully");
      onSuccess();
    } else {
      showToast(follow
          ? "Following the user failed"
          : "Unfollowing the user failed");
      onFailure();
    }
  }

  Future<void> initFollowProcess({
    required String author,
    required bool follow,
    required UserAuthModel<PostingAuthModel> authdata,
    required VoidCallback onSuccess,
    required VoidCallback onFailure,
    required Function(String) showToast,
  }) async {
    final response = await _threadRepository.setFollowStatus(
      authdata.accountName,
      author,
      follow,
      authdata.auth.postingKey,
      null,
      null,
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
}
