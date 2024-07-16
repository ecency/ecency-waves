class Parser {
  static String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    String result = htmlText.replaceAll(exp, '');
    RegExp regex = RegExp(
      r'(posted via d\.buzz|---\s*for the best experience view this post on \[liketu\]\(https://liketu\.com/[^\)]+\))',
      caseSensitive: false,
      multiLine: true,
    );
    return result.replaceAll(regex, '').trim();
  }
}
