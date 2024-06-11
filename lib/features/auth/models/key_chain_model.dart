import 'dart:convert';

class KeyChainModel  {
  final String message;
  final String signedBuffer;

  KeyChainModel({required this.message, required this.signedBuffer});

  factory KeyChainModel.fromJson(Map<String, dynamic> json) {
    return KeyChainModel(
      message: json['message'],
      signedBuffer: json['signedBuffer'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'signedBuffer': signedBuffer,
    };
  }

  factory KeyChainModel.fromJsonString(String jsonString) {
    return KeyChainModel.fromJson(json.decode(jsonString));
  }

  String toJsonString() {
    return json.encode(toJson());
  }

  KeyChainModel copyWith({
    String? message,
    String? signedBuffer,
  }) {
    return KeyChainModel(
      message: message ?? this.message,
      signedBuffer: signedBuffer ?? this.signedBuffer,
    );
  }
}
