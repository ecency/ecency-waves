import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/extensions/ui.dart';
import 'package:waves/core/common/widgets/images/user_profile_image.dart';
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
import 'package:waves/features/threads/presentation/thread_feed/controller/thread_feed_controller.dart';
import 'package:waves/features/threads/presentation/thread_feed/view_models/view_model.dart';
import 'package:waves/features/user/view/user_controller.dart';

class AddCommentView extends StatefulWidget {
  const AddCommentView({
    super.key,
    required this.author,
    required this.permlink,
    required this.depth,
  });

  final String? author;
  final String? permlink;
  final int? depth;

  @override
  State<AddCommentView> createState() => _AddCommentViewState();
}

class _AddCommentViewState extends State<AddCommentView> {
  final TextEditingController commentTextEditingController =
      TextEditingController();
  late final bool isRoot;

  @override
  void initState() {
    if (widget.author == null && widget.permlink == null) {
      isRoot = true;
    } else {
      isRoot = false;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final UserAuthModel userData = context.read<UserController>().userData!;
    return Scaffold(
      appBar: _appBar(),
      body: SafeArea(
          child: Padding(
        padding: kScreenPadding,
        child: TextField(
          controller: commentTextEditingController,
          expands: true,
          maxLines: null,
          minLines: null,
          decoration:
              InputDecoration(hintText: hintText, border: InputBorder.none),
        ),
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          String comment = commentTextEditingController.text.trim();
          if (comment.isEmpty) {
            context.showSnackBar(LocaleText.replyCannotBeEmpty);
          } else if (isRoot &&
              context.read<ThreadFeedController>().rootThreadInfo == null) {
            context.pop();
          } else if (userData.isPostingKeyLogin) {
            _postingKeyCommentTransaction(comment, userData, context);
          } else if (userData.isHiveSignerLogin) {
            _hiveSignerCommentTransaction(comment, userData, context);
          } else {
            _onTransactionDecision(
                comment, AuthType.hiveKeyChain, context, userData);
          }
        },
        child: const Icon(Icons.reply),
      ),
    );
  }

  AppBar _appBar() {
    return isRoot
        ? AppBar(
            title: const Text("Publish"),
          )
        : AppBar(
            leadingWidth: 30,
            title: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: UserProfileImage(
                url: widget.author,
              ),
              title: AutoSizeText(
                "Reply to ${widget.author!}",
                minFontSize: 14,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                widget.permlink!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
  }

  String get hintText {
    return isRoot ? "What's happening?" : "Reply, engage, exchange ideas";
  }

  void _postingKeyCommentTransaction(String comment,
      UserAuthModel<dynamic> userData, BuildContext context) async {
    context.showLoader();
    await SignTransactionPostingKeyController().initCommentProcess(comment,
        author: author(context),
        parentPermlink: permlink(context),
        authData: userData as UserAuthModel<PostingAuthModel>,
        onSuccess: (generatedPermlink) {
          context.hideLoader();
          context.pop(
              generateCommentModel(generatedPermlink, userData.accountName));
        },
        onFailure: () => context.hideLoader(),
        showToast: (message) => context.showSnackBar(message));
  }

  void _hiveSignerCommentTransaction(String comment,
      UserAuthModel<dynamic> userData, BuildContext context) async {
    context.showLoader();
    await SignTransactionHiveSignerController().initCommentProcess(comment,
        parentAuthor: author(context),
        parentPermlink: permlink(context),
        authData: userData as UserAuthModel<HiveSignerAuthModel>,
        onSuccess: (generatedPermlink) {
          context.hideLoader();
          context.pop(
              generateCommentModel(generatedPermlink, userData.accountName));
        },
        onFailure: () => context.hideLoader(),
        showToast: (message) => context.showSnackBar(message));
  }

  Future<dynamic> _dialogForHiveTransaction(
      BuildContext context, String comment, UserAuthModel userData) {
    return showDialog(
      useRootNavigator: true,
      context: context,
      builder: (_) => TransactionDecisionDialog(
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
            author: author(context),
            permlink: permlink(context),
            comment: comment,
            ishiveKeyChainMethod: authType == AuthType.hiveKeyChain);
    context
        .pushNamed(Routes.hiveSignTransactionView, extra: navigationData)
        .then((generatedPermlink) {
      context.pop(
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
          depth: isRoot ? 1 : widget.depth! + 1,
          title: '',
          body: commentTextEditingController.text.trim(),
          created: DateTime.now());
    }
    return null;
  }

  String author(BuildContext context) {
    return threadInfo(context).author;
  }

  String permlink(BuildContext context) {
    return threadInfo(context).permlink;
  }

  ThreadInfo threadInfo(BuildContext context) {
    if (isRoot) {
      return context.read<ThreadFeedController>().rootThreadInfo!;
    } else {
      return ThreadInfo(author: widget.author!, permlink: widget.permlink!);
    }
  }
}
