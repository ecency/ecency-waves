import 'package:flutter/material.dart';
import 'package:waves/core/common/extensions/layout_adapter.dart';

class AdaptiveText extends StatelessWidget {
  const AdaptiveText(
      {super.key,
      required this.text,
      this.style,
      this.overflow,
      this.maxLines,
      this.textAlign});

  final TextStyle? style;
  final String text;
  final TextOverflow? overflow;
  final int? maxLines;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final textStyle = style ?? Theme.of(context).textTheme.bodyMedium;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Text(
          text,
          overflow: overflow,
          maxLines: maxLines,
          textAlign: textAlign,
          style: textStyle!.copyWith(
            fontSize: _fontSize(context, textStyle),
          ),
        );
      },
    );
  }

  double _fontSize(BuildContext context, TextStyle style) {
    if (context.isMobileSize) {
      return style.fontSize!;
    } else if (context.isTabletSize) {
      return style.fontSize! + 1.5;
    } else {
      return style.fontSize! + 3;
    }
  }
}
