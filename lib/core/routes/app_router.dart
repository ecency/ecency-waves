import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:waves/core/routes/route_keys.dart';
import 'package:waves/core/routes/routes.dart';
import 'package:waves/features/auth/presentation/view/auth_key_chain_view.dart';
import 'package:waves/features/auth/presentation/view/auth_view.dart';
import 'package:waves/features/bookmarks/views/thread_bookmark/bookmark_view.dart';
import 'package:waves/features/threads/models/comment/comment_navigation_model.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';
import 'package:waves/features/threads/presentation/comments/add_comment/view/add_comment_view.dart';
import 'package:waves/features/threads/presentation/comments/add_comment/view/hive_sign_transaction_view.dart';
import 'package:waves/features/threads/presentation/comments/comment_detail/view/comment_detail_view.dart';
import 'package:waves/features/threads/presentation/thread_feed/view/thread_feed_view.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter router = GoRouter(
      navigatorKey: _rootNavigatorKey, initialLocation: '/', routes: routes());

  static List<RouteBase> routes() {
    return [
      GoRoute(
        path: '/',
        name: Routes.initialView,
        builder: (context, state) => const ThreadFeedView(),
      ),
      GoRoute(
        path: '/${Routes.bookmarksView}',
        name: Routes.bookmarksView,
        builder: (context, state) => const BookmarksView(),
      ),
      GoRoute(
        path: '/${Routes.authView}',
        name: Routes.authView,
        builder: (context, state) => const AuthView(),
      ),
      GoRoute(
          path: '/${Routes.addCommentView}',
          name: Routes.addCommentView,
          builder: (context, state) {
            String accountName =
                state.uri.queryParameters[RouteKeys.accountName]!;
            String permlink = state.uri.queryParameters[RouteKeys.permlink]!;
            String depth = state.uri.queryParameters[RouteKeys.depth]!;
            return AddCommentView(
              author: accountName,
              permlink: permlink,
              depth: int.parse(depth),
            );
          }),
      GoRoute(
        path: '/${Routes.hiveSignTransactionView}',
        name: Routes.hiveSignTransactionView,
        builder: (context, state) {
          return HiveSignTransactionView(
            data: state.extra as SignTransactionNavigationModel,
          );
        },
      ),
      GoRoute(
        path: '/${Routes.hiveAuthView}',
        name: Routes.hiveAuthView,
        builder: (context, state) {
          String accountName =
              state.uri.queryParameters[RouteKeys.accountName]!;
          bool isHiveKeyChainLogin = _stringToBool(
              state.uri.queryParameters[RouteKeys.isHiveKeyChainLogin]!);
          return HiveAuthView(
            accountName: accountName,
            isHiveKeyChainLogin: isHiveKeyChainLogin,
          );
        },
      ),
       GoRoute(
        path: '/${Routes.commentDetailView}',
        name: Routes.commentDetailView,
        builder: (context, state) {
          return CommentDetailView(
            item: state.extra as ThreadFeedModel,
          );
        },
      ),
    ];
  }

  static bool _stringToBool(String value) {
    return value.toLowerCase() == "true";
  }

  static String currentRoute() {
    return AppRouter.router.routerDelegate.currentConfiguration.uri.path
        .toString();
  }

  static void popTillFirstScreen(
    BuildContext context,
  ) {
    while (router
            .routerDelegate.currentConfiguration.matches.last.matchedLocation !=
        '/') {
      if (!context.canPop()) {
        return;
      }
      context.pop();
    }
  }
}
