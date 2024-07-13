// ignore_for_file: depend_on_referenced_packages

import 'package:markdown/markdown.dart' as md;

class RawImageSyntax extends md.InlineSyntax {
  RawImageSyntax() : super(r'(?<!\!\[.*?\]\()https:\/\/.+\.(png|jpg|jpeg|gif)');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    var rawImage = match[0]!;
    var element = md.Element.text('rawImage', rawImage);
    parser.addNode(element);
    return true;
  }
}
