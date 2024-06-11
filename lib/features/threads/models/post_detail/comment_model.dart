import 'dart:convert';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';

class CommentModel {
  static List<ThreadFeedModel> fromRawJson(String str) =>
      CommentModel.parseComments(json.decode(str)['data']);

  static List<ThreadFeedModel> parseComments(Map<String, dynamic>? json) {
    try {
      List<ThreadFeedModel> items = [];
      if (json != null) {
        int count = 0;
        json.forEach((key, value) {
          if (count != 0) {
            items.add(ThreadFeedModel.fromJson(value));
          }
          count++;
        });
      }
      return items;
    } catch (e) {
      rethrow;
    }
  }
}
