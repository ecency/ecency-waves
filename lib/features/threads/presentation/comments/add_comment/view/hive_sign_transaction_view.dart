import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/extensions/ui.dart';
import 'package:waves/core/common/widgets/transactions/transaction_widget_view.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/utilities/constants/ui_constants.dart';
import 'package:waves/features/auth/models/hive_auth_model.dart';
import 'package:waves/features/auth/models/user_auth_model.dart';
import 'package:waves/features/threads/models/comment/comment_navigation_model.dart';
import 'package:waves/features/threads/presentation/comments/add_comment/controller/sign_transaction_hive_controller.dart';
import 'package:waves/features/user/view/user_controller.dart';

class HiveSignTransactionView extends StatefulWidget {
  const HiveSignTransactionView({super.key, required this.data});

  final SignTransactionNavigationModel data;
  @override
  State<HiveSignTransactionView> createState() =>
      _HiveSignTransactionViewState();
}

class _HiveSignTransactionViewState extends State<HiveSignTransactionView> {
  late final SignTransactionHiveController hiveSignTransactionController;
  @override
  void initState() {
    hiveSignTransactionController = SignTransactionHiveController(
      transactionType: widget.data.transactionType,
      ishiveKeyChainMethod: widget.data.ishiveKeyChainMethod,
      comment: widget.data.comment,
      weight: widget.data.weight,
      showError: (error) => context.showSnackBar(error),
      onSuccess: (generatedPermlink) {
        context.showSnackBar(LocaleText.smCommentPublishMessage);
        Navigator.pop(context,generatedPermlink);
      },
      authData: context.read<UserController>().userData!
          as UserAuthModel<HiveAuthModel>,
      author: widget.data.author,
      permlink: widget.data.permlink,
      onFailure: () {
        Navigator.pop(context);
      },
    );
    hiveSignTransactionController.initTransactionProcess();
    super.initState();
  }

  @override
  void dispose() {
    hiveSignTransactionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Provider.value(
      value: hiveSignTransactionController,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.data.ishiveKeyChainMethod ? LocaleText.keyChain : LocaleText.hiveAuth,
              style: theme.textTheme.displaySmall,
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: kScreenPadding,
              child: TransactionWidgetView(
                listenerProvider: hiveSignTransactionController.listenersProvider,
              ),
            ),
          ),
        );
      },
    );
  }
}
