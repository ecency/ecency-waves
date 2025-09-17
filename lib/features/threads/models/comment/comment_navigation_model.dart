import 'package:waves/core/utilities/enum.dart';

class SignTransactionNavigationModel {
  final String author;
  final String? permlink;
  final String? comment;
  final List<String>? imageLinks;
  final String? pollId;
  final List<int>? choices;
  final double? weight;
  final double? amount;
  final String? assetSymbol;
  final String? memo;
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
    this.amount,
    this.assetSymbol,
    this.memo,
    required this.transactionType,
    required this.ishiveKeyChainMethod,
  });
}
