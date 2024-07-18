import 'package:equatable/equatable.dart';

class ThreadInfo extends Equatable {
  final String author;
  final String permlink;

  const ThreadInfo({required this.author, required this.permlink});
  
  @override
  List<Object?> get props => [author,permlink];
}
