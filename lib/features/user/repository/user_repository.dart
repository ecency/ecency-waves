
import 'package:waves/core/models/action_response.dart';
import 'package:waves/core/services/data_service/api_service.dart';
import 'package:waves/features/user/models/follow_count_model.dart';
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
}
