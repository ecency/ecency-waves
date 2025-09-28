import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/extensions/ui.dart';
import 'package:waves/core/routes/routes.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/auth/models/hive_signer_auth_model.dart';
import 'package:waves/features/auth/models/posting_auth_model.dart';
import 'package:waves/features/auth/models/user_auth_model.dart';
import 'package:waves/features/threads/models/comment/comment_navigation_model.dart';
import 'package:waves/features/threads/presentation/comments/add_comment/controller/sign_transaction_hive_signer_controller.dart';
import 'package:waves/features/threads/presentation/comments/add_comment/controller/sign_transaction_posting_key_controller.dart';
import 'package:waves/features/threads/presentation/comments/add_comment/widgets/transaction_decision_dialog.dart';
import 'package:waves/features/user/view/user_controller.dart';

class FollowUserHelper {
  const FollowUserHelper._();

  static void toggleFollow(
    BuildContext context, {
    required String author,
    required bool follow,
    VoidCallback? onSuccess,
    VoidCallback? onFailure,
  }) {
    final userController = context.read<UserController>();
    final userName = userController.userName;
    if (userName != null && userName == author) {
      onFailure?.call();
      return;
    }

    if (!userController.isUserLoggedIn) {
      context.showLoginDialog();
      onFailure?.call();
      return;
    }

    final userData = userController.userData!;

    if (userData.isPostingKeyLogin) {
      _postingKeyFollowTransaction(
        context,
        author,
        follow,
        userData as UserAuthModel<PostingAuthModel>,
        onSuccess,
        onFailure,
      );
    } else if (userData.isHiveSignerLogin) {
      _hiveSignerFollowTransaction(
        context,
        author,
        follow,
        userData as UserAuthModel<HiveSignerAuthModel>,
        onSuccess,
        onFailure,
      );
    } else if (userData.isHiveKeychainLogin) {
      _onTransactionDecision(
        context,
        author,
        follow,
        AuthType.hiveKeyChain,
        onSuccess,
      );
    } else if (userData.isHiveAuthLogin) {
      _onTransactionDecision(
        context,
        author,
        follow,
        AuthType.hiveAuth,
        onSuccess,
      );
    } else {
      _showTransactionSelection(
        context,
        author,
        follow,
        onSuccess,
      );
    }
  }

  static Future<void> _postingKeyFollowTransaction(
    BuildContext context,
    String author,
    bool follow,
    UserAuthModel<PostingAuthModel> userData,
    VoidCallback? onSuccess,
    VoidCallback? onFailure,
  ) async {
    context.showLoader();
    await SignTransactionPostingKeyController().initFollowProcess(
      author: author,
      follow: follow,
      authdata: userData,
      onSuccess: () {
        context.hideLoader();
        onSuccess?.call();
      },
      onFailure: () {
        context.hideLoader();
        onFailure?.call();
      },
      showToast: (message) => context.showSnackBar(message),
    );
  }

  static Future<void> _hiveSignerFollowTransaction(
    BuildContext context,
    String author,
    bool follow,
    UserAuthModel<HiveSignerAuthModel> userData,
    VoidCallback? onSuccess,
    VoidCallback? onFailure,
  ) async {
    context.showLoader();
    await SignTransactionHiveSignerController().initFollowProcess(
      author: author,
      follow: follow,
      authdata: userData,
      onSuccess: () {
        context.hideLoader();
        onSuccess?.call();
      },
      onFailure: () {
        context.hideLoader();
        onFailure?.call();
      },
      showToast: (message) => context.showSnackBar(message),
    );
  }

  static void _onTransactionDecision(
    BuildContext context,
    String author,
    bool follow,
    AuthType authType,
    VoidCallback? onSuccess,
  ) {
    final navigationData = SignTransactionNavigationModel(
      transactionType: SignTransactionType.follow,
      author: author,
      ishiveKeyChainMethod: authType == AuthType.hiveKeyChain,
      follow: follow,
    );
    context
        .pushNamed(
          Routes.hiveSignTransactionView,
          extra: navigationData,
        )
        .then((value) {
      if (value != null) {
        onSuccess?.call();
      }
    });
  }

  static Future<void> _showTransactionSelection(
    BuildContext context,
    String author,
    bool follow,
    VoidCallback? onSuccess,
  ) async {
    await showDialog(
      context: context,
      builder: (_) => TransactionDecisionDialog(
        onContinue: (authType) => _onTransactionDecision(
          context,
          author,
          follow,
          authType,
          onSuccess,
        ),
      ),
    );
  }
}
