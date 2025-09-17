import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/dependency_injection/dependency_injection.dart';
import 'package:waves/core/routes/route_keys.dart';
import 'package:waves/core/routes/routes.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/auth/presentation/view/auth_view.dart';
import 'package:waves/features/auth/presentation/view/hive_auth_transaction_view.dart';
import 'package:waves/features/auth/presentation/view/hive_key_chain_auth_view.dart';
import 'package:waves/features/auth/presentation/view/hive_signer_auth_view.dart';
import 'package:waves/features/auth/presentation/view/posting_key_auth_view.dart';
import 'package:waves/features/bookmarks/views/thread_bookmark/bookmark_view.dart';
import 'package:waves/features/explore/presentation/tag_feed/view/tag_feed_view.dart';
import 'package:waves/features/explore/presentation/view/explore_view.dart';
import 'package:waves/features/search/presentation/view/search_view.dart';
import 'package:waves/features/settings/presentation/setting/view/setting_view.dart';
import 'package:waves/features/settings/repository/settings_repository.dart';
import 'package:waves/features/threads/models/comment/comment_navigation_model.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';
import 'package:waves/features/threads/presentation/comments/add_comment/view/add_comment_view.dart';
import 'package:waves/features/threads/presentation/comments/add_comment/view/hive_sign_transaction_view.dart';
import 'package:waves/features/threads/presentation/comments/comment_detail/view/comment_detail_view.dart';
import 'package:waves/features/threads/presentation/thread_feed/view/thread_feed_view.dart';
import 'package:waves/features/user/presentation/user_profile/view/user_profile_view.dart';
import 'package:waves/features/user/view/user_controller.dart';
import 'package:waves/features/welcome/view/welcome_view.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter router(BuildContext context) {
    bool isTermsAccepted = context.select<UserController, bool>(
        (settingsController) => settingsController.getTermsAcceptedFlag());

    String initialPath = isTermsAccepted ? '/' : '/${Routes.welcomeView}';

    return GoRouter(
        navigatorKey: _rootNavigatorKey,
        initialLocation: initialPath,
        routes: routes());
  }

  static List<RouteBase> routes() {
    return [
      GoRoute(
        path: '/${Routes.welcomeView}',
        name: Routes.welcomeView,
        builder: (context, state) => const WelcomeView(),
      ),
      GoRoute(
        path: '/',
        name: Routes.initialView,
        builder: (context, state) => const ThreadFeedView(),
      ),
      GoRoute(
        path: '/${Routes.exploreView}',
        name: Routes.exploreView,
        builder: (context, state) => const ExploreView(),
      ),
      GoRoute(
        path: '/${Routes.searchView}',
        name: Routes.searchView,
        builder: (context, state) => const SearchView(),
      ),
      GoRoute(
        path: '/${Routes.tagFeedView}',
        name: Routes.tagFeedView,
        builder: (context, state) {
          final tag = state.uri.queryParameters[RouteKeys.tag]!;
          final typeParam = state.uri.queryParameters[RouteKeys.threadType];
          final defaultType = getIt<SettingsRepository>().readDefaultThread();
          final threadType = typeParam != null
              ? enumFromString<ThreadFeedType>(
                  typeParam,
                  ThreadFeedType.values,
                  defaultValue: defaultType,
                )
              : defaultType;
          return TagFeedView(tag: tag, threadType: threadType);
        },
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
            String? accountName =
                state.uri.queryParameters[RouteKeys.accountName];
            String? permlink = state.uri.queryParameters[RouteKeys.permlink];
            String? depth = state.uri.queryParameters[RouteKeys.depth];
            return AddCommentView(
              author: accountName,
              permlink: permlink,
              depth: depth != null ? int.tryParse(depth) : null,
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
        path: '/${Routes.hiveSignView}',
        name: Routes.hiveSignView,
        builder: (context, state) {
          return const HiveSignerAuthView();
        },
      ),
      GoRoute(
        path: '/${Routes.hiveAuthTransactionView}',
        name: Routes.hiveAuthTransactionView,
        builder: (context, state) {
          String accountName =
              state.uri.queryParameters[RouteKeys.accountName]!;
          bool isHiveKeyChainLogin = _stringToBool(
              state.uri.queryParameters[RouteKeys.isHiveKeyChainLogin]!);
          return HiveAuthTransactionView(
            accountName: accountName,
            isHiveKeyChainLogin: isHiveKeyChainLogin,
          );
        },
      ),
      GoRoute(
        path: '/${Routes.postingKeyAuthView}',
        name: Routes.postingKeyAuthView,
        builder: (context, state) {
          return const PostingKeyAuthView();
        },
      ),
      GoRoute(
        path: '/${Routes.hiveKeyChainAuthView}',
        name: Routes.hiveKeyChainAuthView,
        builder: (context, state) {
          return HiveKeyChainAuthView(
            authType: state.extra as AuthType,
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
      GoRoute(
        path: '/${Routes.userProfileView}',
        name: Routes.userProfileView,
        builder: (context, state) {
          final name = state.uri.queryParameters[RouteKeys.accountName]!;
          final typeParam = state.uri.queryParameters[RouteKeys.threadType];
          final defaultType = getIt<SettingsRepository>().readDefaultThread();
          final threadType = typeParam != null
              ? enumFromString<ThreadFeedType>(
                  typeParam,
                  ThreadFeedType.values,
                  defaultValue: ThreadFeedType.ecency,
                )
              : defaultType;
          return UserProfileView(
            accountName: name,
            threadType: threadType,
          );
        },
      ),
      GoRoute(
        path: '/${Routes.settingsView}',
        name: Routes.settingsView,
        builder: (context, state) {
          return const SettingView();
        },
      ),
    ];
  }

  static bool _stringToBool(String value) {
    return value.toLowerCase() == "true";
  }

  static String currentRoute(BuildContext context) {
    return AppRouter.router(context).routerDelegate.currentConfiguration.uri.path
        .toString();
  }

  static void popTillFirstScreen(
    BuildContext context,
  ) {
    while ((router(context))
            .routerDelegate
            .currentConfiguration
            .matches
            .last
            .matchedLocation !=
        '/') {
      if (!context.canPop()) {
        return;
      }
      context.pop();
    }
  }
}
