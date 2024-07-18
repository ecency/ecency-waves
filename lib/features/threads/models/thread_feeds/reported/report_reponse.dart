import 'dart:convert';

class ReportResponse {
  final int statusCode;
  final ReportStatus status;
  final bool isSuccess;

  ReportResponse({
    required this.statusCode,
    required this.status,
  }): isSuccess = statusCode == 200 && status.value.toLowerCase() == "ok";

  ReportResponse copyWith({
    int? statusCode,
    ReportStatus? status,
  }) =>
      ReportResponse(
        statusCode: statusCode ?? this.statusCode,
        status: status ?? this.status,
      );

  factory ReportResponse.fromRawJson(String str) =>
      ReportResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ReportResponse.fromJson(Map<String, dynamic> json) => ReportResponse(
        statusCode: json["status"],
        status: ReportStatus.fromJson(json["body"]),
      );

  Map<String, dynamic> toJson() => {
        "status": statusCode,
        "body": status.toJson(),
      };
}

class ReportStatus {
  final String value;

  ReportStatus({
    required this.value,
  });

  ReportStatus copyWith({
    String? value,
  }) =>
      ReportStatus(
        value: value ?? this.value,
      );

  factory ReportStatus.fromRawJson(String str) =>
      ReportStatus.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ReportStatus.fromJson(Map<String, dynamic> json) => ReportStatus(
        value: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "status": value,
      };
}
