import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/models/action_response.dart';
import 'package:waves/core/models/auth_decryption_token_response.dart';
import 'package:waves/core/models/auth_redirection_response.dart';
import 'package:waves/core/models/broadcast_model.dart';
import 'package:waves/core/services/data_service/service.dart'
    if (dart.library.io) 'package:waves/core/services/data_service/mobile_service.dart'
    if (dart.library.html) 'package:waves/core/services/data_service/web_service.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/core/utilities/evaluate.dart';
import 'package:waves/features/threads/models/post_detail/comment_model.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';

class ApiService {
  Future<String> getChainProps() async {
    // var jsCode = "client.database.getChainProperties();";
    var jsCode = "client.database.getDiscussions('hot');";
    String responseJson = await runThisJS_(jsCode);
    return responseJson;
  }

  Future<ActionListDataResponse<ThreadFeedModel>> getComments(
      String accountName, String permlink) async {
    try {
      String jsonString = await runThisJS_(
          "client.hivemind.call('get_discussion', ['$accountName','$permlink']);");
      return ActionListDataResponse<ThreadFeedModel>(
          data: CommentModel.fromRawJson(jsonString),
          status: ResponseStatus.success,
          isSuccess: true,
          errorMessage: "");
    } catch (e) {
      return ActionListDataResponse(
          status: ResponseStatus.failed, errorMessage: e.toString());
    }
  }

  Future<ActionListDataResponse<ThreadFeedModel>> getAccountPosts(
    String accountName,
    AccountPostType type,
    int limit,
    String? lastAuthor,
    String? lastPermlink,
  ) async {
    try {
      String jsonString = await runThisJS_(
          "client.hivemind.getAccountPosts({ account: '$accountName', sort: '${enumToString(type)}', start_author: ${Evaluate.stringOrNull(lastAuthor)}, start_permlink: ${Evaluate.stringOrNull(lastPermlink)}, limit: $limit });");
      ActionListDataResponse<ThreadFeedModel> response =
          ActionListDataResponse.fromJsonString(
              jsonString, (item) => ThreadFeedModel.fromJson(item));
      return response;
    } catch (e) {
      return ActionListDataResponse(
          status: ResponseStatus.failed, errorMessage: e.toString());
    }
  }

  Future<ActionSingleDataResponse<ThreadFeedModel>> getFirstAccountPost(
    String accountName,
    AccountPostType type,
    int limit,
    String? lastAuthor,
    String? lastPermlink,
  ) async {
    try {
      String jsonString = await runThisJS_(
          "client.hivemind.getAccountPosts({ account: '$accountName', sort: '${enumToString(type)}', start_author: ${Evaluate.stringOrNull(lastAuthor)}, start_permlink: ${Evaluate.stringOrNull(lastPermlink)}, limit: $limit });");
      ActionSingleDataResponse<ThreadFeedModel> response =
          ActionSingleDataResponse.fromJsonString(
              parseFromList: true, jsonString, ThreadFeedModel.fromJson);
      return response;
    } catch (e) {
      return ActionSingleDataResponse(
          status: ResponseStatus.failed, errorMessage: e.toString());
    }
  }

  Future<ActionSingleDataResponse<AuthRedirectionResponse>> getRedirectUri(
      String accountName) async {
    try {
      String jsonString = await getRedirectUriDataFromPlatform(accountName);
      ActionSingleDataResponse<AuthRedirectionResponse> response =
          ActionSingleDataResponse.fromJsonString(
              jsonString, AuthRedirectionResponse.fromJson);
      return response;
    } catch (e) {
      return ActionSingleDataResponse(
          status: ResponseStatus.failed, errorMessage: e.toString());
    }
  }

  Future<ActionSingleDataResponse<AuthDecryptionResponse>> getDecryptedHASToken(
      String accountName, String encryptedData, String authKey) async {
    try {
      String jsonString = await getDecryptedHASTokenFromPlatform(
          accountName, encryptedData, authKey);
      ActionSingleDataResponse<AuthDecryptionResponse> response =
          ActionSingleDataResponse.fromJsonString(
              jsonString, AuthDecryptionResponse.fromJson);
      return response;
    } catch (e) {
      return ActionSingleDataResponse(
          status: ResponseStatus.failed, errorMessage: e.toString());
    }
  }

  Future<ActionSingleDataResponse<bool>> validatePostingKey(
      String accountName, String postingKey) async {
    try {
      String jsonString =
          await validatePostingKeyFromPlatform(accountName, postingKey);
      ActionSingleDataResponse<bool> response =
          ActionSingleDataResponse.fromJsonString(jsonString, null);
      return response;
    } catch (e) {
      return ActionSingleDataResponse(
          status: ResponseStatus.failed, errorMessage: e.toString());
    }
  }

  Future<ActionSingleDataResponse<String>> commentOnContent(
    String username,
    String author,
    String parentPermlink,
    String permlink,
    String comment,
    String? postingKey,
    String? authKey,
    String? token,
  ) async {
    try {
      String jsonString = await commentOnContentFromPlatform(username, author,
          parentPermlink, permlink, comment, postingKey, authKey, token);
      ActionSingleDataResponse<String> response =
          ActionSingleDataResponse.fromJsonString(jsonString, null,
              ignoreFromJson: true);
      return response;
    } catch (e) {
      return ActionSingleDataResponse(
          status: ResponseStatus.failed, errorMessage: e.toString());
    }
  }

  Future<ActionSingleDataResponse<String>> voteContent(
    String username,
    String author,
    String permlink,
    double weight,
    String? postingKey,
    String? authKey,
    String? token,
  ) async {
    try {
      String jsonString = await voteContentFromPlatform(
          username, author, permlink, weight, postingKey, authKey, token);
      ActionSingleDataResponse<String> response =
          ActionSingleDataResponse.fromJsonString(jsonString, null,
              ignoreFromJson: true);
      return response;
    } catch (e) {
      return ActionSingleDataResponse(
          status: ResponseStatus.failed, errorMessage: e.toString());
    }
  }

  Future<ActionSingleDataResponse> broadcastTransactionUsingHiveSigner<T>(
      String accessToken, BroadcastModel<T> args) async {
    print(accessToken);
    final url = Uri.parse('https://hivesigner.com/api/broadcast');
    final headers = {
      'Authorization': accessToken,
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final body = json.encode({
      'operations': [
        [
          enumToString(args.type),
          (args.data is VoteBroadCastModel
              ? (args.data as VoteBroadCastModel).toJson()
              : (args.data as CommentBroadCastModel).toJson())
        ]
      ]
    });

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        Map decodedData = json.decode(response.body);
        if (decodedData['error'] == null) {
          return ActionSingleDataResponse(
              data: null,
              errorMessage: "",
              status: ResponseStatus.success,
              isSuccess: true);
        } else {
          return ActionSingleDataResponse(
              data: null,
              errorMessage: decodedData['error'],
              status: ResponseStatus.failed,
              isSuccess: false);
        }
      } else {
        return ActionSingleDataResponse(
            data: null,
            errorMessage: LocaleText.somethingWentWrong,
            status: ResponseStatus.failed,
            isSuccess: false);
      }
    } catch (e) {
      return ActionSingleDataResponse(
          data: null,
          errorMessage: e.toString(),
          status: ResponseStatus.failed,
          isSuccess: false);
    }
  }
}
