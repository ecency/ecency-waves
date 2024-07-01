import 'dart:convert';

class FollowCountModel {
  final String? account;
  final int? followerCount;
  final int? followingCount;

  FollowCountModel({
    this.account,
    this.followerCount,
    this.followingCount,
  });

  FollowCountModel copyWith({
    String? account,
    int? followerCount,
    int? followingCount,
  }) =>
      FollowCountModel(
        account: account ?? this.account,
        followerCount: followerCount ?? this.followerCount,
        followingCount: followingCount ?? this.followingCount,
      );

  factory FollowCountModel.fromJson(Map<String, dynamic> json) =>
      FollowCountModel(
        account: json["account"],
        followerCount: json["follower_count"],
        followingCount: json["following_count"],
      );

  Map<String, dynamic> toJson() => {
        "account": account,
        "follower_count": followerCount,
        "following_count": followingCount,
      };

  factory FollowCountModel.fromJsonString(String string) =>
      FollowCountModel.fromJson(json.decode(string));
}
