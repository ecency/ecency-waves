import 'dart:convert';
import 'package:waves/core/utilities/save_convert.dart';
import 'package:waves/features/threads/models/post_detail/post_detail_model.dart';
import 'package:waves/features/threads/models/thread_feeds/beneficiary_model.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_json_meta_data/thread_json_meta_data.dart';

class ThreadFeedModel {
  final int postId;
  final String author;
  final String? permlink;
  final String? category;
  final String title;
  final String body;
  final ThreadJsonMetadata? jsonMetadata;
  final DateTime? created;
  final DateTime? lastUpdate;
  final int? depth;
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

  ThreadFeedModel({
    required this.postId,
    required this.author,
    this.permlink,
    this.category,
    required this.title,
    required this.body,
    this.jsonMetadata,
    this.created,
    this.lastUpdate,
    this.depth,
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
  });

  ThreadFeedModel copyWith({
    int? postId,
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
  }) =>
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
      );

  factory ThreadFeedModel.fromJson(Map<String, dynamic> json) =>
      ThreadFeedModel(
        postId: json["post_id"],
        author: asString(json, "author"),
        permlink: json["permlink"],
        category: json["category"],
        title: asString(json, "title"),
        body: asString(json, "body"),
        jsonMetadata: _parseJsonMetaData(json['json_metadata']),
        created: DateTime.parse(json["created"]),
        lastUpdate: DateTime.parse(json["last_update"]),
        depth: json["depth"],
        children: json["children"],
        netRshares: json["net_rshares"],
        lastPayout: DateTime.parse(json["last_payout"]),
        cashoutTime: DateTime.parse(json["cashout_time"]),
        totalPayoutValue: json["total_payout_value"],
        curatorPayoutValue: json["curator_payout_value"],
        pendingPayoutValue: json["pending_payout_value"],
        promoted: json["promoted"],
        replies: List<dynamic>.from(json["replies"].map((x) => x)),
        bodyLength: json["body_length"],
        authorReputation: json['author_reputation'],
        activeVotes: List<ActiveVoteModel>.from(
            json["active_votes"].map((x) => ActiveVoteModel.fromJson(x))),
        parentAuthor: json["parent_author"],
        parentPermlink: json["parent_permlink"],
        url: json["url"],
        rootTitle: json["root_title"],
        beneficiaries: List<BeneficiaryModel>.from(
            json["beneficiaries"].map((x) => BeneficiaryModel.fromJson(x))),
        maxAcceptedPayout: json["max_accepted_payout"],
        percentHBD: json["percent_hbd"],
      );

  static ThreadJsonMetadata? _parseJsonMetaData(dynamic data) {
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
}
