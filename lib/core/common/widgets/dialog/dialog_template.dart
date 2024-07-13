import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:waves/core/common/widgets/dialog/dialog_button.dart';

class DialogTemplate extends StatelessWidget {
  const DialogTemplate({
    super.key,
    required this.title,
    required this.content,
    this.maxWidth,
    this.declineButtonText,
    this.proceedButtonText,
    this.onProceedTap,
  });

  final String title;
  final Widget? content;
  final double? maxWidth;
  final String? declineButtonText;
  final String? proceedButtonText;
  final VoidCallback? onProceedTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: theme.primaryColorLight,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12))),
      title: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.displaySmall,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          IconButton(
              onPressed: () {
                context.pop();
              },
              icon: const Icon(Icons.cancel))
        ],
      ),
      content: content,
      actions: [
        if (declineButtonText != null)
          DialogButton(
              text: declineButtonText!,
              onPressed: () {
                Navigator.pop(context);
              }),
        if (proceedButtonText != null)
          DialogButton(
            text: proceedButtonText!,
            onPressed: () {
              Navigator.pop(context);
              if (onProceedTap != null) onProceedTap!();
            },
          )
      ],
    );
  }
}
