import 'package:equatable/equatable.dart';
import 'package:waves/core/utilities/save_convert.dart';

class ActiveVoteModel extends Equatable{
  final int percent;
  final int? reputation;
  final int? rshares;
  final DateTime? time;
  final String voter;
  final int? weight;

  const ActiveVoteModel({
    this.percent = 0,
    this.reputation,
    this.rshares,
    this.time,
    this.voter = "",
    this.weight,
  });

  ActiveVoteModel copyWith({
    int? percent,
    int? reputation,
    int? rshares,
    DateTime? time,
    String? voter,
    int? weight,
  }) =>
      ActiveVoteModel(
        percent: percent ?? this.percent,
        reputation: reputation ?? this.reputation,
        rshares: rshares ?? this.rshares,
        time: time ?? this.time,
        voter: voter ?? this.voter,
        weight: weight ?? this.weight,
      );

  factory ActiveVoteModel.fromJson(Map<String, dynamic> json) =>
      ActiveVoteModel(
        percent: asInt(json, 'percent'),
        reputation: json["reputation"],
        rshares: json["rshares"],
        time: json["time"] == null ? null : DateTime.parse(json["time"]),
        voter: asString(json, "voter"),
        weight: json["weight"],
      );

  Map<String, dynamic> toJson() => {
        "percent": percent,
        "reputation": reputation,
        "rshares": rshares,
        "time": time?.toIso8601String(),
        "voter": voter,
        "weight": weight,
      };
      
        @override
        List<Object?> get props => [voter,weight];
}
