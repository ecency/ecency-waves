import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/extensions/ui.dart';
import 'package:waves/core/common/widgets/transactions/transaction_widget_view.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/utilities/constants/ui_constants.dart';
import 'package:waves/features/auth/presentation/controller/hive_auth_controller.dart';

class HiveAuthView extends StatefulWidget {
  const HiveAuthView(
      {super.key,
      required this.accountName,
      required this.isHiveKeyChainLogin});

  final String accountName;
  final bool isHiveKeyChainLogin;

  @override
  State<HiveAuthView> createState() => _HiveAuthViewState();
}

class _HiveAuthViewState extends State<HiveAuthView> {
  late final HiveAuthController hiveAuthController;
  @override
  void initState() {
    hiveAuthController = HiveAuthController(
      ishiveKeyChainMethod: widget.isHiveKeyChainLogin,
      showError: (error) => context.showSnackBar(error),
      onSuccess: (_) {
        context.showSnackBar(LocaleText.successfullLoginMessage(widget.accountName));
        Navigator.pop(context);
        Navigator.pop(context);
      },
      accountName: widget.accountName,
      onFailure: () {
        Navigator.pop(context);
      },
    );
    hiveAuthController.initTransactionProcess();
    super.initState();
  }

  @override
  void dispose() {
    hiveAuthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Provider.value(
      value: hiveAuthController,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.isHiveKeyChainLogin ? "KeyChain Login" : "Hive Auth Login",
              style: theme.textTheme.displaySmall,
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: kScreenPadding,
              child: TransactionWidgetView(
                listenerProvider: hiveAuthController.listenersProvider,
              ),
            ),
          ),
        );
      },
    );
  }
}
