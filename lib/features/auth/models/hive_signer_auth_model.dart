import 'dart:convert';

class HiveSignerAuthModel {
  final String token;

  HiveSignerAuthModel({required this.token});

  factory HiveSignerAuthModel.fromJson(Map<String, dynamic> json) {
    return HiveSignerAuthModel(
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
    };
  }

  factory HiveSignerAuthModel.fromJsonString(String jsonString) {
    return HiveSignerAuthModel.fromJson(json.decode(jsonString));
  }

  String toJsonString() {
    return json.encode(toJson());
  }

  HiveSignerAuthModel copyWith({String? token}) {
    return HiveSignerAuthModel(
      token: token ?? this.token,
    );
  }

}
