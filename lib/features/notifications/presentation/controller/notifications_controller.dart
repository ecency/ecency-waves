import 'package:flutter/foundation.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/auth/models/hive_signer_auth_model.dart';
import 'package:waves/features/auth/models/user_auth_model.dart';
import 'package:waves/features/notifications/models/notification_model.dart';
import 'package:waves/features/notifications/repository/notifications_repository.dart';

class NotificationsController extends ChangeNotifier {
  NotificationsController({
    required NotificationsRepository repository,
    UserAuthModel? user,
  })  : _repository = repository,
        _userName = user?.accountName,
        _authToken = _resolveAuthToken(user) {
    if (_userName != null) {
      _loadUnreadCount();
    }
  }

  final NotificationsRepository _repository;
  final List<NotificationModel> _notifications = [];
  String? _activeFilter;

  String? _userName;
  String? _authToken;
  ViewState viewState = ViewState.loading;
  String? errorMessage;
  bool _isFetching = false;
  bool _hasLoaded = false;
  bool _loadingUnread = false;
  int unreadCount = 0;

  List<NotificationModel> get notifications => List.unmodifiable(_notifications);

  List<NotificationModel> get filteredNotifications {
    final filter = _activeFilter;
    if (filter == null || filter.isEmpty) {
      return notifications;
    }
    return _notifications
        .where((item) => item.type.toLowerCase() == filter)
        .toList(growable: false);
  }

  List<String> get availableFilters {
    final types = <String>{};
    for (final notification in _notifications) {
      final type = notification.type.trim().toLowerCase();
      if (type.isNotEmpty) {
        types.add(type);
      }
    }
    final list = types.toList(growable: false);
    list.sort();
    return list;
  }

  String? get activeFilter => _activeFilter;

  bool get isLoggedIn => _userName != null && _userName!.isNotEmpty;

  bool get hasLoaded => _hasLoaded;

  void setFilter(String? type) {
    final normalized = type?.trim().toLowerCase();
    if (_activeFilter == normalized) {
      return;
    }
    _activeFilter = normalized?.isEmpty ?? true ? null : normalized;
    notifyListeners();
  }

  void updateUser(UserAuthModel? user) {
    final newUserName = user?.accountName;
    final newAuthToken = _resolveAuthToken(user);
    final hasChanged =
        _userName != newUserName || _authToken != newAuthToken;

    _userName = newUserName;
    _authToken = newAuthToken;

    if (!isLoggedIn) {
      _isFetching = false;
      _loadingUnread = false;
      _notifications.clear();
      _activeFilter = null;
      unreadCount = 0;
      errorMessage = null;
      _hasLoaded = false;
      viewState = ViewState.empty;
      notifyListeners();
      return;
    }

    if (hasChanged) {
      _resetState(preserveViewState: false);
      _loadUnreadCount();
    }
  }

  Future<void> loadNotifications({bool forceRefresh = false}) async {
    if (!isLoggedIn) {
      viewState = ViewState.empty;
      notifyListeners();
      return;
    }

    if (_isFetching) return;
    _isFetching = true;

    if (!forceRefresh) {
      viewState = ViewState.loading;
      notifyListeners();
    }

    try {
      final response = await _repository.fetchNotifications(
        userName: _userName!,
        limit: 50,
        code: _authToken,
      );

      if (response.isSuccess && response.data != null) {
        _notifications
          ..clear()
          ..addAll(response.data!);
        if (_activeFilter != null &&
            !_notifications.any(
              (item) => item.type.toLowerCase() == _activeFilter,
            )) {
          _activeFilter = null;
        }
        viewState = _notifications.isEmpty ? ViewState.empty : ViewState.data;
        errorMessage = null;
      } else {
        viewState = ViewState.error;
        errorMessage = response.errorMessage;
      }

      final unreadResponse = await _repository.fetchUnreadCount(
        userName: _userName!,
        code: _authToken,
      );

      if (unreadResponse.isSuccess && unreadResponse.data != null) {
        unreadCount = unreadResponse.data!;
      }
    } catch (e) {
      viewState = ViewState.error;
      errorMessage = e.toString();
    } finally {
      _hasLoaded = true;
      _isFetching = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadNotifications(forceRefresh: true);
  }

  Future<void> markAsRead(NotificationModel notification) async {
    if (!isLoggedIn || notification.read) {
      return;
    }

    final index =
        _notifications.indexWhere((item) => item.id == notification.id);
    if (index == -1) {
      return;
    }

    final previous = _notifications[index];
    if (previous.read) {
      return;
    }

    _notifications[index] = previous.copyWith(read: true);
    bool decremented = false;
    if (unreadCount > 0) {
      unreadCount -= 1;
      decremented = true;
    }
    notifyListeners();

    try {
      final response = await _repository.markNotification(
        userName: _userName!,
        code: _authToken,
        id: notification.id.isNotEmpty ? notification.id : null,
      );

      if (!response.isSuccess) {
        _notifications[index] = previous;
        if (decremented) {
          unreadCount += 1;
        }
        notifyListeners();
      }
    } catch (_) {
      _notifications[index] = previous;
      if (decremented) {
        unreadCount += 1;
      }
      notifyListeners();
    }
  }

  void _resetState({bool preserveViewState = true}) {
    _notifications.clear();
    _activeFilter = null;
    unreadCount = 0;
    errorMessage = null;
    _hasLoaded = false;
    if (!preserveViewState) {
      viewState = ViewState.loading;
    }
    notifyListeners();
  }

  Future<void> _loadUnreadCount() async {
    if (!isLoggedIn || _loadingUnread) return;
    _loadingUnread = true;
    try {
      final response = await _repository.fetchUnreadCount(
        userName: _userName!,
        code: _authToken,
      );
      if (response.isSuccess && response.data != null) {
        unreadCount = response.data!;
        notifyListeners();
      }
    } finally {
      _loadingUnread = false;
    }
  }

  static String? _resolveAuthToken(UserAuthModel? user) {
    if (user == null) {
      return null;
    }

    if (user.imageUploadToken.isNotEmpty) {
      return user.imageUploadToken;
    }

    if (user.authType == AuthType.hiveSign) {
      final auth = user.auth;
      if (auth is HiveSignerAuthModel && auth.token.isNotEmpty) {
        return auth.token;
      }
    }

    return null;
  }
}
