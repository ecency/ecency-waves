import 'dart:convert';

class ImageUploadErrorResponse {
  final ErrorMessage? error;

  ImageUploadErrorResponse({
    this.error,
  });

  ImageUploadErrorResponse copyWith({
    ErrorMessage? error,
  }) =>
      ImageUploadErrorResponse(
        error: error ?? this.error,
      );

  factory ImageUploadErrorResponse.fromJson(Map<String, dynamic> json) =>
      ImageUploadErrorResponse(
        error:
            json["error"] == null ? null : ErrorMessage.fromJson(json["error"]),
      );

  Map<String, dynamic> toJson() => {
        "error": error?.toJson(),
      };

  static ImageUploadErrorResponse fromJsonString(String str) =>
      ImageUploadErrorResponse.fromJson(json.decode(str));
}

class ErrorMessage {
  final String message;

  ErrorMessage({
    required this.message,
  });

  ErrorMessage copyWith({
    String? message,
  }) =>
      ErrorMessage(
        message: message ?? this.message,
      );

  factory ErrorMessage.fromJson(Map<String, dynamic> json) => ErrorMessage(
        message: json["name"] ?? "Something went wrong",
      );

  Map<String, dynamic> toJson() => {
        "name": message,
      };
}
