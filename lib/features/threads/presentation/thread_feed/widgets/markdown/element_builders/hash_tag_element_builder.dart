// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

class HashTagBuilder extends MarkdownElementBuilder {
  final ThemeData theme;
  HashTagBuilder({required this.theme});

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    if (element.tag.isNotEmpty &&
        element.tag == 'hashtag' &&
        element.textContent.isNotEmpty) {
      return GestureDetector(
        onTap: () {},
        child: Text(
          element.textContent,
          style: preferredStyle
        ),
      );
    }
    return super.visitElementAfterWithContext(
        context, element, preferredStyle, parentStyle);
  }
}
