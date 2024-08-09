import 'dart:convert';

import 'package:waves/core/utilities/enum.dart';

class PollModel {
  final String author;
  final DateTime created;
  final String permlink;
  final String parentPermlink;
  final String parentAuthor;
  final String? image;
  final double protocolVersion;
  final String question;
  final String preferredInterpretation;
  final String? token;
  final DateTime endTime;
  final String status;
  final int maxChoicesVoted;
  final int filterAccountAgeDays;
  final bool uiHideResUntilVoted;
  final String pollTrxId;
  final List<PollChoice> pollChoices;
  final List<PollVoter> pollVoters;
  final PollStats pollStats;

  PollModel({
    required this.author,
    required this.created,
    required this.permlink,
    required this.parentPermlink,
    required this.parentAuthor,
    this.image,
    required this.protocolVersion,
    required this.question,
    required this.preferredInterpretation,
    this.token,
    required this.endTime,
    required this.status,
    required this.maxChoicesVoted,
    required this.filterAccountAgeDays,
    required this.uiHideResUntilVoted,
    required this.pollTrxId,
    required this.pollChoices,
    required this.pollVoters,
    required this.pollStats,
  });

  static List<PollModel> fromJsonString(String str) =>
      List<PollModel>.from(json.decode(str).map((x) => PollModel.fromJson(x)));

  factory PollModel.fromJson(Map<String, dynamic> json) {
    return PollModel(
      author: json['author'],
      created: DateTime.parse(json['created']),
      permlink: json['permlink'],
      parentPermlink: json['parent_permlink'],
      parentAuthor: json['parent_author'],
      image: json['image'],
      protocolVersion: json['protocol_version'].toDouble(),
      question: json['question'],
      preferredInterpretation: json['preferred_interpretation'],
      token: json['token'],
      endTime: DateTime.parse(json['end_time']),
      status: json['status'],
      maxChoicesVoted: json['max_choices_voted'],
      filterAccountAgeDays: json['filter_account_age_days'],
      uiHideResUntilVoted: json['ui_hide_res_until_voted'],
      pollTrxId: json['poll_trx_id'],
      pollChoices: (json['poll_choices'] as List<dynamic>)
          .map((e) => PollChoice.fromJson(e as Map<String, dynamic>))
          .toList(),
      pollVoters: (json['poll_voters'] as List<dynamic>)
          .map((e) => PollVoter.fromJson(e as Map<String, dynamic>))
          .toList(),
      pollStats: PollStats.fromJson(json['poll_stats'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'author': author,
      'created': created.toIso8601String(),
      'permlink': permlink,
      'parent_permlink': parentPermlink,
      'parent_author': parentAuthor,
      'image': image,
      'protocol_version': protocolVersion,
      'question': question,
      'preferred_interpretation': preferredInterpretation,
      'token': token,
      'end_time': endTime.toIso8601String(),
      'status': status,
      'max_choices_voted': maxChoicesVoted,
      'filter_account_age_days': filterAccountAgeDays,
      'ui_hide_res_until_voted': uiHideResUntilVoted,
      'poll_trx_id': pollTrxId,
      'poll_choices': pollChoices.map((e) => e.toJson()).toList(),
      'poll_voters': pollVoters.map((e) => e.toJson()).toList(),
      'poll_stats': pollStats.toJson(),
    };
  }
}

class PollChoice {
  final int choiceNum;
  final String choiceText;
  final Votes? votes;

  PollChoice({
    required this.choiceNum,
    required this.choiceText,
    this.votes,
  });

  factory PollChoice.fromJson(Map<String, dynamic> json) {
    return PollChoice(
      choiceNum: json['choice_num'],
      choiceText: json['choice_text'],
      votes: json['votes'] != null
          ? Votes.fromJson(json['votes'] as Map<String, dynamic>)
          : null,
    );
  }

  static List<PollChoice> fromValues(List<String> values) {
    return values
        .asMap()
        .entries
        .map((entry) => PollChoice(
              choiceNum: entry.key + 1,
              choiceText: entry.value,
              votes: null,
            ))
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'choice_num': choiceNum,
      'choice_text': choiceText,
      'votes': votes?.toJson(),
    };
  }
}

class Votes {
  final int totalVotes;
  final double hiveHp;
  final double hiveProxiedHp;
  final double hiveHpInclProxied;
  final double splSpsp;
  final String? heToken;

