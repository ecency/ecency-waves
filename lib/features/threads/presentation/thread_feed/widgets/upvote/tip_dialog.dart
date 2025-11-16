import 'package:flutter/material.dart';
import 'package:waves/core/locales/locale_text.dart';

class TipSelection {
  const TipSelection({required this.amount, required this.tokenSymbol});

  final double amount;
  final String tokenSymbol;
}

class TipDialog extends StatefulWidget {
  const TipDialog({
    super.key,
    required this.amountOptions,
    required this.tokenOptions,
    this.initialToken,
  });

  final List<double> amountOptions;
  final List<String> tokenOptions;
  final String? initialToken;

  @override
  State<TipDialog> createState() => _TipDialogState();
}

class _TipDialogState extends State<TipDialog> {
  late double _selectedAmount;
  late String _selectedToken;

  @override
  void initState() {
    super.initState();
    _selectedAmount = widget.amountOptions.first;
    _selectedToken = _resolveInitialToken();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final onSurface = colorScheme.onSurface;
    final brightness = theme.brightness;
    final outlineColor = colorScheme.outline.withOpacity(0.4);
    final unselectedBackgroundColor = colorScheme.surfaceVariant;
    final unselectedLabelColor = onSurface;
    final selectedBackgroundColor = colorScheme.primaryContainer;
    final selectedLabelColor = brightness == Brightness.dark
        ? Colors.black87
        : colorScheme.onPrimaryContainer;
    final chipBorderColor = brightness == Brightness.dark
        ? colorScheme.primary.withOpacity(0.35)
        : outlineColor;
    return AlertDialog(
      title: Text(
        LocaleText.tip,
        style: theme.textTheme.titleLarge?.copyWith(color: onSurface),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleText.selectTipAmount,
            style:
                theme.textTheme.titleSmall?.copyWith(color: onSurface),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.amountOptions
                .map<Widget>(
                  (amount) {
                    final isSelected = _selectedAmount == amount;
                    return ChoiceChip(
                      label: Text(
                        _formatAmount(amount),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? selectedLabelColor
                              : unselectedLabelColor,
                        ),
                      ),
                      selected: isSelected,
                      backgroundColor: unselectedBackgroundColor,
                      selectedColor: selectedBackgroundColor,
                      side: BorderSide(
                        color: isSelected
                            ? colorScheme.primary
                            : chipBorderColor,
                      ),
                      showCheckmark: false,
                      onSelected: (_) => setState(() {
                        _selectedAmount = amount;
                      }),
                    );
                  },
                )
                .toList(),
          ),
          const SizedBox(height: 20),
          Text(
            LocaleText.selectToken,
            style:
                theme.textTheme.titleSmall?.copyWith(color: onSurface),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: widget.tokenOptions
                .map<Widget>(
                  (token) {
                    final isSelected = _selectedToken == token;
                    return ChoiceChip(
                      label: Text(
                        token,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? selectedLabelColor
                              : unselectedLabelColor,
                        ),
                      ),
                      selected: isSelected,
                      backgroundColor: unselectedBackgroundColor,
                      selectedColor: selectedBackgroundColor,
                      side: BorderSide(
                        color: isSelected
                            ? colorScheme.primary
                            : chipBorderColor,
                      ),
                      showCheckmark: false,
                      onSelected: (_) => setState(() {
                        _selectedToken = token;
                      }),
                    );
                  },
                )
                .toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.primary,
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(LocaleText.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.brightness == Brightness.dark
                ? Colors.black87
                : theme.colorScheme.onPrimary,
          ),
          onPressed: () {
            Navigator.of(context).pop(
              TipSelection(amount: _selectedAmount, tokenSymbol: _selectedToken),
            );
          },
          child: Text(LocaleText.tip),
        ),
      ],
    );
  }

  String _formatAmount(double amount) {
    if (amount % 1 == 0) {
      return amount.toStringAsFixed(0);
    }
    return amount.toStringAsFixed(1);
  }

  String _resolveInitialToken() {
    final initialToken = widget.initialToken;
    if (initialToken != null && widget.tokenOptions.contains(initialToken)) {
      return initialToken;
    }
    return widget.tokenOptions.first;
  }
}
