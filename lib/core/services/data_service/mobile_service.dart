import 'dart:convert';

import 'package:flutter/services.dart';

const String channel = 'bridge';
const platform = MethodChannel(channel);

Future<String> runThisJS_(String jsCode) async {
  final String reqId = 'runThisJS_${DateTime.now().toIso8601String()}';
  final String response = await platform.invokeMethod('runThisJS', {
    'id': reqId,
    'jsCode': jsCode,
  });
  return response;
}

Future<String> getRedirectUriDataFromPlatform(String username) async {
  final String id = 'getRedirectUriData_${DateTime.now().toIso8601String()}';
  final String response = await platform.invokeMethod('getRedirectUriData', {
    'id': id,
    'username': username,
  });
  return response;
}

Future<String> getDecryptedHASTokenFromPlatform(
    String username, String encryptedData, String authKey) async {
  final String id = 'getDecryptedHASToken_${DateTime.now().toIso8601String()}';
  final String response = await platform.invokeMethod('getDecryptedHASToken', {
    'id': id,
    'username': username,
    'encryptedData': encryptedData,
    'authKey': authKey,
  });
  return response;
}

Future<String> validatePostingKeyFromPlatform(
  String username,
  String postingKey,
) async {
  final String id = 'validatePostingKey${DateTime.now().toIso8601String()}';
  final String response = await platform.invokeMethod('validatePostingKey', {
    'id': id,
    'username': username,
    'postingKey': postingKey,
  });
  return response;
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
  final String id = 'commentOnContent${DateTime.now().toIso8601String()}';
  final String response = await platform.invokeMethod('commentOnContent', {
    'id': id,
    'username': username,
    'author': author,
    'parentPermlink': parentPermlink,
    'permlink': permlink,
    'comment': base64.encode(utf8.encode(comment)),
    'postingKey': postingKey ?? '',
    'token': token ?? '',
    'authKey': authKey ?? '',
  });
  return response;
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
  final String id = 'voteContent${DateTime.now().toIso8601String()}';
  final String response = await platform.invokeMethod('voteContent', {
    'id': id,
    'username': username,
    'author': author,
    'permlink': permlink,
    'weight': weight.toInt(),
    'postingKey': postingKey ?? '',
    'token': token ?? '',
    'authKey': authKey ?? '',
  });
  return response;
}

Future<String> getImageUploadProofWithPostingKeyFromPlatform(
  String username,
  String postingKey,
) async {
  final String id = 'getImageUploadProofWithPostingKey${DateTime.now().toIso8601String()}';
  final String response = await platform.invokeMethod('getImageUploadProofWithPostingKey', {
    'id': id,
    'username': username,
    'postingKey': postingKey,
  });
  return response;
}


