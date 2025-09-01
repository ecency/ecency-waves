import 'package:waves/core/models/action_response.dart';
import 'package:waves/core/services/data_service/api_service.dart';
import 'package:waves/features/explore/models/trending_author_model.dart';
import 'package:waves/features/explore/models/trending_tag_model.dart';
import 'package:waves/features/threads/presentation/thread_feed/view_models/view_model.dart';

class ExploreRepository {
  final ApiService _apiService;
  ExploreRepository({required ApiService apiService}) : _apiService = apiService;

  Future<ActionListDataResponse<TrendingTagModel>> getTrendingTags(
          String container) =>
      _apiService.getTrendingTags(container);

  Future<ActionListDataResponse<TrendingAuthorModel>> getTrendingAuthors(
          String container) =>
      _apiService.getTrendingAuthors(container);

  Future<ActionListDataResponse<ThreadInfo>> getTagSnaps(
          String container, String tag) =>
      _apiService.getTagSnaps(container, tag);

  Future<ActionListDataResponse<ThreadInfo>> getAccountSnaps(
          String container, String username) =>
      _apiService.getAccountSnaps(container, username);
}
