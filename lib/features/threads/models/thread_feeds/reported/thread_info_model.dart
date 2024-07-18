import 'dart:convert';

import 'package:waves/features/threads/presentation/thread_feed/view_models/view_model.dart';

class ThreadInfoModel extends ThreadInfo {
  const ThreadInfoModel({required super.author, required super.permlink});

  factory ThreadInfoModel.fromJson(Map<String, dynamic> json) =>
      ThreadInfoModel(author: json['author'], permlink: json['permlink']);

  Map<String, dynamic> toJson() => {
        'author': author,
        'permlink': permlink,
      };

  static List<ThreadInfoModel> fromRawJsonList(String string) {
    List data = json.decode(string);
    return data.map((e) => ThreadInfoModel.fromJson(e)).toList();
  }

  static String toRawJsonList(List<ThreadInfoModel> threads) {
    return json.encode(threads.map((e) => e.toJson()).toList());
  }
}