  Votes({
    required this.totalVotes,
    required this.hiveHp,
    required this.hiveProxiedHp,
    required this.hiveHpInclProxied,
    required this.splSpsp,
    this.heToken,
  });

  factory Votes.fromJson(Map<String, dynamic> json) {
    return Votes(
      totalVotes: json['total_votes'],
      hiveHp: json['hive_hp'].toDouble(),
      hiveProxiedHp: json['hive_proxied_hp'].toDouble(),
      hiveHpInclProxied: json['hive_hp_incl_proxied'].toDouble(),
      splSpsp: json['spl_spsp'].toDouble(),
      heToken: json['he_token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_votes': totalVotes,
      'hive_hp': hiveHp,
      'hive_proxied_hp': hiveProxiedHp,
      'hive_hp_incl_proxied': hiveHpInclProxied,
      'spl_spsp': splSpsp,
      'he_token': heToken,
    };
  }
}

class PollVoter {
  final String name;
  final List<int> choices;
  final double hiveHp;
  final String? heToken;
  final double splSpsp;
  final double hiveProxiedHp;
  final double hiveHpInclProxied;

  PollVoter({
    required this.name,
    required this.choices,
    required this.hiveHp,
    this.heToken,
    required this.splSpsp,
    required this.hiveProxiedHp,
    required this.hiveHpInclProxied,
  });

  factory PollVoter.fromJson(Map<String, dynamic> json) {
    return PollVoter(
      name: json['name'],
      choices: List<int>.from(json['choices']),
      hiveHp: json['hive_hp'].toDouble(),
      heToken: json['he_token'],
      splSpsp: json['spl_spsp'].toDouble(),
      hiveProxiedHp: json['hive_proxied_hp'].toDouble(),
      hiveHpInclProxied: json['hive_hp_incl_proxied'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'choices': choices,
      'hive_hp': hiveHp,
      'he_token': heToken,
      'spl_spsp': splSpsp,
      'hive_proxied_hp': hiveProxiedHp,
      'hive_hp_incl_proxied': hiveHpInclProxied,
    };
  }
}

class PollStats {
  final int totalVotingAccountsNum;
  final double totalHiveHp;
  final double totalHiveProxiedHp;
  final double totalHiveHpInclProxied;
  final double totalSplSpsp;
  final String? totalHeToken;

  PollStats({
    required this.totalVotingAccountsNum,
    required this.totalHiveHp,
    required this.totalHiveProxiedHp,
    required this.totalHiveHpInclProxied,
    required this.totalSplSpsp,
    this.totalHeToken,
  });

  factory PollStats.fromJson(Map<String, dynamic> json) {
    return PollStats(
      totalVotingAccountsNum: json['total_voting_accounts_num'],
      totalHiveHp: json['total_hive_hp'].toDouble(),
      totalHiveProxiedHp: json['total_hive_proxied_hp'].toDouble(),
      totalHiveHpInclProxied: json['total_hive_hp_incl_proxied'].toDouble(),
      totalSplSpsp: json['total_spl_spsp'].toDouble(),
      totalHeToken: json['total_he_token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_voting_accounts_num': totalVotingAccountsNum,
      'total_hive_hp': totalHiveHp,
      'total_hive_proxied_hp': totalHiveProxiedHp,
      'total_hive_hp_incl_proxied': totalHiveHpInclProxied,
      'total_spl_spsp': totalSplSpsp,
      'total_he_token': totalHeToken,
    };
  }
}
