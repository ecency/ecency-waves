import 'package:waves/core/utilities/save_convert.dart';

class SearchTagModel {
  final String name;
  final int totalPosts;

  SearchTagModel({required this.name, required this.totalPosts});

  factory SearchTagModel.fromJson(Map<String, dynamic> json) {
    return SearchTagModel(
      name: (json['name'] as String?) ?? '',
      totalPosts: asInt(json, 'total_posts'),
    );
  }
}
