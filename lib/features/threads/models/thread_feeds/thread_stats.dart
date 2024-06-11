import 'package:waves/core/utilities/save_convert.dart';

class ThreadStats {
  final bool? hide;
  final bool? gray;
  final int? totalVotes;
  final double? flagWeight;

  ThreadStats({
    this.hide = false,
    this.gray = false,
    this.totalVotes = 0,
    this.flagWeight = 0.0,
  });

  factory ThreadStats.fromJson(Map<String, dynamic>? json) => ThreadStats(
        hide: asBool(json, 'hide'),
        gray: asBool(json, 'gray'),
        totalVotes: asInt(json, 'total_votes'),
        flagWeight: asDouble(json, 'flag_weight'),
      );
}