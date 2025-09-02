import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:waves/core/utilities/save_convert.dart';
import 'package:waves/features/threads/models/post_detail/upvote_model.dart';
import 'package:waves/features/threads/models/thread_feeds/beneficiary_model.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_json_meta_data/thread_json_meta_data.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_stats.dart';

class ThreadFeedModel extends Equatable {
  final int postId;
  final String author;
  final String permlink;
  final String category;
  final String title;
  final String body;
  final ThreadJsonMetadata? jsonMetadata;
  final DateTime created;
  final DateTime? lastUpdate;
  final int depth;
  final int? children;
  final int? netRshares;
  final DateTime? lastPayout;
  final DateTime? cashoutTime;
  final String? totalPayoutValue;
  final String? curatorPayoutValue;
  final String? pendingPayoutValue;
  final String? promoted;
  final List<dynamic>? replies;
  final int? bodyLength;
  final int? authorReputation;
  final List<ActiveVoteModel>? activeVotes;
  final String? parentAuthor;
  final String? parentPermlink;
  final String? url;
  final String? rootTitle;
  final List<BeneficiaryModel>? beneficiaries;
  final String? maxAcceptedPayout;
  final int? percentHBD;
  final ThreadStats? stats;
  final bool visited;

  const ThreadFeedModel({
    this.visited = false,
    required this.postId,
    required this.author,
    this.permlink = "",
    required this.category,
    required this.title,
    required this.body,
    this.jsonMetadata,
    required this.created,
    this.lastUpdate,
    this.depth = 1,
    this.children,
    this.netRshares,
    this.lastPayout,
    this.cashoutTime,
    this.totalPayoutValue,
    this.curatorPayoutValue,
    this.pendingPayoutValue,
    this.promoted,
    this.replies,
    this.bodyLength,
    this.authorReputation,
    this.activeVotes,
    this.parentAuthor,
    this.parentPermlink,
    this.url,
    this.rootTitle,
    this.beneficiaries,
    this.maxAcceptedPayout,
    this.percentHBD,
    this.stats,
  });

  ThreadFeedModel copyWith(
          {int? postId,
          String? author,
          String? permlink,
          String? category,
          String? title,
          String? body,
          ThreadJsonMetadata? jsonMetadata,
          DateTime? created,
          DateTime? lastUpdate,
          int? depth,
          int? children,
          int? netRshares,
          DateTime? lastPayout,
          DateTime? cashoutTime,
          String? totalPayoutValue,
          String? curatorPayoutValue,
          String? pendingPayoutValue,
          String? promoted,
          List<dynamic>? replies,
          int? bodyLength,
          int? authorReputation,
          List<ActiveVoteModel>? activeVotes,
          String? parentAuthor,
          String? parentPermlink,
          String? url,
          String? rootTitle,
          List<BeneficiaryModel>? beneficiaries,
          String? maxAcceptedPayout,
          int? percentHBD,
          ThreadStats? stats,
          bool? visited}) =>
      ThreadFeedModel(
        postId: postId ?? this.postId,
        author: author ?? this.author,
        permlink: permlink ?? this.permlink,
        category: category ?? this.category,
        title: title ?? this.title,
        body: body ?? this.body,
        jsonMetadata: jsonMetadata ?? this.jsonMetadata,
        created: created ?? this.created,
        lastUpdate: lastUpdate ?? this.lastUpdate,
        depth: depth ?? this.depth,
        children: children ?? this.children,
        netRshares: netRshares ?? this.netRshares,
        lastPayout: lastPayout ?? this.lastPayout,
        cashoutTime: cashoutTime ?? this.cashoutTime,
        totalPayoutValue: totalPayoutValue ?? this.totalPayoutValue,
        curatorPayoutValue: curatorPayoutValue ?? this.curatorPayoutValue,
        pendingPayoutValue: pendingPayoutValue ?? this.pendingPayoutValue,
        promoted: promoted ?? this.promoted,
        replies: replies ?? this.replies,
        bodyLength: bodyLength ?? this.bodyLength,
        authorReputation: authorReputation ?? this.authorReputation,
        activeVotes: activeVotes ?? this.activeVotes,
        parentAuthor: parentAuthor ?? this.parentAuthor,
        parentPermlink: parentPermlink ?? this.parentPermlink,
        url: url ?? this.url,
        rootTitle: rootTitle ?? this.rootTitle,
        beneficiaries: beneficiaries ?? this.beneficiaries,
        maxAcceptedPayout: maxAcceptedPayout ?? this.maxAcceptedPayout,
        percentHBD: percentHBD ?? this.percentHBD,
        stats: stats ?? this.stats,
        visited: visited ?? this.visited,
      );

