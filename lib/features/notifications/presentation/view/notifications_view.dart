import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/widgets/empty_state.dart';
import 'package:waves/core/common/widgets/loading_state.dart';
import 'package:waves/core/common/widgets/server_error.dart';
import 'package:waves/core/common/widgets/locale_aware_consumer.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/routes/route_keys.dart';
import 'package:waves/core/routes/routes.dart';
import 'package:waves/core/utilities/constants/ui_constants.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/core/dependency_injection/dependency_injection.dart';
import 'package:waves/features/notifications/models/notification_model.dart';
import 'package:waves/features/notifications/presentation/controller/notifications_controller.dart';
import 'package:waves/features/notifications/presentation/widgets/notification_tile.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';
import 'package:waves/features/threads/repository/thread_repository.dart';
import 'package:waves/features/user/view/user_controller.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<NotificationsController>();
      if (!controller.hasLoaded) {
        controller.loadNotifications();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleText.notifications),
        actions: const [
          _NotificationsFilterButton(),
        ],
      ),
      body: SafeArea(
        child: LocaleAwareConsumer<NotificationsController>(
          builder: (context, controller, child) {
            if (!controller.isLoggedIn) {
              return Emptystate(
                icon: Icons.notifications_off,
                text: LocaleText.pleaseLoginFirst,
              );
            }

            switch (controller.viewState) {
              case ViewState.loading:
                return const LoadingState();
              case ViewState.error:
                return ErrorState(
                  showRetryButton: true,
                  onTapRetryButton: () => controller.loadNotifications(),
                );
              case ViewState.empty:
                return Emptystate(
                  icon: Icons.notifications_none,
                  text: LocaleText.noNotificationsFound,
                );
              case ViewState.data:
                final notifications = controller.filteredNotifications;
                if (notifications.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: controller.refresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: kScreenPadding,
                      children: [
                        Emptystate(
                          icon: Icons.notifications_none,
                          text: LocaleText.noNotificationsFound,
                        ),
                      ],
                    ),
                  );
                }

                final hasFilter = controller.activeFilter != null;
                final filterLabel = hasFilter
                    ? _formatFilterLabel(controller.activeFilter!)
                    : null;

                return RefreshIndicator(
                  onRefresh: controller.refresh,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: kScreenPadding,
                    itemCount:
                        notifications.length + (hasFilter ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (hasFilter) {
                        if (index == 0) {
                          final theme = Theme.of(context);
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    theme.colorScheme.primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.filter_list,
                                    size: 18,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(filterLabel ?? ''),
                                ],
                              ),
                            ),
                          );
                        }
                        final notification = notifications[index - 1];
                        return NotificationTile(
                          notification: notification,
                          onAvatarTap: () =>
                              _onNotificationAvatarTap(notification),
                          onTap: () => _onNotificationTap(notification),
                        );
                      }

                      final notification = notifications[index];
                      return NotificationTile(
                        notification: notification,
                        onAvatarTap: () =>
                            _onNotificationAvatarTap(notification),
                        onTap: () => _onNotificationTap(notification),
                      );
                    },
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                  ),
                );
            }
          },
        ),
      ),
    );
  }

  void _onNotificationAvatarTap(NotificationModel notification) {
    final controller = context.read<NotificationsController>();
    unawaited(controller.markAsRead(notification));
    _openProfile(notification.actor);
  }

  Future<void> _onNotificationTap(NotificationModel notification) async {
    if (_isNavigating) return;

    final controller = context.read<NotificationsController>();
    unawaited(controller.markAsRead(notification));

    final type = notification.type.toLowerCase();
    switch (type) {
      case 'follow':
      case 'delegations':
        _openProfile(notification.actor);
        return;
      case 'transfer':
        final actor = notification.actor;
        if (actor.isNotEmpty) {
          _openProfile(actor);
        }
        return;
      default:
        break;
    }

    final contentAuthor = notification.contentAuthor;
    final contentPermlink = notification.permlink;

    String? targetAuthor = contentAuthor;
    String? targetPermlink = contentPermlink;

    if (type == 'reply') {
      final parentAuthor = notification.parentAuthor;
      final parentPermlink = notification.parentPermlink;
      if (parentAuthor != null && parentAuthor.isNotEmpty &&
          parentPermlink != null && parentPermlink.isNotEmpty) {
        targetAuthor = parentAuthor;
        targetPermlink = parentPermlink;
      }
    }

    if (targetAuthor == null || targetAuthor.isEmpty ||
        targetPermlink == null || targetPermlink.isEmpty) {
      _openProfile(notification.actor);
      return;
    }

    _isNavigating = true;

    BuildContext? dialogContext;
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          dialogContext = ctx;
          return const Center(child: CircularProgressIndicator());
        },
      );
    }

    try {
      final repository = getIt<ThreadRepository>();
      final observer = context.read<UserController>().userName;
      final response =
          await repository.getcomments(targetAuthor, targetPermlink, observer);

      if (dialogContext != null) {
        _dismissProgressDialog(dialogContext);
        dialogContext = null;
      }

      if (!mounted) return;

      if (response.isSuccess && response.data != null && response.data!.isNotEmpty) {
        final items = response.data!;
        ThreadFeedModel? target;
        for (final item in items) {
          if (item.author == targetAuthor &&
              item.permlink == targetPermlink) {
            target = item;
            break;
          }
        }
        target ??= items.first;
        context.pushNamed(Routes.commentDetailView, extra: target);
      } else {
        _showError(response.errorMessage);
      }
    } catch (e) {
      if (dialogContext != null) {
        _dismissProgressDialog(dialogContext);
        dialogContext = null;
      }
      if (mounted) {
        _showError(e.toString());
      }
    } finally {
      if (dialogContext != null) {
        _dismissProgressDialog(dialogContext);
        dialogContext = null;
      }
      _isNavigating = false;
    }
  }

  void _openProfile(String? username) {
    if (!mounted || username == null || username.isEmpty) {
      return;
    }

    final sanitized = username.startsWith('@') ? username.substring(1) : username;
    if (sanitized.isEmpty) return;

    context.pushNamed(
      Routes.userProfileView,
      queryParameters: {
        RouteKeys.accountName: sanitized,
      },
    );
  }

  void _showError(String? message) {
    if (!mounted) return;
    final text = (message != null && message.trim().isNotEmpty)
        ? message
        : LocaleText.somethingWentWrong;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  void _dismissProgressDialog(BuildContext? context) {
    final dialogContext = context;
    if (dialogContext == null) {
      return;
    }

    Navigator.of(dialogContext).pop();
  }
}

