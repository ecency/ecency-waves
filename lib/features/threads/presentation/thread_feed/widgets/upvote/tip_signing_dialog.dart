import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/auth/presentation/widgets/auth_button.dart';

enum TipSigningMethod { hiveSigner, hiveKeychain, ecency, hiveAuth }

class TipSigningDialog extends StatelessWidget {
  const TipSigningDialog({super.key});

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
          AuthButton(
            authType: AuthType.hiveSign,
            onTap: () => _onSelect(context, TipSigningMethod.hiveSigner),
            label: 'Hivesigner',
          ),
          const Gap(12),
          AuthButton(
            authType: AuthType.hiveKeyChain,
            onTap: () => _onSelect(context, TipSigningMethod.hiveKeychain),
            label: 'HiveKeychain',
          ),
          const Gap(12),
          AuthButton(
            authType: AuthType.ecency,
            onTap: () => _onSelect(context, TipSigningMethod.ecency),
            label: 'Ecency',
          ),
          const Gap(12),
          AuthButton(
            authType: AuthType.hiveAuth,
            onTap: () => _onSelect(context, TipSigningMethod.hiveAuth),
            label: 'HiveAuth',
          ),
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
}
