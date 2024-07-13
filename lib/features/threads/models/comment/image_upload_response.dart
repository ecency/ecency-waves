import 'dart:convert';

class ImageUploadResponse {
  final String url;

  ImageUploadResponse({
    required this.url,
  });

  ImageUploadResponse copyWith({
    String? url,
  }) =>
      ImageUploadResponse(
        url: url ?? this.url,
      );

  factory ImageUploadResponse.fromJson(Map<String, dynamic> json) =>
      ImageUploadResponse(
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "url": url,
      };

  static ImageUploadResponse fromJsonString(String str) =>
      ImageUploadResponse.fromJson(json.decode(str));
}
