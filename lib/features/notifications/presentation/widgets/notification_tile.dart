import 'package:flutter/material.dart';
import 'package:waves/core/common/widgets/images/user_profile_image.dart';
import 'package:waves/core/common/widgets/inkwell_wrapper.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/locales/timeago_localizations.dart';
import 'package:waves/core/utilities/responsive/responsive_layout.dart';
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

    final title = _buildTitle();
    final subtitle = _buildSubtitle(title);

    final responsive = ResponsiveLayout.of(context);
    final borderRadius = BorderRadius.circular(
      responsive.value(mobile: 16, tablet: 18, desktop: 20),
    );
    final horizontalPadding = responsive.scaleComponent(12);
    final verticalPadding = responsive.scaleComponent(8);
    final interItemSpacing = responsive.scaleComponent(12);

    return InkWellWrapper(
      onTap: onTap,
      borderRadius: borderRadius,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserProfileImage(
              url: notification.actor.isEmpty ? null : notification.actor,
              radius: 22,
              verticalPadding: responsive.scaleComponent(4),
              onTap: onAvatarTap,
            ),
            SizedBox(width: interItemSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: titleStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: responsive.scaleComponent(4)),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  SizedBox(height: responsive.scaleComponent(6)),
                  Text(
                    formatRelativeTime(context, notification.timestamp),
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
        final mentionContext = _buildMentionContext();
        if (mentionContext != null && mentionContext.isNotEmpty) {
          return '$actorHandle mentioned you in $mentionContext';
        }
        return LocaleText.notificationsMentionedYou(actorHandle);
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

  String? _buildMentionContext() {
    final commentLink = _buildCommentLink();

    if (notification.isPost) {
      final title = notification.title;
      if (title != null && title.isNotEmpty) {
        return title;
      }
      if (commentLink != null && commentLink.isNotEmpty) {
        return commentLink;
      }
      final parentTitle = notification.parentTitle;
      if (parentTitle != null && parentTitle.isNotEmpty) {
        return parentTitle;
      }
    } else {
      if (commentLink != null && commentLink.isNotEmpty) {
        return commentLink;
      }
      final parentTitle = notification.parentTitle;
      if (parentTitle != null && parentTitle.isNotEmpty) {
        return parentTitle;
      }
      final title = notification.title;
      if (title != null && title.isNotEmpty) {
        return title;
      }
    }

    final permlink = notification.permlink;
    if (permlink != null && permlink.isNotEmpty) {
      return permlink;
    }

    return commentLink;
  }

  String? _buildCommentLink() {
    final author = notification.contentAuthor;
    final permlink = notification.permlink;
    if (author == null || author.isEmpty || permlink == null || permlink.isEmpty) {
      return null;
    }

    final sanitizedAuthor = author.startsWith('@') ? author.substring(1) : author;
    return '@$sanitizedAuthor/$permlink';
  }

  String? _buildSubtitle(String title) {
    switch (notification.type) {
      case 'follow':
        return null;
      case 'mention':
        final body = notification.body;
        if (body != null && body.isNotEmpty) {
          return body;
        }
        final mentionParentTitle = notification.parentTitle;
        if (mentionParentTitle != null &&
            mentionParentTitle.isNotEmpty &&
            mentionParentTitle != title) {
          return mentionParentTitle;
        }
        final notificationTitle = notification.title;
        if (notificationTitle != null &&
            notificationTitle.isNotEmpty &&
            notificationTitle != title) {
          return notificationTitle;
        }
        return null;
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
        final memo = notification.memo;
        if (memo != null && memo.isNotEmpty) {
          return memo;
        }
        return null;
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
