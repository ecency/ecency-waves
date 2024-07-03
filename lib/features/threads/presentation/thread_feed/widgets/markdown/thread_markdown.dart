import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:waves/core/utilities/act.dart';
import 'package:waves/core/utilities/parser.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/markdown/element_builders/hash_tag_element_builder.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/markdown/element_builders/raw_image_element_builder.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/markdown/markdown_image.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/markdown/markdown_syntax.dart/hash_tag_syntax.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/markdown/markdown_syntax.dart/raw_image_syntax.dart';

class ThreadMarkDown extends StatelessWidget {
  const ThreadMarkDown({super.key, required this.item});

  final ThreadFeedModel item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MarkdownBody(
      styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
        blockquoteDecoration: const BoxDecoration(color: Colors.transparent),
        blockquotePadding: EdgeInsets.zero,
        a: _threadLinkTextStyle(theme),
        p: _threadTextStyle(theme),
      ),
      inlineSyntaxes: [HashtagSyntax(),RawImageSyntax()],
      data: Parser.removeAllHtmlTags(item.body),
      // data:
      //     "![image](https://img.inleo.io/DQmVABFnMDwPhMe6ZnRN7nG8RAo37uk9v9QMQyiaQpd64bk/Screenshot_20240627-081817.jpg)",
      builders: {
        'hashtag': HashTagBuilder(theme: theme),
        'rawImage': RawImageElementBuilder(theme: theme, item: item)
      },
      imageBuilder: (uri, title, alt) {
        return MarkdownImage(
          item: item,
          theme: theme,
          image: uri.toString(),
        );
      },
      shrinkWrap: true,
      onTapLink: (text, url, title) {
        Act.launchThisUrl(url ?? 'https://google.com');
      },
    );
  }

  TextStyle _threadTextStyle(ThemeData theme) {
    return theme.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w300);
  }

  TextStyle _threadLinkTextStyle(ThemeData theme) {
    return theme.textTheme.bodyMedium!
        .copyWith(fontWeight: FontWeight.w300, color: theme.primaryColor);
  }
}

