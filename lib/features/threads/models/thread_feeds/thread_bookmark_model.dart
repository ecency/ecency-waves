import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';

class ThreadBookmarkModel {
  final String id;
  final String author;
  final String permlink;

  ThreadBookmarkModel(
      {required this.id, required this.author, required this.permlink});

  factory ThreadBookmarkModel.fromJson(Map<String, dynamic> json) {
    return ThreadBookmarkModel(
      author: json['author'],
      permlink: json['permlink'],
      id: json['id'],
    );
  }

  static Map<String, dynamic> toJson(ThreadFeedModel item) {
    return {
      'author': item.author,
      'permlink': item.permlink,
      'id': item.postId.toString()
    };
  }
}
