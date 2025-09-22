import 'package:waves/core/models/action_response.dart';
import 'package:waves/core/services/data_service/api_service.dart';
import 'package:waves/features/notifications/models/notification_model.dart';

class NotificationsRepository {
  NotificationsRepository({required ApiService apiService})
      : _apiService = apiService;

  final ApiService _apiService;

  Future<ActionListDataResponse<NotificationModel>> fetchNotifications({
    required String userName,
    String? filter,
    String? since,
    int? limit,
    String? code,
  }) {
    return _apiService.getNotifications(
      userName: userName,
      filter: filter,
      since: since,
      limit: limit,
      code: code,
    );
  }

  Future<ActionSingleDataResponse<int>> fetchUnreadCount({
    required String userName,
    String? code,
  }) {
    return _apiService.getUnreadNotificationCount(
      userName: userName,
      code: code,
    );
  }

  Future<ActionSingleDataResponse<void>> markNotification({
    required String userName,
    String? id,
    String? code,
  }) {
    return _apiService.markNotification(
      userName: userName,
      id: id,
      code: code,
    );
  }
}
