import 'package:waves/core/utilities/save_convert.dart';


class PostJsonVideoInfo {
  final String? videoV2;
  PostJsonVideoInfo({
    required this.videoV2,
  });

  factory PostJsonVideoInfo.fromJson(Map<String, dynamic>? json) =>
      PostJsonVideoInfo(
        videoV2: asString(json, 'videoV2'),
      );
}