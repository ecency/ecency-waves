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

class BlockUserHelper {
  const BlockUserHelper._();

  static void blockUser(
    BuildContext context, {
    required String author,
    VoidCallback? onSuccess,
  }) {
    final userController = context.read<UserController>();
    final userName = userController.userName;
    if (userName != null && userName == author) {
      return;
    }

    context.authenticatedAction(action: () {
      final userData = userController.userData!;
      if (userData.isPostingKeyLogin) {
        _postingKeyMuteTransaction(
          context,
          author,
          userData as UserAuthModel<PostingAuthModel>,
          onSuccess,
        );
      } else if (userData.isHiveSignerLogin) {
        _hiveSignerMuteTransaction(
          context,
          author,
          userData as UserAuthModel<HiveSignerAuthModel>,
          onSuccess,
        );
      } else if (userData.isHiveKeychainLogin) {
        _onTransactionDecision(
          context,
          author,
          AuthType.hiveKeyChain,
          userData,
          onSuccess,
        );
      } else if (userData.isHiveAuthLogin) {
        _onTransactionDecision(
          context,
          author,
          AuthType.hiveAuth,
          userData,
          onSuccess,
        );
      } else {
        _showTransactionSelection(context, author, userData, onSuccess);
      }
    });
  }

  static Future<void> _postingKeyMuteTransaction(
    BuildContext context,
    String author,
    UserAuthModel<PostingAuthModel> userData,
    VoidCallback? onSuccess,
  ) async {
    context.showLoader();
    await SignTransactionPostingKeyController().initMuteProcess(
      author: author,
      authdata: userData,
      onSuccess: () {
        context.hideLoader();
        onSuccess?.call();
      },
      onFailure: () => context.hideLoader(),
      showToast: (message) => context.showSnackBar(message),
    );
  }

  static Future<void> _hiveSignerMuteTransaction(
    BuildContext context,
    String author,
    UserAuthModel<HiveSignerAuthModel> userData,
    VoidCallback? onSuccess,
  ) async {
    context.showLoader();
    await SignTransactionHiveSignerController().initMuteProcess(
      author: author,
      authdata: userData,
      onSuccess: () {
        context.hideLoader();
        onSuccess?.call();
      },
      onFailure: () => context.hideLoader(),
      showToast: (message) => context.showSnackBar(message),
    );
  }

  static void _onTransactionDecision(
    BuildContext context,
    String author,
    AuthType authType,
    UserAuthModel userData,
    VoidCallback? onSuccess,
  ) {
    final navigationData = SignTransactionNavigationModel(
      transactionType: SignTransactionType.mute,
      author: author,
      ishiveKeyChainMethod: authType == AuthType.hiveKeyChain,
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
    UserAuthModel userData,
    VoidCallback? onSuccess,
  ) async {
    await showDialog(
      context: context,
      builder: (_) => TransactionDecisionDialog(
        onContinue: (authType) =>
            _onTransactionDecision(context, author, authType, userData, onSuccess),
      ),
    );
  }
}
