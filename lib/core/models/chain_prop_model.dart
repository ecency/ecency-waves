import 'dart:convert';

class ChainPropResponseModel {
  final String id;
  final String type;
  final ChainPropModel data;
  final bool valid;
  final String errorMessage;

  ChainPropResponseModel(
      {required this.id,
      required this.type,
      required this.data,
      required this.valid,
      required this.errorMessage});

  factory ChainPropResponseModel.fromJson(Map<String, dynamic> json) =>
      ChainPropResponseModel(
          id: json['id'],
          type: json['type'],
          data: ChainPropModel.fromRawJson(json['data']),
          valid: json['valid'],
          errorMessage: json['error']);
}

class ChainPropModel {
  final String accountCreationFee;
  final int maximumBlockSize;
  final int accountSubsidyBudget;
  final int accountSubsidyDecay;
  final int hbdInterestRate;

  ChainPropModel({
    required this.accountCreationFee,
    required this.maximumBlockSize,
    required this.accountSubsidyBudget,
    required this.accountSubsidyDecay,
    required this.hbdInterestRate
  });

  ChainPropModel copyWith({
    String? accountCreationFee,
    int? maximumBlockSize,
    int? accountSubsidyBudget,
    int? accountSubsidyDecay,
    int? hbdInterestRate,
  }) =>
      ChainPropModel(
        accountCreationFee: accountCreationFee ?? this.accountCreationFee,
        maximumBlockSize: maximumBlockSize ?? this.maximumBlockSize,
        accountSubsidyBudget: accountSubsidyBudget ?? this.accountSubsidyBudget,
        accountSubsidyDecay: accountSubsidyDecay ?? this.accountSubsidyDecay,
        hbdInterestRate: hbdInterestRate ?? this.hbdInterestRate,
      );

  factory ChainPropModel.fromRawJson(String str) =>
      ChainPropModel.fromJson((json.decode(str)));

  factory ChainPropModel.fromJson(Map<String, dynamic> json) => ChainPropModel(
        accountCreationFee: json["account_creation_fee"],
        maximumBlockSize: json["maximum_block_size"],
        accountSubsidyBudget: json["account_subsidy_budget"],
        accountSubsidyDecay: json["account_subsidy_decay"],
        hbdInterestRate: json["hbd_interest_rate"],
      );
}
