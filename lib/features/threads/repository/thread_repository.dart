import 'package:waves/core/models/action_response.dart';
import 'package:waves/core/models/broadcast_model.dart';
import 'package:waves/core/services/data_service/api_service.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';

class ThreadRepository {
  final ApiService _apiService;

  ThreadRepository({required ApiService apiService}) : _apiService = apiService;

  Future<ActionListDataResponse<ThreadFeedModel>> getAccountPosts(
      String accountName, AccountPostType type, int limit,
      {String? lastAuthor, String? lastPermlink}) async {
    return await _apiService.getAccountPosts(
        accountName, type, limit, lastAuthor, lastPermlink);
  }

  Future<ActionSingleDataResponse<ThreadFeedModel>> getFirstAccountPost(
      String accountName, AccountPostType type, int limit,
      {String? lastAuthor, String? lastPermlink}) async {
    return await _apiService.getFirstAccountPost(
      accountName,
      type,
      limit,
      lastAuthor,
      lastPermlink,
    );
  }

  Future<ActionListDataResponse<ThreadFeedModel>> getcomments(
      String accountName, String permlink) async {
    return await _apiService.getComments(accountName, permlink);
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
    return await _apiService.commentOnContent(username, author, parentPermlink,
        permlink, comment, postingKey, authKey, token);
  }

  Future<ActionSingleDataResponse<String>> votecontent(
    String username,
    String author,
    String permlink,
    double weight,
    String? postingKey,
    String? authKey,
    String? token,
  ) async {
    return await _apiService.voteContent(
        username, author, permlink, weight, postingKey, authKey, token);
  }

  Future<ActionSingleDataResponse> voteUsingHiveSigner(
      String token, BroadcastModel<VoteBroadCastModel> data) async {
    return await _apiService.broadcastTransactionUsingHiveSigner(token, data);
  }

   Future<ActionSingleDataResponse> commentUsingHiveSigner(
      String token, BroadcastModel<CommentBroadCastModel> data) async {
    return await _apiService.broadcastTransactionUsingHiveSigner(token, data);
  }
}
