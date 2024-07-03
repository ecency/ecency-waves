// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/markdown/markdown_image.dart';

class RawImageElementBuilder extends MarkdownElementBuilder {
  final ThemeData theme;
  final ThreadFeedModel item;
  RawImageElementBuilder({required this.theme, required this.item});

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    if (element.tag.isNotEmpty &&
        element.tag == 'rawImage' &&
        element.textContent.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: MarkdownImage(
          item: item,
          theme: theme,
          image: element.textContent,
        ),
      );
    }
    return super.visitElementAfterWithContext(
        context, element, preferredStyle, parentStyle);
  }
}
