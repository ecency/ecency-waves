class AuthRedirectionResponse {
  final String authKey;
  final String encryptedData;

  AuthRedirectionResponse({
    required this.authKey,
    required this.encryptedData,
  });

  factory AuthRedirectionResponse.fromJson(Map<String, dynamic> json) {
    return AuthRedirectionResponse(
        authKey: json['auth_key'], encryptedData: json['encrypted_data']);
  }
}
