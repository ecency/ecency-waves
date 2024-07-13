import 'package:waves/core/utilities/save_convert.dart';

class AuthDecryptionResponse {
  final String? token;
  final int? expire;
  final String? hsToken;

  AuthDecryptionResponse({
    required this.token,
    required this.expire,
    required this.hsToken,
  });

  factory AuthDecryptionResponse.fromJson(Map<String, dynamic> json) {
    return AuthDecryptionResponse(
      token: asString(json, 'token'),
      expire: asInt(json, 'expire'),
      hsToken: asString(json, 'hsToken'),
    );
  }
}
