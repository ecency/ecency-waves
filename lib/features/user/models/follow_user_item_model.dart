class FollowUserItemModel {
  final String name;

  FollowUserItemModel({required this.name});

  factory FollowUserItemModel.fromFollowerJson(Map<String, dynamic> json) {
    final follower = json['follower'];
    return FollowUserItemModel(name: follower is String ? follower : '');
  }

  factory FollowUserItemModel.fromFollowingJson(Map<String, dynamic> json) {
    final following = json['following'];
    return FollowUserItemModel(name: following is String ? following : '');
  }
}
