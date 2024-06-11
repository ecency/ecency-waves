import 'dart:convert';

import 'package:waves/core/utilities/enum.dart';

class SocketSignRequestModel {
  final String command = enumToString(SocketInputType.sign_req);
  final String accountName;
  final String token;
  final String data;

  SocketSignRequestModel(
      {required this.accountName, required this.token,required this.data});

  Map<String, dynamic> toJson() {
    return {
      "cmd": command,
      "account": accountName,
      "token": token,
      "data": data,
    };
  }

  String toJsonString() => json.encode(toJson());
}
