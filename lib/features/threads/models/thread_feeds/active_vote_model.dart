class ActiveVoteModel {
    final String voter;
    final int? rshares;
    final String? percent;

    ActiveVoteModel({
        required this.voter,
        required this.rshares,
        required this.percent,
    });

    ActiveVoteModel copyWith({
        String? voter,
        int? rshares,
        String? percent,
    }) => 
        ActiveVoteModel(
            voter: voter ?? this.voter,
            rshares: rshares ?? this.rshares,
            percent: percent ?? this.percent,
        );

    factory ActiveVoteModel.fromJson(Map<String, dynamic> json) => ActiveVoteModel(
        voter: json["voter"],
        rshares: json["rshares"],
        percent: json["percent"],
    );
}