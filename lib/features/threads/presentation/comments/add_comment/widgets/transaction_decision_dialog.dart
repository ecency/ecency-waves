import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/auth/presentation/widgets/auth_button.dart';

class TransactionDecisionDialog extends StatelessWidget {
  const TransactionDecisionDialog({super.key, required this.onContinue});

  final Function(AuthType) onContinue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Center(
          child: Text(
        LocaleText.continueUsing,
        style: theme.textTheme.displayMedium,
      )),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Gap(15),
          AuthButton(
              authType: AuthType.hiveKeyChain,
              onTap: () => onTap(context, AuthType.hiveKeyChain)),
          const Gap(15),
          AuthButton(
              authType: AuthType.hiveAuth,
              onTap: () => onTap(context, AuthType.hiveAuth)),
        ],
      ),
    );
  }

  void onTap(BuildContext context, AuthType authType) {
    Navigator.pop(context);
    onContinue(authType);
  }
}
