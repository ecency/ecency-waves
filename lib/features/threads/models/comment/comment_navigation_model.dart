import 'package:waves/core/utilities/enum.dart';

class SignTransactionNavigationModel {
  final String author;
  final String? permlink;
  final String? comment;
  final List<String>? imageLinks;
  final String? pollId;
  final List<int>? choices;
  final double? weight;
  final bool ishiveKeyChainMethod;
  final SignTransactionType transactionType;

  SignTransactionNavigationModel({
    required this.author,
    this.permlink,
    this.imageLinks,
    this.pollId,
    this.choices,
    this.comment,
    this.weight,
    required this.transactionType,
    required this.ishiveKeyChainMethod,
  });
}
