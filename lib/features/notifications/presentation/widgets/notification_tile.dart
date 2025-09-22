import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:waves/core/common/widgets/images/user_profile_image.dart';
import 'package:waves/core/common/widgets/inkwell_wrapper.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/features/notifications/models/notification_model.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
    this.onAvatarTap,
  });

  static const String _fallbackActor = '@user';

  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = notification.read
        ? Colors.transparent
        : theme.colorScheme.primary.withOpacity(0.08);
    final titleStyle = notification.read
        ? theme.textTheme.bodyMedium
        : theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600);

    final subtitle = _buildSubtitle();

    return InkWellWrapper(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserProfileImage(
              url: notification.actor.isEmpty ? null : notification.actor,
              radius: 22,
              verticalPadding: 4,
              onTap: onAvatarTap,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _buildTitle(),
                    style: titleStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    timeago.format(notification.timestamp),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildTitle() {
    final actorHandle = notification.actorHandle.isNotEmpty
        ? notification.actorHandle
        : _fallbackActor;
    switch (notification.type) {
      case 'follow':
        return LocaleText.notificationsFollowedYou(actorHandle);
      case 'mention':
        return notification.title ??
            LocaleText.notificationsMentionedYou(actorHandle);
      case 'reply':
        return LocaleText.notificationsRepliedToYou(actorHandle);
      case 'delegations':
        final amount = notification.amount;
        if (amount != null && amount.isNotEmpty) {
          return LocaleText.notificationsDelegatedToYou(
            actorHandle,
            amount,
          );
        }
        return LocaleText.notificationsFromUser(
          _formatType(notification.type),
          actorHandle,
        );
      case 'transfer':
        final amount = notification.amount;
        if (amount != null && amount.isNotEmpty) {
          return LocaleText.notificationsTransferReceived(
            actorHandle,
            amount,
          );
        }
        return LocaleText.notificationsFromUser(
          _formatType(notification.type),
          actorHandle,
        );
      case 'vote':
        final title = notification.title ?? notification.permlink;
        if (title != null && title.isNotEmpty) {
          return LocaleText.notificationsVotedOn(
            actorHandle,
            title,
          );
        }
        return LocaleText.notificationsFromUser(
          _formatType(notification.type),
          actorHandle,
        );
      default:
        final typeLabel = _formatType(notification.type);
        return LocaleText.notificationsFromUser(
          typeLabel,
          actorHandle,
        );
    }
  }

  String? _buildSubtitle() {
    switch (notification.type) {
      case 'follow':
        return null;
      case 'mention':
        final title = notification.title;
        if (title != null && title.isNotEmpty) {
          return title;
        }
        return LocaleText.notificationsMentionedYou(
          notification.actorHandle.isNotEmpty
              ? notification.actorHandle
              : _fallbackActor,
        );
      case 'reply':
        if (notification.body != null) {
          return notification.body;
        }
        final parentTitle = notification.parentTitle;
        if (parentTitle != null) {
          return parentTitle;
        }
        return LocaleText.notificationsRepliedToYou(
          notification.actorHandle.isNotEmpty
              ? notification.actorHandle
              : _fallbackActor,
        );
      case 'delegations':
        return notification.memo ?? notification.amount;
      case 'transfer':
        final parts = <String>[];
        final amount = notification.amount;
        if (amount != null && amount.isNotEmpty) {
          parts.add(amount);
        }
        final memo = notification.memo;
        if (memo != null && memo.isNotEmpty) {
          parts.add(memo);
        }
        return parts.isEmpty ? null : parts.join(' • ');
      case 'vote':
        final title = notification.title;
        if (title != null && title.isNotEmpty) {
          return title;
        }
        final memo = notification.memo;
        if (memo != null && memo.isNotEmpty) {
          return memo;
        }
        return null;
      default:
        final memo = notification.memo;
        if (memo != null) {
          return memo;
        }
        final title = notification.title;
        if (title != null && title.isNotEmpty) {
          return title;
        }
        return null;
    }
  }

  String _formatType(String value) {
    if (value.isEmpty) return value;
    final cleaned = value.replaceAll('_', ' ');
    return cleaned[0].toUpperCase() + cleaned.substring(1);
  }

}
