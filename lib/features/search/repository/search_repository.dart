import 'package:waves/core/models/action_response.dart';
import 'package:waves/core/services/data_service/api_service.dart';
import 'package:waves/features/search/models/search_tag_model.dart';
import 'package:waves/features/search/models/search_user_model.dart';

class SearchRepository {
  final ApiService _apiService;

  SearchRepository({required ApiService apiService}) : _apiService = apiService;

  Future<ActionListDataResponse<SearchUserModel>> searchUsers(String query,
          {int limit = 20}) =>
      _apiService.searchUsers(query, limit: limit);

  Future<ActionListDataResponse<SearchTagModel>> searchTags(String query,
          {int limit = 250}) =>
      _apiService.searchTags(query, limit: limit);
}
