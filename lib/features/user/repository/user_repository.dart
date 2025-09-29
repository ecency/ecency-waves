
import 'package:waves/core/models/action_response.dart';
import 'package:waves/core/services/data_service/api_service.dart';
import 'package:waves/features/user/models/account_relationship_model.dart';
import 'package:waves/features/user/models/follow_count_model.dart';
import 'package:waves/features/user/models/follow_user_item_model.dart';
import 'package:waves/features/user/models/user_model.dart';

class UserRepository {
  final ApiService _apiService;

  UserRepository({required ApiService apiService}) : _apiService = apiService;

  Future<ActionSingleDataResponse<UserModel>> getAccountInfo(
      String accountName) async {
    return await _apiService.getAccountInfo(accountName);
  }

  Future<ActionSingleDataResponse<FollowCountModel>> getFollowCount(
      String accountName) async {
    return await _apiService.getFollowCount(accountName);
  }

  Future<ActionSingleDataResponse<bool>> fetchFollowRelationship(
      String follower, String following) async {
    return await _apiService.fetchFollowRelationship(follower, following);
  }

  Future<ActionSingleDataResponse<bool>> loadFollowRelationship(
      String follower, String following) async {
    return await _apiService.loadFollowRelationship(follower, following);
  }

  Future<ActionSingleDataResponse<AccountRelationshipModel>>
      fetchAccountRelationship(String follower, String following) async {
    return await _apiService.fetchAccountRelationship(follower, following);
  }

  Future<ActionListDataResponse<FollowUserItemModel>> getFollowers(
    String accountName, {
    String? start,
    int limit = 20,
  }) async {
    return await _apiService.getFollowers(
      accountName,
      start: start,
      limit: limit,
    );
  }

  Future<ActionListDataResponse<FollowUserItemModel>> getFollowing(
    String accountName, {
    String? start,
    int limit = 20,
  }) async {
    return await _apiService.getFollowing(
      accountName,
      start: start,
      limit: limit,
    );
  }
}
