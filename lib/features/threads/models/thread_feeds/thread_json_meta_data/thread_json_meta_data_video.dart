import 'package:waves/core/utilities/save_convert.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_json_meta_data/thread_json_meta_data_video_info.dart';

class ThreadJsonVideo {
  final PostJsonVideoInfo info;

  ThreadJsonVideo({
    required this.info,
  });

  factory ThreadJsonVideo.fromJson(Map<String, dynamic>? json) =>
      ThreadJsonVideo(
        info: PostJsonVideoInfo.fromJson(
          asMap(json, 'info'),
        ),
      );
}
