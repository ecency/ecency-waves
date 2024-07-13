import 'dart:convert';
import 'package:waves/core/utilities/enum.dart';

class BroadcastModel<T> {
  final BroadCastType type;
  final T data;

  const BroadcastModel({required this.type, required this.data});
}

class VoteBroadCastModel {
  final String voter;
  final String author;
  final String permlink;
  final double weight;

  const VoteBroadCastModel(
      {required this.voter,
      required this.author,
      required this.permlink,
      required this.weight});

  Map<String, dynamic> toJson() {
    return {
      'voter': voter,
      'author': author,
      'permlink': permlink,
      'weight': weight,
    };
  }
}

class CommentBroadCastModel {
  final String parentAuthor;
  final String parentPermlink;
  final String username;
  final String permlink;
  final String comment;

  const CommentBroadCastModel(
      {required this.parentAuthor,
      required this.parentPermlink,
      required this.username,
      required this.permlink,
      required this.comment});

  Map<String, dynamic> toJson() {
    return {
      'parent_author': parentAuthor,
      'parent_permlink': parentPermlink,
      'author': username,
      'permlink': permlink,
      'title': "",
      'body': comment,
      'json_metadata': json.encode({
        'tags': [
          "ecency",
          "ios",
          "android",
          "mobile",
          "app",
          "spknetwork",
          "sagarkothari88",
          "comment",
          "reply",
        ],
        'app': "Ecency-Waves",
        'format': "markdown+html",
      }),
    };
  }
}
