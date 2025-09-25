import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/dependency_injection/dependency_injection.dart';
import 'package:waves/core/routes/routes.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';
import 'package:waves/features/threads/repository/thread_repository.dart';
import 'package:waves/features/user/view/user_controller.dart';

class HivePostLinkHandler {
  static const Set<String> _supportedHosts = {
    'hive.blog',
    'www.hive.blog',
    'ecency.com',
    'www.ecency.com',
    'peakd.com',
    'www.peakd.com',
  };

  const HivePostLinkHandler._();

  static Future<bool> open(BuildContext context, String? rawUrl) async {
    final uri = _parseSupportedUri(rawUrl);
    if (uri == null) {
      return false;
    }

    final authorPermlink = _extractAuthorAndPermlink(uri);
    if (authorPermlink == null) {
      return false;
    }

    final repository = getIt<ThreadRepository>();
    final observer = context.read<UserController>().userName;

    BuildContext? dialogContext;
    void closeDialog() {
      if (dialogContext != null) {
        Navigator.of(dialogContext!).pop();
        dialogContext = null;
      }
    }

    if (context.mounted) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          dialogContext = ctx;
          return const Center(child: CircularProgressIndicator());
        },
      );
    }

    try {
      final response = await repository.getcomments(
        authorPermlink.author,
        authorPermlink.permlink,
        observer,
      );

      closeDialog();

      if (!context.mounted) {
        return false;
      }

      if (response.isSuccess &&
          response.data != null &&
          response.data!.isNotEmpty) {
        final items = response.data!;
        ThreadFeedModel target = items.first;
        for (final item in items) {
          if (item.author == authorPermlink.author &&
              item.permlink == authorPermlink.permlink) {
            target = item;
            break;
          }
        }
        context.pushNamed(Routes.commentDetailView, extra: target);
        return true;
      }
    } catch (_) {
      closeDialog();
      return false;
    } finally {
      closeDialog();
    }

    return false;
  }

  static Uri? _parseSupportedUri(String? rawUrl) {
    if (rawUrl == null) {
      return null;
    }
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final uri = Uri.tryParse(trimmed);
    if (uri == null) {
      return null;
    }
    final host = uri.host.toLowerCase();
    if (!_supportedHosts.contains(host)) {
      return null;
    }
    return uri;
  }

  static _AuthorPermlink? _extractAuthorAndPermlink(Uri uri) {
    final segments =
        uri.pathSegments.where((segment) => segment.isNotEmpty).toList();
    if (segments.length < 2) {
      return null;
    }

    final authorIndex =
        segments.lastIndexWhere((segment) => segment.startsWith('@'));
    if (authorIndex == -1 || authorIndex + 1 >= segments.length) {
      return null;
    }

    final authorSegment = segments[authorIndex];
    final permlink = segments[authorIndex + 1];
    final author =
        authorSegment.startsWith('@') ? authorSegment.substring(1) : authorSegment;

    if (author.isEmpty || permlink.isEmpty) {
      return null;
    }

    return _AuthorPermlink(author: author, permlink: permlink);
  }
}

class _AuthorPermlink {
  const _AuthorPermlink({required this.author, required this.permlink});

  final String author;
  final String permlink;
}
