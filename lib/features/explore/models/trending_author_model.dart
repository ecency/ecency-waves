import 'package:waves/core/utilities/save_convert.dart';

class TrendingAuthorModel {
  final String author;
  final int posts;

  TrendingAuthorModel({required this.author, required this.posts});

  factory TrendingAuthorModel.fromJson(Map<String, dynamic> json) {
    return TrendingAuthorModel(
      author: json['author'] as String,
      posts: asInt(json, 'posts'),
    );
  }
}
