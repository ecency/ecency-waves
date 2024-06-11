// ignore_for_file: depend_on_referenced_packages

import 'package:markdown/markdown.dart' as md;

class HashtagSyntax extends md.InlineSyntax {
  HashtagSyntax() : super(r'#\w+');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    var hashtag = match[0]!;
    var tag = hashtag.substring(1); 
    var element = md.Element.text('hashtag', '#$tag');
    parser.addNode(element);
    return true;
  }
}