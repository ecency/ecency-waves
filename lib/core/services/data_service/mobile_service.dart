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
  String account,
) async {
  final String id = 'validatePostingKey${DateTime.now().toIso8601String()}';
  final String response = await platform.invokeMethod('validatePostingKey', {
    'id': id,
    'username': username,
    'postingKey': postingKey,
    'account': account,
  });
  return response;
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
) async {
  final String id = 'commentOnContent${DateTime.now().toIso8601String()}';
  final String response = await platform.invokeMethod('commentOnContent', {
    'id': id,
    'username': username,
    'author': author,
    'parentPermlink': parentPermlink,
    'permlink': permlink,
    'comment': base64.encode(utf8.encode(comment)),
    'tags': tags,
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
  int weight,
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
    'weight': weight,
    'postingKey': postingKey ?? '',
    'token': token ?? '',
    'authKey': authKey ?? '',
  });
  return response;
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
) async {
  final String id = 'transfer${DateTime.now().toIso8601String()}';
  final String response = await platform.invokeMethod('transfer', {
    'id': id,
    'username': username,
    'to': to,
    'amount': amount,
    'asset': asset,
    'memo': memo,
    'postingKey': postingKey ?? '',
    'token': token ?? '',
    'authKey': authKey ?? '',
  });
  return response;
}

//ADD custom json support for vote poll support here

Future<String> getImageUploadProofWithPostingKeyFromPlatform(
  String username,
  String postingKey,
) async {
  final String id =
      'getImageUploadProofWithPostingKey${DateTime.now().toIso8601String()}';
  final String response =
      await platform.invokeMethod('getImageUploadProofWithPostingKey', {
    'id': id,
    'username': username,
    'postingKey': postingKey,
  });
  return response;
}

Future<String> muteUserFromPlatform(
  String username,
  String author,
  String? postingKey,
  String? authKey,
  String? token,
) async {
  final String id = 'muteUser${DateTime.now().toIso8601String()}';
  final String response = await platform.invokeMethod('muteUser', {
    'id': id,
    'username': username,
    'author': author,
    'postingKey': postingKey ?? '',
    'token': token ?? '',
    'authKey': authKey ?? '',
  });
  return response;
}

Future<String> setFollowStatusFromPlatform(
  String username,
  String author,
  bool follow,
  String? postingKey,
  String? authKey,
  String? token,
) async {
  final String id = 'followUser${DateTime.now().toIso8601String()}';
  final String response = await platform.invokeMethod('followUser', {
    'id': id,
    'username': username,
    'author': author,
    'follow': follow,
    'postingKey': postingKey ?? '',
    'token': token ?? '',
    'authKey': authKey ?? '',
  });
  return response;
}

Future<String> updateFollowStatusFromPlatform(
  String username,
  String author,
  bool follow,
  String? postingKey,
  String? authKey,
  String? token,
) async {
  final String id = 'followUser${DateTime.now().toIso8601String()}';
  final String response = await platform.invokeMethod('followUser', {
    'id': id,
    'username': username,
    'author': author,
    'follow': follow,
    'postingKey': postingKey ?? '',
    'token': token ?? '',
    'authKey': authKey ?? '',
  });
  return response;
}

Future<String> setFollowStatusFromPlatform(
  String username,
  String author,
  bool follow,
  String? postingKey,
  String? authKey,
  String? token,
) async {
  final String id = 'followUser${DateTime.now().toIso8601String()}';
  final String response = await platform.invokeMethod('followUser', {
    'id': id,
    'username': username,
    'author': author,
    'follow': follow,
    'postingKey': postingKey ?? '',
    'token': token ?? '',
    'authKey': authKey ?? '',
  });
  return response;
}

Future<String> setFollowStatusFromPlatform(
  String username,
  String author,
  bool follow,
  String? postingKey,
  String? authKey,
  String? token,
) async {
  final String id = 'followUser${DateTime.now().toIso8601String()}';
  final String response = await platform.invokeMethod('followUser', {
    'id': id,
    'username': username,
    'author': author,
    'follow': follow,
    'postingKey': postingKey ?? '',
    'token': token ?? '',
    'authKey': authKey ?? '',
  });
  return response;
}

Future<String> castPollVoteFromPlatform(
  String username,
  String pollId,
  List<int> choices,
  String? postingKey,
  String? authKey,
  String? token,
) async {
  final String id = 'castPollVote${DateTime.now().toIso8601String()}';
  final String response = await platform.invokeMethod('castPollVote', {
    'id': id,
    'username': username,
    'pollId': pollId,
    'choices': choices,
    'postingKey': postingKey ?? '',
    'token': token ?? '',
    'authKey': authKey ?? ''
  });
  return response;
}