class _NotificationsFilterButton extends StatelessWidget {
  const _NotificationsFilterButton();

  static const String _allFilterValue = '__all_notifications__';

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationsController>(
      builder: (context, controller, child) {
        if (!controller.isLoggedIn) {
          return const SizedBox.shrink();
        }

        final iconColor = controller.activeFilter == null
            ? null
            : Theme.of(context).colorScheme.primary;

        return PopupMenuButton<String>(
          icon: Icon(
            Icons.filter_list,
            color: iconColor,
          ),
          onSelected: (value) {
            if (value == _allFilterValue) {
              controller.setFilter(null);
            } else {
              controller.setFilter(value);
            }
          },
          itemBuilder: (context) {
            final filters = controller.availableFilters;
            return <PopupMenuEntry<String>>[
              CheckedPopupMenuItem<String>(
                value: _allFilterValue,
                checked: controller.activeFilter == null,
                child: Text(LocaleText.threadTypeAll),
              ),
              ...filters.map(
                (filter) => CheckedPopupMenuItem<String>(
                  value: filter,
                  checked: controller.activeFilter == filter,
                  child: Text(_formatFilterLabel(filter)),
                ),
              ),
            ];
          },
        );
      },
    );
  }
}

String _formatFilterLabel(String value) {
  if (value.isEmpty) return value;
  final cleaned = value.replaceAll('_', ' ');
  return cleaned[0].toUpperCase() + cleaned.substring(1);
}
