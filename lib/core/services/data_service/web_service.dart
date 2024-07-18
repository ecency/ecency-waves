// ---- DHive Methods ----

// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:js_util';
import 'package:js/js.dart' show JS;

@JS('getChainProps')
external dynamic getChainProps(String identifier);

@JS('runThisJS')
external dynamic runThisJS(String jsCode);

Future<String> runThisJS_(String jsCode) async {
  var promise = runThisJS(jsCode);
  var contentData = await promiseToFuture(promise);
  return contentData;
}

@JS('doWeHaveHiveKeychainExtension')
external dynamic doWeHaveHiveKeychainExtension();

Future<String> doWeHaveHiveKeychainExtension_() async {
  var promise = doWeHaveHiveKeychainExtension();
  var contentData = await promiseToFuture(promise);
  return contentData;
}

@JS('signInWithHiveKeychain')
external dynamic signInWithHiveKeychain(String username, String message);

Future<String> signInWithHiveKeychain_(String username) async {
  final String id =
      'signInWithHiveKeychain_${DateTime.now().toIso8601String()}';
  final String message = '${username}_$id';
  var promise = signInWithHiveKeychain(username, message);
  var contentData = await promiseToFuture(promise);
  return contentData;
}

Future<String> getRedirectUriDataFromPlatform(String username) {
  throw UnimplementedError();
}

Future<String> getDecryptedHASTokenFromPlatform(
    String username, String encryptedData, String authKey) {
  throw UnimplementedError();
}

Future<String> validatePostingKeyFromPlatform(
  String username,
  String postingKey,
) async {
  throw UnimplementedError();
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
) async {
  throw UnimplementedError();
}

Future<String> voteContentFromPlatform(
  String username,
  String author,
  String permlink,
  double weight,
  String? postingKey,
  String? authKey,
  String? token,
) async {
  throw UnimplementedError();
}

Future<String> getImageUploadProofWithPostingKeyFromPlatform(
  String username,
  String postingKey,
) {
  throw UnimplementedError();
}

Future<String> muteUserFromPlatform(
  String username,
  String author,
  String? postingKey,
  String? authKey,
  String? token,
) {
  throw UnimplementedError();
}
