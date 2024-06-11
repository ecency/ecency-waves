import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:waves/core/common/widgets/inkwell_wrapper.dart';

class IconWithText extends StatelessWidget {
  const IconWithText(
      {super.key,
      required this.icon,
      this.iconColor,
      this.iconGap,
      this.textStyle,
      this.onTap,
      this.expand = false,
       this.text,
      this.maxlines,
      this.color,
      this.padding,
      this.borderRadius});
  final IconData icon;
  final Color? iconColor;
  final double? iconGap;
  final TextStyle? textStyle;
  final String? text;
  final VoidCallback? onTap;
  final bool expand;
  final int? maxlines;
  final Color? color;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWellWrapper(
      onTap: onTap,
      borderRadius: borderRadius,
      child: Container(
        decoration: BoxDecoration(color: color, borderRadius: borderRadius),
        child: Padding(
          padding:
              padding ?? const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 20,
                color: iconColor ?? theme.primaryColorDark.withOpacity(0.9),
              ),
              if(text!=null) SizedBox(width: iconGap ?? 5),
              if(text!=null) expand
                  ? Expanded(
                      child: _text(theme),
                    )
                  : _text(theme),
            ],
          ),
        ),
      ),
    );
  }

  AutoSizeText _text(ThemeData theme) {
    return AutoSizeText(
      text!,
      maxLines: maxlines ?? 1,
      minFontSize: 10,
      overflow: TextOverflow.ellipsis,
      style: textStyle ??
          theme.textTheme.labelLarge!.copyWith(
              color: iconColor ?? theme.primaryColorDark.withOpacity(0.9)),
    );
  }
}
