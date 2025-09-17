import 'package:flutter/material.dart';
import 'package:waves/core/locales/locale_text.dart';

class TipActiveKeyDialog extends StatefulWidget {
  const TipActiveKeyDialog({super.key, required this.accountName});

  final String accountName;

  @override
  State<TipActiveKeyDialog> createState() => _TipActiveKeyDialogState();
}

class _TipActiveKeyDialogState extends State<TipActiveKeyDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canSubmit = _controller.text.trim().isNotEmpty;
    final colorScheme = theme.colorScheme;
    final onSurface = colorScheme.onSurface;
    return AlertDialog(
      title: Text(
        LocaleText.tipEnterActiveKey,
        style: theme.textTheme.titleLarge?.copyWith(color: onSurface),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleText.tipActiveKeyInstructions(widget.accountName),
            style:
                theme.textTheme.bodyMedium?.copyWith(color: onSurface),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: LocaleText.activePrivateKey,
              labelStyle: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() {
                  _obscure = !_obscure;
                }),
              ),
            ),
            onChanged: (_) => setState(() {}),
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
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: theme.primaryColor,
            foregroundColor: colorScheme.onPrimary,
            disabledForegroundColor:
                theme.colorScheme.onSurface.withOpacity(0.38),
            disabledBackgroundColor:
                theme.colorScheme.onSurface.withOpacity(0.12),
          ),
          onPressed: canSubmit
              ? () => Navigator.of(context).pop(_controller.text.trim())
              : null,
          child: Text(LocaleText.tip),
        ),
      ],
    );
  }
}
