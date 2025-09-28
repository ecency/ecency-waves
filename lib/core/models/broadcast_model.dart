import 'dart:convert';
import 'package:waves/core/utilities/enum.dart';

class BroadcastModel<T> {
  final BroadCastType type;
  final T data;

  const BroadcastModel({required this.type, required this.data});

  Map<String, dynamic> toJson() {
    return _toJson(data);
  }

  Map<String, dynamic> _toJson(T model) {
    if (model is VoteBroadCastModel) {
      return model.toJson();
    } else if (model is CommentBroadCastModel) {
      return model.toJson();
    } else if (model is MuteBroadcastModel) {
      return model.toJson();
    } else if (model is TransferBroadcastModel) {
      return model.toJson();
    } else if (model is FollowBroadcastModel) {
      return model.toJson();
    } else {
      throw Exception('Unknown type');
    }
  }
}

class VoteBroadCastModel {
  final String voter;
  final String author;
  final String permlink;
  final int weight;

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

class PollVoteBroadcastModel {
  final String username;
  final String pollId;
  final List<int> choices;

  const PollVoteBroadcastModel({
    required this.username,
    required this.pollId,
    required this.choices
  });


  Map<String, dynamic> toJson() {
    return {
      "id": "polls",
      "required_posting_auths": [username],
      "json": json.encode(
        {
         "poll": pollId, 
         "action": "vote", 
         "choices": choices
        }
      )
    };
  }
}

class CommentBroadCastModel {
  final String parentAuthor;
  final String parentPermlink;
  final String username;
  final String permlink;
  final String comment;
  final List<String> tags;
  final String app;
  final String format;

  const CommentBroadCastModel({
    required this.parentAuthor,
    required this.parentPermlink,
    required this.username,
    required this.permlink,
    required this.comment,
    List<String>? tags,
    String? app,
    String? format,
  })  : tags = tags ?? const ["hive-125125", "waves", "ecency", "mobile", "thread"],
        app = app ?? "ecency-waves",
        format = format ?? "markdown+html";

  Map<String, dynamic> toJson() {
    return {
      'parent_author': parentAuthor,
      'parent_permlink': parentPermlink,
      'author': username,
      'permlink': permlink,
      'title': "",
      'body': comment,
      'json_metadata': json.encode({
        'tags': tags,
        'app': app,
        'format': format,
      }),
    };
  }
}

class MuteBroadcastModel {
  final String username;
  final String author;

  const MuteBroadcastModel({
    required this.username,
    required this.author,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": "follow",
      "required_posting_auths": [username],
      "json": json.encode([
        "follow",
        {
          "follower": username,
          "following": author,
          "what": ["ignore"]
        }
      ])
    };
  }
}

class FollowBroadcastModel {
  final String username;
  final String author;
  final bool follow;

  const FollowBroadcastModel({
    required this.username,
    required this.author,
    required this.follow,
  });

  Map<String, dynamic> toJson() {
    final List<String> what = follow ? ["blog"] : <String>[];
    return {
      "id": "follow",
      "required_posting_auths": [username],
      "json": json.encode([
        "follow",
        {
          "follower": username,
          "following": author,
          "what": what,
        }
      ])
    };
  }
}

class TransferBroadcastModel {
  final String from;
  final String to;
  final String amount;
  final String assetSymbol;
  final String memo;

  const TransferBroadcastModel({
    required this.from,
    required this.to,
    required this.amount,
    required this.assetSymbol,
    required this.memo,
  });

  Map<String, dynamic> toJson() {
    return {
      'from': from,
      'to': to,
      'amount': '${amount} $assetSymbol',
      'memo': memo,
    };
  }
}
