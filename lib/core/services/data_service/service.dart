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
) {
  return _error();
}

Future<String> commentOnContentFromPlatform(
  String username,
  String author,
  String parentPermlink,
  String permlink,
  String comment,
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
  double weight,
  String? postingKey,
  String? authKey,
  String? token,
) {
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
