// ignore_for_file: depend_on_referenced_packages

import 'package:markdown/markdown.dart' as md;

class MentionSyntax extends md.InlineSyntax {
  MentionSyntax()
      : super(r'@[A-Za-z0-9_](?:[A-Za-z0-9_.-]*[A-Za-z0-9_])?');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    var mention = match[0]!;
    var user = mention.substring(1);
    var element = md.Element.text('mention', '@$user');
    parser.addNode(element);
    return true;
  }
}
