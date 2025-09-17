import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class ColoredButton extends StatelessWidget {
  const ColoredButton(
      {super.key,
      required this.text,
      this.icon,
      required this.onPressed,
      this.backgroundColor,
      this.isBoldText = false,
      this.borderRadius});

  final String text;
  final IconData? icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final bool isBoldText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _button(theme);
  }

  SizedBox _button(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final Color effectiveBackground =
        backgroundColor ?? colorScheme.primary;
    final Color effectiveForeground = _resolveForegroundColor(
      theme,
      colorScheme,
      effectiveBackground,
    );
    return SizedBox(
      height: 30,
      child: FilledButton(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ??
                  const BorderRadius.all(Radius.circular(10)),
            ),
            backgroundColor: effectiveBackground,
            foregroundColor: effectiveForeground,
          ),
          onPressed: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null)
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Icon(
                    icon,
                    size: 18,
                    color: effectiveForeground,
                  ),
                ),
              AutoSizeText(
                text,
                minFontSize: 12,
                style: theme.textTheme.bodyMedium!
                    .copyWith(
                      fontWeight: isBoldText ? FontWeight.bold : null,
                      color: effectiveForeground,
                    ),
              ),
            ],
          )),
    );
  }

  Color _resolveForegroundColor(
      ThemeData theme, ColorScheme colorScheme, Color background) {
    if (background == colorScheme.primary) {
      if (theme.brightness == Brightness.dark) {
        return Colors.black87;
      }
      return colorScheme.onPrimary;
    }
    if (background == colorScheme.secondary) return colorScheme.onSecondary;
    if (background == colorScheme.tertiary) return colorScheme.onTertiary;
    if (background == colorScheme.primaryContainer) {
      return colorScheme.onPrimaryContainer;
    }
    if (background == colorScheme.secondaryContainer) {
      return colorScheme.onSecondaryContainer;
    }
    if (background == colorScheme.tertiaryContainer) {
      return colorScheme.onTertiaryContainer;
    }
    if (background == colorScheme.surface) return colorScheme.onSurface;
    if (background == colorScheme.surfaceVariant) {
      return colorScheme.onSurface;
    }
    return ThemeData.estimateBrightnessForColor(background) == Brightness.dark
        ? Colors.white
        : Colors.black;
  }
}
