import 'package:waves/core/utilities/save_convert.dart';

class TrendingTagModel {
  final String tag;
  final int posts;

  TrendingTagModel({required this.tag, required this.posts});

  factory TrendingTagModel.fromJson(Map<String, dynamic> json) {
    return TrendingTagModel(
      tag: json['tag'] as String,
      posts: asInt(json, 'posts'),
    );
  }
}
