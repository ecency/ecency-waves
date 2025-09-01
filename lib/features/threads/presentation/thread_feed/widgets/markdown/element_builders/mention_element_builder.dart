// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:waves/core/common/extensions/platform_navigation.dart';
import 'package:waves/core/routes/route_keys.dart';
import 'package:waves/core/routes/routes.dart';

class MentionBuilder extends MarkdownElementBuilder {
  final ThemeData theme;
  MentionBuilder({required this.theme});

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    if (element.tag.isNotEmpty &&
        element.tag == 'mention' &&
        element.textContent.isNotEmpty) {
      final user = element.textContent.replaceFirst('@', '');
      return GestureDetector(
        onTap: () {
          context.platformPushNamed(
            Routes.userProfileView,
            queryParameters: {RouteKeys.accountName: user},
          );
        },
        child: Text(
          element.textContent,
          style: theme.textTheme.bodyMedium!
              .copyWith(fontWeight: FontWeight.w300, color: theme.primaryColor),
        ),
      );
    }
    return super.visitElementAfterWithContext(
        context, element, preferredStyle, parentStyle);
  }
}
