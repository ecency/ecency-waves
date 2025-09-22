import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/widgets/empty_state.dart';
import 'package:waves/core/common/widgets/loading_state.dart';
import 'package:waves/core/common/widgets/server_error.dart';
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
      ),
      body: SafeArea(
        child: Consumer<NotificationsController>(
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
                return RefreshIndicator(
                  onRefresh: controller.refresh,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: kScreenPadding,
                    itemCount: controller.notifications.length,
                    itemBuilder: (context, index) {
                      final notification = controller.notifications[index];
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

    final author = notification.contentAuthor;
    final permlink = notification.permlink;

    if (author == null || author.isEmpty || permlink == null || permlink.isEmpty) {
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
      final response = await repository.getcomments(author, permlink, observer);

      if (dialogContext != null) {
        Navigator.of(dialogContext!).pop();
        dialogContext = null;
      }

      if (!mounted) return;

      if (response.isSuccess && response.data != null && response.data!.isNotEmpty) {
        final items = response.data!;
        ThreadFeedModel? target;
        for (final item in items) {
          if (item.author == author && item.permlink == permlink) {
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
        Navigator.of(dialogContext!).pop();
        dialogContext = null;
      }
      if (mounted) {
        _showError(e.toString());
      }
    } finally {
      if (dialogContext != null) {
        Navigator.of(dialogContext!).pop();
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
}