  factory ThreadFeedModel.fromJson(Map<String, dynamic> json) =>
      ThreadFeedModel(
        postId: json["post_id"],
        author: asString(json, "author"),
        permlink: asString(json, "permlink"),
        category: asString(json, "category"),
        title: asString(json, "title"),
        body: asString(json, "body"),
        jsonMetadata: parseJsonMetaData(json['json_metadata']),
        created: DateTime.parse(_timeStamp(json["created"])).toLocal(),
        lastUpdate: json["last_update"] != null
            ? DateTime.parse(json["last_update"])
            : null,
        depth: json["depth"],
        children: json["children"],
        netRshares: json["net_rshares"],
        lastPayout: json["last_payout"] != null
            ? DateTime.parse(json["last_payout"])
            : null,
        cashoutTime: json["cashout_time"] != null
            ? DateTime.parse(json["cashout_time"])
            : null,
        totalPayoutValue: json["total_payout_value"],
        curatorPayoutValue: json["curator_payout_value"],
        pendingPayoutValue: json["pending_payout_value"],
        promoted: json["promoted"],
        replies: _parseReplies(json["replies"]),
        bodyLength: asInt(json, "body_length"),
        authorReputation: asInt(json, 'author_reputation'),
        activeVotes: json["active_votes"] != null
            ? List<ActiveVoteModel>.from((json["active_votes"] as List)
                .map((x) => ActiveVoteModel.fromJson(x)))
            : [],
        parentAuthor: json["parent_author"],
        parentPermlink: json["parent_permlink"],
        url: json["url"],
        rootTitle: json["root_title"],
        beneficiaries: List<BeneficiaryModel>.from(
            json["beneficiaries"].map((x) => BeneficiaryModel.fromJson(x))),
        maxAcceptedPayout: json["max_accepted_payout"],
        percentHBD: json["percent_hbd"],
        stats: ThreadStats.fromJson(json['stats']),
      );

  static List<dynamic> _parseReplies(dynamic value) {
    if (value is List) {
      return List<dynamic>.from(value.map((x) => x));
    }
    if (value is Map) {
      return List<dynamic>.from(value.values.map((x) => x));
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'post_id': postId,
      'author': author,
      'permlink': permlink,
      'category': category,
      'title': title,
      'body': body,
      'json_metadata': jsonMetadata?.toJson(),
      'created': created.toUtc().toIso8601String(),
      'last_update': lastUpdate?.toIso8601String(),
      'depth': depth,
      'children': children,
      'net_rshares': netRshares,
      'last_payout': lastPayout?.toIso8601String(),
      'cashout_time': cashoutTime?.toIso8601String(),
      'total_payout_value': totalPayoutValue,
      'curator_payout_value': curatorPayoutValue,
      'pending_payout_value': pendingPayoutValue,
      'promoted': promoted,
      'replies': replies,
      'body_length': bodyLength,
      'author_reputation': authorReputation,
      'active_votes': activeVotes?.map((vote) => vote.toJson()).toList(),
      'parent_author': parentAuthor,
      'parent_permlink': parentPermlink,
      'url': url,
      'root_title': rootTitle,
      'beneficiaries':
          beneficiaries?.map((beneficiary) => beneficiary.toJson()).toList(),
      'max_accepted_payout': maxAcceptedPayout,
      'percent_hbd': percentHBD,
      'stats': stats?.toJson(),
    };
  }

  static ThreadJsonMetadata? parseJsonMetaData(dynamic data) {
    if (data != null) {
      if (data is String) {
        Map<String, dynamic> map = json.decode(data);
        return ThreadJsonMetadata.fromJson(map);
      } else {
        if (data is Map) {
          return ThreadJsonMetadata.fromJson(data as Map<String, dynamic>);
        }
      }
    }
    return null;
  }

  static String _timeStamp(String data) {
    if (data.substring(data.length - 1).toLowerCase() != 'z') {
      return '${data}z';
    }
    return data;
  }

  List<String>? get images {
    List<String>? extractedImages = _extractImages();
    if (extractedImages != null) {
      return extractedImages;
    } else if (jsonMetadata != null &&
        jsonMetadata!.images != null &&
        jsonMetadata!.images!.isNotEmpty) {
      return jsonMetadata!.images;
    }
    return null;
  }

  String get identifier => "$author-$permlink";

  List<String>? _extractImages() {
    // 1) Match standard markdown image syntax ![alt](url)
    final markdownImageRegex =
        RegExp(r'!\[.*?\]\((https?:\/\/[^\s)]+)\)', caseSensitive: false);
    // 2) Match bare image URLs (png/jpg/jpeg/gif/webp) that are not part of markdown
    final rawImageRegex = RegExp(
        r'(?<!!\[.*?\]\()https?:\/\/[^)\s]+\.(?:png|jpe?g|gif|webp)',
        caseSensitive: false);

    final urls = <String>{};

    for (final match in markdownImageRegex.allMatches(body)) {
      urls.add(match.group(1)!);
    }

    for (final match in rawImageRegex.allMatches(body)) {
      urls.add(match.group(0)!);
    }

    return urls.isNotEmpty ? urls.toList() : null;
  }

  static List<ThreadFeedModel> fromRawJson(String str) =>
      ThreadFeedModel.parseThreads(json.decode(str));

  static String toRawJson(List<ThreadFeedModel> threads) {
    return json.encode(threads.map((e) => e.toJson()).toList());
  }

  static List<ThreadFeedModel> parseThreads(List? data) {
    try {
      if (data == null) return [];
      return data.map((e) => ThreadFeedModel.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  String get idString => postId.toString();

  @override
  List<Object?> get props => [
        postId,
        author,
        permlink,
        parentAuthor,
        parentPermlink,
        depth,
        activeVotes,
        children,
        body,
        title
      ];
}
