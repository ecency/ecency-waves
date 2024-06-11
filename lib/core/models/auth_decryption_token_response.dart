import 'package:waves/core/utilities/save_convert.dart';

class AuthDecryptionResponse {
  final String? token;
  final int? expire;

  AuthDecryptionResponse({
    required this.token,
    required this.expire,
  });

  factory AuthDecryptionResponse.fromJson(Map<String, dynamic> json) {
    return AuthDecryptionResponse(
        token: json['token'], expire: asInt(json, 'expire'));
  }
}
