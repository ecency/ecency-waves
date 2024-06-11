import 'dart:convert';

class PostingAuthModel {
  final String postingKey;

  PostingAuthModel({required this.postingKey});

  factory PostingAuthModel.fromJson(Map<String, dynamic> json) {
    return PostingAuthModel(
      postingKey: json['postingKey'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postingKey': postingKey,
    };
  }

  factory PostingAuthModel.fromJsonString(String jsonString) {
    return PostingAuthModel.fromJson(json.decode(jsonString));
  }

  String toJsonString() {
    return json.encode(toJson());
  }

  PostingAuthModel copyWith({String? postingKey}) {
    return PostingAuthModel(
      postingKey: postingKey ?? this.postingKey,
    );
  }

}
