import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/extensions/ui.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/routes/routes.dart';
import 'package:waves/core/utilities/act.dart';
import 'package:waves/core/utilities/constants/ui_constants.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/auth/models/hive_signer_auth_model.dart';
import 'package:waves/features/auth/models/posting_auth_model.dart';
import 'package:waves/features/auth/models/user_auth_model.dart';
import 'package:waves/features/threads/models/comment/comment_navigation_model.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';
import 'package:waves/features/threads/presentation/comments/add_comment/controller/sign_transaction_hive_signer_controller.dart';
import 'package:waves/features/threads/presentation/comments/add_comment/controller/sign_transaction_posting_key_controller.dart';
import 'package:waves/features/threads/presentation/comments/add_comment/widgets/transaction_decision_dialog.dart';
import 'package:waves/features/user/view/user_controller.dart';

class AddCommentView extends StatefulWidget {
  const AddCommentView(
      {super.key,
      required this.author,
      required this.permlink,
      required this.depth});

  final String author;
  final String permlink;
  final int depth;

  @override
  State<AddCommentView> createState() => _AddCommentViewState();
}

class _AddCommentViewState extends State<AddCommentView> {
  final TextEditingController commentTextEditingController =
      TextEditingController();
  @override
  Widget build(BuildContext context) {
    final UserAuthModel userData = context.read<UserController>().userData!;
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleText.addAComment),
      ),
      body: SafeArea(
          child: Padding(
        padding: kScreenPadding,
        child: TextField(
          controller: commentTextEditingController,
          expands: true,
          maxLines: null,
          minLines: null,
          decoration: InputDecoration(
              hintText: LocaleText.addYourReply, border: InputBorder.none),
        ),
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          String comment = commentTextEditingController.text.trim();
          // Navigator.pop(
          //     context,
          //     ThreadFeedModel(
          //         postId: Act.generateRandomNumber(6),
          //         parentAuthor: widget.author,
          //         parentPermlink: widget.permlink,
          //         author: userData.accountName,
          //         permlink: Act.generatePermlink(userData.accountName),
          //         category: "",
          //         depth: widget.depth + 1,
          //         title: '',
          //         children: 0,
          //         body: commentTextEditingController.text.trim(),
          //         created: DateTime.now()));
          if (comment.isEmpty) {
            context.showSnackBar(LocaleText.replyCannotBeEmpty);
          } else if (userData.isPostingKeyLogin) {
            _postingKeyCommentTransaction(comment, userData, context);
          } else if (userData.isHiveSignerLogin) {
            _hiveSignerCommentTransaction(comment, userData, context);
          } else {
            _dialogForHiveTransaction(context, comment, userData);
          }
        },
        child: const Icon(Icons.reply),
      ),
    );
  }

  void _postingKeyCommentTransaction(String comment,
      UserAuthModel<dynamic> userData, BuildContext context) async {
    context.showLoader();
    await SignTransactionPostingKeyController().initCommentProcess(comment,
        author: widget.author,
        parentPermlink: widget.permlink,
        authData: userData as UserAuthModel<PostingAuthModel>,
        onSuccess: (generatedPermlink) {
          Navigator.pop(context,
              generateCommentModel(generatedPermlink, userData.accountName));
        },
        showToast: (message) => context.showSnackBar(message));
    // ignore: use_build_context_synchronously
    context.hideLoader();
  }

  void _hiveSignerCommentTransaction(String comment,
      UserAuthModel<dynamic> userData, BuildContext context) async {
    context.showLoader();
    await SignTransactionHiveSignerController().initCommentProcess(comment,
        parentAuthor: widget.author,
        parentPermlink: widget.permlink,
        authData: userData as UserAuthModel<HiveSignerAuthModel>,
        onSuccess: (generatedPermlink) {
          Navigator.pop(context,
              generateCommentModel(generatedPermlink, userData.accountName));
        },
        showToast: (message) => context.showSnackBar(message));
    // ignore: use_build_context_synchronously
    context.hideLoader();
  }

  Future<dynamic> _dialogForHiveTransaction(
      BuildContext context, String comment, UserAuthModel userData) {
    return showDialog(
      context: context,
      builder: (context) => TransactionDecisionDialog(
        onContinue: (authType) {
          _onTransactionDecision(comment, authType, context, userData);
        },
      ),
    );
  }

  void _onTransactionDecision(String comment, AuthType authType,
      BuildContext context, UserAuthModel userData) async {
    SignTransactionNavigationModel navigationData =
        SignTransactionNavigationModel(
            transactionType: SignTransactionType.comment,
            author: widget.author,
            permlink: widget.permlink,
            comment: comment,
            ishiveKeyChainMethod: authType == AuthType.hiveKeyChain);
    context
        .pushNamed(Routes.hiveSignTransactionView, extra: navigationData)
        .then((generatedPermlink) {
      Navigator.pop(
        context,
        generateCommentModel(generatedPermlink, userData.accountName),
      );
    });
  }

  ThreadFeedModel? generateCommentModel(Object? permlink, String userName) {
    if (permlink != null && permlink is String) {
      return ThreadFeedModel(
          postId: Act.generateRandomNumber(6),
          parentAuthor: widget.author,
          parentPermlink: widget.permlink,
          author: userName,
          permlink: permlink,
          category: "",
          depth: widget.depth + 1,
          title: '',
          body: commentTextEditingController.text.trim(),
          created: DateTime.now());
    }
    return null;
  }
}
