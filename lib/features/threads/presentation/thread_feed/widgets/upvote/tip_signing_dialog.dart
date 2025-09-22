import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/auth/presentation/widgets/auth_button.dart';

enum TipSigningMethod { hiveSigner, hiveKeychain, ecency, hiveAuth }

class TipSigningDialog extends StatelessWidget {
  const TipSigningDialog({
    super.key,
    this.availableMethods = TipSigningMethod.values,
  });

  final List<TipSigningMethod> availableMethods;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final onSurface = colorScheme.onSurface;
    return AlertDialog(
      title: Text(
        LocaleText.tip,
        style: theme.textTheme.titleLarge?.copyWith(color: onSurface),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            LocaleText.tipRequiresAuth,
            style:
                theme.textTheme.bodyMedium?.copyWith(color: onSurface),
          ),
          const Gap(16),
          ..._buildMethodButtons(context),
        ],
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: colorScheme.primary,
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(LocaleText.cancel),
        )
      ],
    );
  }

  void _onSelect(BuildContext context, TipSigningMethod method) {
    Navigator.of(context).pop(method);
  }

  List<Widget> _buildMethodButtons(BuildContext context) {
    final buttons = <Widget>[];
    for (var index = 0; index < availableMethods.length; index++) {
      final method = availableMethods[index];
      late final AuthType authType;
      late final String label;
      switch (method) {
        case TipSigningMethod.hiveSigner:
          authType = AuthType.hiveSign;
          label = LocaleText.signWithSigner;
          break;
        case TipSigningMethod.hiveKeychain:
          authType = AuthType.hiveKeyChain;
          label = LocaleText.signWithKeychain;
          break;
        case TipSigningMethod.ecency:
          authType = AuthType.ecency;
          label = LocaleText.signWithEcency;
          break;
        case TipSigningMethod.hiveAuth:
          authType = AuthType.hiveAuth;
          label = LocaleText.signWithAuth;
          break;
      }

      buttons.add(
        AuthButton(
          authType: authType,
          onTap: () => _onSelect(context, method),
          label: label,
        ),
      );

      final isLast = index == availableMethods.length - 1;
      if (!isLast) {
        buttons.add(const Gap(12));
      }
    }

    return buttons;
  }
}
