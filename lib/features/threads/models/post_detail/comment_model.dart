import 'dart:convert';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';

class CommentModel {
  static List<ThreadFeedModel> fromRawJson(String str) =>
      CommentModel.parseComments(json.decode(str));

  static List<ThreadFeedModel> parseComments(Map<String, dynamic>? json) {
    try {
      List<ThreadFeedModel> items = [];
      if (json != null) {
        json.forEach((key, value) {
            items.add(ThreadFeedModel.fromJson(value));
        });
      }
      return items;
    } catch (e) {
      rethrow;
    }
  }
}
