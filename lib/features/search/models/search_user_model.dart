class SearchUserModel {
  final String name;

  SearchUserModel({required this.name});

  factory SearchUserModel.fromName(String name) {
    return SearchUserModel(name: name);
  }
}
