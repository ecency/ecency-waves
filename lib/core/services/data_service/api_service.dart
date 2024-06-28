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
import 'package:waves/features/threads/models/post_detail/comment_model.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';
import 'package:waves/features/user/models/follow_count_model.dart';
import 'package:waves/features/user/models/user_model.dart';

class ApiService {
  Future<ActionListDataResponse<ThreadFeedModel>> getComments(
      String accountName, String permlink) async {
    try {
      var url = Uri.parse(
          'https://hivexplorer.com/api/get_discussion?author=$accountName&permlink=$permlink');

      var response = await http.get(
        url,
      );

      if (response.statusCode == 200) {
        return ActionListDataResponse<ThreadFeedModel>(
            data: CommentModel.fromRawJson(response.body),
            status: ResponseStatus.success,
            isSuccess: true,
            errorMessage: "");
      } else {
        return ActionListDataResponse(
            status: ResponseStatus.failed, errorMessage: "Server Error");
      }
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
      http.Response response = await _getAccountPosts(
          type, accountName, lastAuthor, lastPermlink, limit);

      if (response.statusCode == 200) {
        return ActionListDataResponse<ThreadFeedModel>(
            data: ThreadFeedModel.fromRawJson(response.body),
            status: ResponseStatus.success,
            isSuccess: true,
            errorMessage: "");
      } else {
        return ActionListDataResponse(
            status: ResponseStatus.failed, errorMessage: "Server Error");
      }
    } catch (e) {
      return ActionListDataResponse(
          status: ResponseStatus.failed, errorMessage: e.toString());
    }
  }

  Future<http.Response> _getAccountPosts(
      AccountPostType type,
      String accountName,
      String? lastAuthor,
      String? lastPermlink,
      int limit) async {
    var url = Uri.parse(
        'https://hivexplorer.com/api/get_account_posts?sort=${enumToString(type)}&account=$accountName&limit=$limit&start_author=$lastAuthor&start_permlink=$lastPermlink');

    var response = await http.get(
      url,
    );
    return response;
  }

  Future<ActionSingleDataResponse<ThreadFeedModel>> getFirstAccountPost(
    String accountName,
    AccountPostType type,
    int limit,
    String? lastAuthor,
    String? lastPermlink,
  ) async {
    try {
      http.Response response = await _getAccountPosts(
          type, accountName, lastAuthor, lastPermlink, limit);

      if (response.statusCode == 200) {
        return ActionSingleDataResponse<ThreadFeedModel>(
            data: ThreadFeedModel.fromRawJson(response.body).first,
            status: ResponseStatus.success,
            isSuccess: true,
            errorMessage: "");
      } else {
        return ActionSingleDataResponse(
            status: ResponseStatus.failed, errorMessage: "Server Error");
      }
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

  Future<ActionSingleDataResponse<UserModel>> getAccountInfo(
    String accountName,
  ) async {
    try {
      var url = Uri.parse(
          'https://hivexplorer.com/api/get_accounts?names=\[%22$accountName%22\]');

      http.Response response = await http.get(
        url,
      );
      if (response.statusCode == 200) {
        return ActionSingleDataResponse<UserModel>(
            data: UserModel.fromJsonString(response.body).first,
            status: ResponseStatus.success,
            isSuccess: true,
            errorMessage: "");
      } else {
        return ActionSingleDataResponse(
            status: ResponseStatus.failed, errorMessage: "Server Error");
      }
    } catch (e) {
      return ActionSingleDataResponse(
          status: ResponseStatus.failed, errorMessage: e.toString());
    }
  }

  Future<ActionSingleDataResponse<FollowCountModel>> getFollowCount(
    String accountName,
  ) async {
    try {
      var url = Uri.parse(
          "https://hivexplorer.com/api/get_follow_count?account=$accountName");

      http.Response response = await http.get(
        url,
      );
      if (response.statusCode == 200) {
        return ActionSingleDataResponse<FollowCountModel>(
            data: FollowCountModel.fromJsonString(response.body),
            status: ResponseStatus.success,
            isSuccess: true,
            errorMessage: "");
      } else {
        return ActionSingleDataResponse(
            status: ResponseStatus.failed, errorMessage: "Server Error");
      }
    } catch (e) {
      return ActionSingleDataResponse(
          status: ResponseStatus.failed, errorMessage: e.toString());
    }
  }
}
