import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/extensions/ui.dart';
import 'package:waves/core/common/widgets/buttons/duo_text_buttons.dart';
import 'package:waves/core/routes/routes.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/auth/models/hive_signer_auth_model.dart';
import 'package:waves/features/auth/models/posting_auth_model.dart';
import 'package:waves/features/auth/models/user_auth_model.dart';
import 'package:waves/features/threads/models/comment/comment_navigation_model.dart';
import 'package:waves/features/threads/presentation/comments/add_comment/controller/sign_transaction_hive_signer_controller.dart';
import 'package:waves/features/threads/presentation/comments/add_comment/controller/sign_transaction_posting_key_controller.dart';
import 'package:waves/features/threads/presentation/comments/add_comment/widgets/transaction_decision_dialog.dart';
import 'package:waves/features/threads/presentation/thread_feed/controller/thread_feed_controller.dart';
import 'package:waves/features/user/view/user_controller.dart';

class UserProfileFollowMuteButtons extends StatefulWidget {
  const UserProfileFollowMuteButtons({
    super.key,
    this.buttonHeight,
    required this.author,
  });

  final double? buttonHeight;
  final String author;

  @override
  State<UserProfileFollowMuteButtons> createState() =>
      _UserProfileFollowMuteButtonsState();
}

class _UserProfileFollowMuteButtonsState
    extends State<UserProfileFollowMuteButtons> {
  late ThreadFeedController feedController;

  @override
  void didChangeDependencies() {
    feedController = context.read<ThreadFeedController>();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final userName = context.read<UserController>().userName;
    if (userName != null && userName == widget.author) {
      return const SizedBox.shrink();
    }
    return DuoTextButtons(
      buttonHeight: widget.buttonHeight,
      buttonOneText: "Block User",
      buttonOneOnTap: () {
        context.authenticatedAction(action: () {
          final UserAuthModel userData =
              context.read<UserController>().userData!;
          if (userData.isPostingKeyLogin) {
            _postingKeyMuteTransaction(userData, context);
          } else if (userData.isHiveSignerLogin) {
            _hiveSignerMuteTransaction(userData, context);
          } else if (userData.isHiveKeychainLogin) {
            _onTransactionDecision(AuthType.hiveKeyChain, context, userData);
          } else if (userData.isHiveAuthLogin) {
            _onTransactionDecision(AuthType.hiveAuth, context, userData);
          } else {
            _showTransactionSelection(context, userData);
          }
        });
      },
    );
  }

  void _postingKeyMuteTransaction(
      UserAuthModel<dynamic> userData, BuildContext context) async {
    context.showLoader();
    await SignTransactionPostingKeyController().initMuteProcess(
        author: widget.author,
        authdata: userData as UserAuthModel<PostingAuthModel>,
        onSuccess: () {
          context.hideLoader();
          refreshFeeds();
        },
        onFailure: () => context.hideLoader(),
        showToast: (message) => context.showSnackBar(message));
  }

  void _hiveSignerMuteTransaction(
      UserAuthModel<dynamic> userData, BuildContext context) async {
    context.showLoader();
    await SignTransactionHiveSignerController().initMuteProcess(
        author: widget.author,
        authdata: userData as UserAuthModel<HiveSignerAuthModel>,
        onSuccess: () {
          context.hideLoader();
          refreshFeeds();
        },
        onFailure: () => context.hideLoader(),
        showToast: (message) => context.showSnackBar(message));
  }

  void _onTransactionDecision(
      AuthType authType, BuildContext context, UserAuthModel userData) async {
    SignTransactionNavigationModel navigationData =
        SignTransactionNavigationModel(
            transactionType: SignTransactionType.mute,
            author: widget.author,
            ishiveKeyChainMethod: authType == AuthType.hiveKeyChain);
    context
        .pushNamed(Routes.hiveSignTransactionView, extra: navigationData)
        .then((value) {
      if (value != null) {
        refreshFeeds();
      }
    });
  }

  Future<void> _showTransactionSelection(
      BuildContext context, UserAuthModel userData) async {
    await showDialog(
      context: context,
      builder: (_) => TransactionDecisionDialog(
        onContinue: (authType) =>
            _onTransactionDecision(authType, context, userData),
      ),
    );
  }

  void refreshFeeds() {
    Future.delayed(const Duration(seconds: 3)).then((_) {
      feedController.refresh();
    });
  }
}
