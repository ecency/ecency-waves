import 'dart:convert';

import 'package:waves/core/utilities/constants/server_constants.dart';

class SocketWaitModel {
  final String accountName;
  final String uuid;
  final String authKey;
  final String host = socketServer;

  const SocketWaitModel(
      {required this.accountName, required this.uuid, required this.authKey});

  Map<String, dynamic> toJson() {
    return {"account": accountName, "uuid": uuid, "key": authKey, "host": host};
  }

  String toJsonString() => json.encode(toJson());
}
