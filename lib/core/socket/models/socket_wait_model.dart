import 'dart:convert';

class SocketWaitModel {
  final String accountName;
  final String uuid;
  final String authKey;
  final String host;

  const SocketWaitModel(
      {required this.accountName,
      required this.uuid,
      required this.authKey,
      required this.host});

  Map<String, dynamic> toJson() {
    return {
      "account": accountName,
      "uuid": uuid,
      "key": authKey,
      "host": host
    };
  }

  String toJsonString() => json.encode(toJson());
}
