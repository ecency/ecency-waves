import 'dart:convert';
import 'package:waves/core/utilities/enum.dart';

String _parseErrorMessage(dynamic error) {
  if (error == null) {
    return '';
  }
  if (error is String) {
    return error;
  }
  if (error is Map<String, dynamic>) {
    final dynamic message = error['message'];
    if (message is String) {
      return message;
    }
    return jsonEncode(error);
  }
  return error.toString();
}

bool _hasError(dynamic error) {
  if (error == null) {
    return false;
  }
  if (error is String) {
    return error.isNotEmpty;
  }
  if (error is Map) {
    return error.isNotEmpty;
  }
  return true;
}

class ActionListDataResponse<T> {
  final List<T>? data;
  final bool valid;
  final String errorMessage;
  final ResponseStatus status;
  final bool isSuccess;

  ActionListDataResponse({
    this.data,
    this.isSuccess = false,
    this.valid = false,
    required this.status,
    required this.errorMessage,
  });

  factory ActionListDataResponse.fromJsonString(
          String string, T Function(dynamic) fromJson) =>
      ActionListDataResponse.fromJson(json.decode(string), fromJson);

  factory ActionListDataResponse.fromJson(
      Map<String, dynamic> json, T Function(dynamic) fromJson) {
    return ActionListDataResponse(
      data: (json['data'] as List<dynamic>?)
              ?.map((dynamic item) => fromJson(item))
              .toList() ??
          [],
      status: json['valid'] && !_hasError(json['error'])
          ? ResponseStatus.success
          : ResponseStatus.failed,
      isSuccess:
          json['valid'] && !_hasError(json['error']) && json['data'] != null,
      valid: json['valid'] as bool,
      errorMessage: _parseErrorMessage(json['error']),
    );
  }
}

class ActionSingleDataResponse<T> {
  final T? data;
  final bool valid;
  final String errorMessage;
  final ResponseStatus status;
  final bool isSuccess;

  ActionSingleDataResponse(
      {this.data,
      this.isSuccess = false,
      this.valid = false,
      required this.errorMessage,
      required this.status});

  factory ActionSingleDataResponse.fromJsonString(
          String string, T Function(Map<String, dynamic>)? fromJson,
          {bool parseFromList = false, bool ignoreFromJson = false}) =>
      ActionSingleDataResponse.fromJson(json.decode(string), fromJson,
          parseFromList: parseFromList,ignoreFromJson: ignoreFromJson);

  factory ActionSingleDataResponse.fromJson(
      Map<String, dynamic> json, T Function(Map<String, dynamic>)? fromJson,
      {bool parseFromList = false, bool ignoreFromJson = false}) {
    return ActionSingleDataResponse(
      data: _parseData(json, fromJson, parseFromList, ignoreFromJson),
      valid: json['valid'] as bool,
      status: json['valid'] && !_hasError(json['error'])
          ? ResponseStatus.success
          : ResponseStatus.failed,
      isSuccess: json['valid'] &&
          !_hasError(json['error']) &&
          (fromJson != null ? json['data'] != null : true),
      errorMessage: _parseErrorMessage(json['error']),
    );
  }

  static T? _parseData<T>(
      Map<String, dynamic> json,
      T Function(Map<String, dynamic>)? fromJson,
      bool parseFromList,
      bool ignoreFromJson) {
    if (fromJson != null) {
      if (json['data'] != null) {
        if (parseFromList) {
          return fromJson(json['data'][0]);
        } else {
          return fromJson(json['data']);
        }
      } else {
        return null;
      }
    } else if (!ignoreFromJson) {
      return null;
    } else {
      final dynamic raw = json['data'];
      if (raw == null) {
        return null;
      }
      if (raw is String) {
        return raw as T;
      }
      return jsonEncode(raw) as T;
    }
  }
}
