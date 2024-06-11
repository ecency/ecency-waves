import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:waves/core/common/extensions/ui.dart';
import 'package:waves/core/common/widgets/view_image.dart';
import 'package:waves/core/utilities/act.dart';
import 'package:waves/core/utilities/parser.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/markdown/element_builders/hash_tag_element_builder.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/markdown/markdown_syntax.dart/hash_tag_syntax.dart';

class ThreadMarkDown extends StatelessWidget {
  const ThreadMarkDown({super.key, required this.item});

  final ThreadFeedModel item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MarkdownBody(
      styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
        a: _threadLinkTextStyle(theme),
        p: _threadTextStyle(theme),
      ),
      inlineSyntaxes: [HashtagSyntax()],
      data: Parser.removeAllHtmlTags(item.body),
      builders: {
        'hashtag': HashTagBuilder(theme: theme),
      },
      imageBuilder: (uri, title, alt) {
        return Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: GestureDetector(
            onTap: () {
              log(item.body);
              Navigator.push(
                context,
                context.fadePageRoute(
                  ViewImage(
                    image: uri.toString(),
                    images:
                        item.images != null ? item.images! : [uri.toString()],
                  ),
                ),
              );
            },
            child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                child: Image.network(
                  uri.toString(),
                  frameBuilder:
                      (context, child, frame, wasSynchronouslyLoaded) =>
                          frame == null
                              ? Container(
                                  color: theme.colorScheme.tertiary,
                                  height: 250,
                                  width: double.infinity,
                                  child: child,
                                )
                              : child,
                  loadingBuilder: (context, child, loadingProgress) =>
                      loadingProgress?.cumulativeBytesLoaded !=
                              loadingProgress?.expectedTotalBytes
                          ? Container(
                              color: theme.colorScheme.tertiary,
                              height: 250,
                              width: double.infinity,
                              child: child,
                            )
                          : child,
                )),
          ),
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






