import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/extensions/ui.dart';
import 'package:waves/core/dependency_injection/dependency_injection.dart';
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
import 'package:waves/features/threads/repository/thread_local_repository.dart';

class BlockUserHelper {
  const BlockUserHelper._();

  static void blockUser(
    BuildContext context, {
    required String author,
    VoidCallback? onSuccess,
  }) {
    toggleBlock(
      context,
      author: author,
      block: true,
      onSuccess: onSuccess,
    );
  }

  static void toggleBlock(
    BuildContext context, {
    required String author,
    required bool block,
    VoidCallback? onSuccess,
    VoidCallback? onFailure,
  }) {
    final userController = context.read<UserController>();
    final userName = userController.userName;
    if (userName != null && userName == author) {
      return;
    }

    context.authenticatedAction(action: () {
      final wrappedOnSuccess = () {
        if (block) {
          unawaited(
            getIt<ThreadLocalRepository>().removeAuthorFromCache(author),
          );
        }
        onSuccess?.call();
      };

      final wrappedOnFailure = () {
        onFailure?.call();
      };

      final userData = userController.userData;
      if (userData == null) {
        wrappedOnFailure();
        return;
      }
      if (userData.isPostingKeyLogin) {
        _postingKeyMuteTransaction(
          context,
          author,
          block,
          userData as UserAuthModel<PostingAuthModel>,
          wrappedOnSuccess,
          wrappedOnFailure,
        );
      } else if (userData.isHiveSignerLogin) {
        _hiveSignerMuteTransaction(
          context,
          author,
          block,
          userData as UserAuthModel<HiveSignerAuthModel>,
          wrappedOnSuccess,
          wrappedOnFailure,
        );
      } else if (userData.isHiveKeychainLogin) {
        _onTransactionDecision(
          context,
          author,
          block,
          AuthType.hiveKeyChain,
          userData,
          wrappedOnSuccess,
          wrappedOnFailure,
        );
      } else if (userData.isHiveAuthLogin) {
        _onTransactionDecision(
          context,
          author,
          block,
          AuthType.hiveAuth,
          userData,
          wrappedOnSuccess,
          wrappedOnFailure,
        );
      } else {
        _showTransactionSelection(
          context,
          author,
          block,
          userData,
          wrappedOnSuccess,
          wrappedOnFailure,
        );
      }
    });
  }

  static Future<void> _postingKeyMuteTransaction(
    BuildContext context,
    String author,
    bool block,
    UserAuthModel<PostingAuthModel> userData,
    VoidCallback? onSuccess,
    VoidCallback? onFailure,
  ) async {
    context.showLoader();
    await SignTransactionPostingKeyController().initMuteProcess(
      author: author,
      block: block,
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

  static Future<void> _hiveSignerMuteTransaction(
    BuildContext context,
    String author,
    bool block,
    UserAuthModel<HiveSignerAuthModel> userData,
    VoidCallback? onSuccess,
    VoidCallback? onFailure,
  ) async {
    context.showLoader();
    await SignTransactionHiveSignerController().initMuteProcess(
      author: author,
      block: block,
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
    bool block,
    AuthType authType,
    UserAuthModel userData,
    VoidCallback? onSuccess,
    VoidCallback? onFailure,
  ) {
    final navigationData = SignTransactionNavigationModel(
      transactionType: SignTransactionType.mute,
      author: author,
      ishiveKeyChainMethod: authType == AuthType.hiveKeyChain,
      mute: block,
    );
    context
        .pushNamed(
          Routes.hiveSignTransactionView,
          extra: navigationData,
        )
        .then((value) {
      if (value != null) {
        onSuccess?.call();
      } else {
        onFailure?.call();
      }
    });
  }

  static Future<void> _showTransactionSelection(
    BuildContext context,
    String author,
    bool block,
    UserAuthModel userData,
    VoidCallback? onSuccess,
    VoidCallback? onFailure,
  ) async {
    await showDialog(
      context: context,
      builder: (_) => TransactionDecisionDialog(
        onContinue: (authType) => _onTransactionDecision(
          context,
          author,
          block,
          authType,
          userData,
          onSuccess,
          onFailure,
        ),
      ),
    );
  }
}
