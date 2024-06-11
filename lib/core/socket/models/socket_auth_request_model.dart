import 'dart:convert';

import 'package:waves/core/utilities/enum.dart';

class SocketAuthRequestModel {
  final String command = enumToString(SocketInputType.auth_req);
  final String accountName;
  final String encryptedData;

  SocketAuthRequestModel(
      {required this.accountName, required this.encryptedData});

  Map<String, dynamic> toJson() {
    return {
      "cmd": command,
      "account": accountName,
      "data": encryptedData,
    };
  }

  String toJsonString() => json.encode(toJson());
}
