import 'package:flutter/material.dart';
import 'package:waves/core/common/widgets/dialog/dialog_template.dart';

class DeleteAccountDialog extends StatelessWidget {
  const DeleteAccountDialog({super.key, required this.onDelete});

  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DialogTemplate(
      title: "Delete Account",
      content: Text(
        "Are you sure you want to delete your account?",
        style: theme.textTheme.bodyMedium,
      ),
      declineButtonText: "Cancel",
      proceedButtonText: "Confirm",
      onProceedTap: () {
        onDelete();
      },
    );
  }
}
