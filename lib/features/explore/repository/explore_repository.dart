import 'package:waves/core/models/action_response.dart';
import 'package:waves/core/services/data_service/api_service.dart';
import 'package:waves/features/explore/models/trending_author_model.dart';
import 'package:waves/features/explore/models/trending_tag_model.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';

class ExploreRepository {
  final ApiService _apiService;
  ExploreRepository({required ApiService apiService}) : _apiService = apiService;

  Future<ActionListDataResponse<TrendingTagModel>> getTrendingTags(
          String container) =>
      _apiService.getTrendingTags(container);

  Future<ActionListDataResponse<TrendingAuthorModel>> getTrendingAuthors(
          String container) =>
      _apiService.getTrendingAuthors(container);

  Future<ActionListDataResponse<ThreadFeedModel>> getTagWaves(
          String container, String tag,
          {int limit = 20, String? lastAuthor, String? lastPermlink}) =>
      _apiService.getTagWaves(container, tag,
          limit: limit, lastAuthor: lastAuthor, lastPermlink: lastPermlink);

  Future<ActionListDataResponse<ThreadFeedModel>> getAccountWaves(
          String container, String username,
          {int limit = 20, String? lastAuthor, String? lastPermlink}) =>
      _apiService.getAccountWaves(container, username,
          limit: limit, lastAuthor: lastAuthor, lastPermlink: lastPermlink);
}
