import 'package:flutter/material.dart';
import 'package:waves/core/common/extensions/platform_navigation.dart';
import 'package:waves/core/common/widgets/dialog/dialog_template.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/routes/routes.dart';

class LogInDialog extends StatelessWidget {
  const LogInDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      title: LocaleText.notLoggedIn,
      content: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ).copyWith(bottom: 20),
        child: Text(LocaleText.pleaseLoginFirst),
      ),
      declineButtonText: LocaleText.cancel,
      proceedButtonText: LocaleText.login,
      onProceedTap: () {
        context.platformPushNamed(Routes.authView);
      },
    );
  }
}
