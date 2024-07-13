import 'dart:convert';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/auth/models/hive_auth_model.dart';
import 'package:waves/features/auth/models/hive_signer_auth_model.dart';
import 'package:waves/features/auth/models/posting_auth_model.dart';

class UserAuthModel<T> {
  final String accountName;
  final AuthType authType;
  final String imageUploadToken;
  final T auth;

  UserAuthModel({
    required this.accountName,
    required this.auth,
    required this.authType,
    required this.imageUploadToken,
  });

  bool get isPostingKeyLogin => authType == AuthType.postingKey;
  bool get isHiveSignerLogin => authType == AuthType.hiveSign;
  bool get isHiveAuthLogin => authType == AuthType.hiveAuth;
  bool get isHiveKeychainLogin => authType == AuthType.hiveKeyChain;

  factory UserAuthModel.fromJson(Map<String, dynamic> json) {
    return UserAuthModel(
      accountName: json['accountName'],
      authType: enumFromString(json['authType'], AuthType.values),
      imageUploadToken: json['imageUploadToken'],
      auth: _fromJsonAuth<T>(
        json['auth'],
        enumFromString(json['authType'], AuthType.values),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountName': accountName,
      'authType': enumToString(authType),
      'imageUploadToken':imageUploadToken,
      'auth': _toJsonAuth<T>(auth),
    };
  }

  factory UserAuthModel.fromJsonString(String jsonString) {
    return UserAuthModel.fromJson(json.decode(jsonString));
  }

  static AuthType authTypeFromJsonString(String jsonString) {
    return enumFromString(json.decode(jsonString)['authType'], AuthType.values);
  }

  static AuthType authTypeFromMap(Map<String, dynamic> json) {
    return enumFromString(json['authType'], AuthType.values);
  }

  String toJsonString() {
    final jsonData = toJson();
    return json.encode(jsonData);
  }

  UserAuthModel<T> copyWith({
    String? accountName,
    AuthType? authType,
    String? imageUploadToken,
    T? auth,
  }) {
    return UserAuthModel<T>(
      accountName: accountName ?? this.accountName,
      authType: authType ?? this.authType,
      imageUploadToken: imageUploadToken ?? this.imageUploadToken,
      auth: auth ?? this.auth,
    );
  }

  static T _fromJsonAuth<T>(Map<String, dynamic> json, AuthType authType) {
    switch (authType) {
      case AuthType.postingKey:
        return PostingAuthModel.fromJson(json) as T;
      case AuthType.hiveKeyChain:
        return HiveAuthModel.fromJson(json) as T;
      case AuthType.hiveAuth:
        return HiveAuthModel.fromJson(json) as T;
      case AuthType.hiveSign:
        return HiveSignerAuthModel.fromJson(json) as T;
      default:
        throw Exception('Unknown authType: $authType');
    }
  }

  static Map<String, dynamic> _toJsonAuth<T>(T auth) {
    if (auth is PostingAuthModel) {
      return auth.toJson();
    } else if (auth is HiveAuthModel) {
      return (auth as HiveAuthModel).toJson();
    } else if (auth is HiveSignerAuthModel) {
      return (auth as HiveSignerAuthModel).toJson();
    } else {
      throw Exception('Unknown auth type');
    }
  }

  static List fromRawJsonList(String str) => json.decode(str);

  static String toRawJsonList(List<UserAuthModel> accounts) {
    return json.encode(accounts.map((e) => e.toJson()).toList());
  }
}
