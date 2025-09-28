import 'package:waves/core/utilities/enum.dart';

class SignTransactionNavigationModel {
  final String author;
  final String? permlink;
  final String? comment;
  final List<String>? imageLinks;
  final String? pollId;
  final List<int>? choices;
  final int? weight;
  final double? amount;
  final String? assetSymbol;
  final String? memo;
  final String? existingPermlink;
  final bool ishiveKeyChainMethod;
  final SignTransactionType transactionType;
  final List<String>? baseTags;
  final String? metadataApp;
  final String? metadataFormat;
  final bool? follow;

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
    this.existingPermlink,
    this.baseTags,
    this.metadataApp,
    this.metadataFormat,
    required this.transactionType,
    required this.ishiveKeyChainMethod,
    this.follow,
  });
}
