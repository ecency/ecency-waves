Future<String> runThisJS_(String jsCode) {
  return _error();
}

Future<String> getRedirectUriDataFromPlatform(String username) {
  return _error();
}

Future<String> getDecryptedHASTokenFromPlatform(
    String username, String encryptedData, String authKey) {
  return _error();
}

Future<String> validatePostingKeyFromPlatform(
  String username,
  String postingKey,
  String account,
) {
  return _error();
}

Future<String> commentOnContentFromPlatform(
  String username,
  String author,
  String parentPermlink,
  String permlink,
  String comment,
  List<String> tags,
  String? postingKey,
  String? authKey,
  String? token,
) {
  return _error();
}

Future<String> voteContentFromPlatform(
  String username,
  String author,
  String permlink,
  int weight,
  String? postingKey,
  String? authKey,
  String? token,
) {
  return _error();
}

Future<String> transferFromPlatform(
  String username,
  String to,
  String amount,
  String asset,
  String memo,
  String? postingKey,
  String? authKey,
  String? token,
) {
  return _error();
}

Future<String> castPollVoteFromPlatform(
  String username,
  String pollId,
  List<int> choices,
  String? postingKey,
  String? authKey,
  String? token,
) async {
     return _error();
}

Future<String> getImageUploadProofWithPostingKeyFromPlatform(
  String username,
  String postingKey,
) {
  return _error();
}

Future<String> muteUserFromPlatform(
  String username,
  String author,
  String? postingKey,
  String? authKey,
  String? token,
){
  return _error();
}

Future<String> _error() {
  return Future.value('error');
}

String generateId(String name) {
  return '${name}_${DateTime.now().toIso8601String()}';
}
