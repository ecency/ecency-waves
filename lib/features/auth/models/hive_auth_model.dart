import 'dart:convert';

class HiveAuthModel  {
  final String authKey;
  final String token;
  final int expiry;

  HiveAuthModel({
    required this.authKey,
    required this.token,
    required this.expiry,
  });

  factory HiveAuthModel.fromJson(Map<String, dynamic> json) {
    return HiveAuthModel(
      authKey: json['authKey'],
      token: json['token'],
      expiry: json['expiry'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authKey': authKey,
      'token': token,
      'expiry': expiry,
    };
  }

  factory HiveAuthModel.fromJsonString(String jsonString) {
    return HiveAuthModel.fromJson(json.decode(jsonString));
  }

  String toJsonString() {
    return json.encode(toJson());
  }

  HiveAuthModel copyWith({
    String? authKey,
    String? token,
    int? expiry,
  }) {
    return HiveAuthModel(
      authKey: authKey ?? this.authKey,
      token: token ?? this.token,
      expiry: expiry ?? this.expiry,
    );
  }
}
