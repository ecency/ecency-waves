import 'package:waves/core/utilities/save_convert.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_json_meta_data/thread_json_meta_data_video.dart';

class ThreadJsonMetadata {
  final List<String>? tags;
  final List<String>? image;
  final List<String>? images;
  final List<String>? links;
  final List<String>? users;
  final String? app;
  final ThreadJsonVideo? video;
  final String? format;

  const ThreadJsonMetadata({
    required this.tags,
    required this.image,
    this.images = const [],
    this.app = "",
    this.format,
    this.links = const [],
    this.users = const [],
    required this.video,
  });

  factory ThreadJsonMetadata.fromJson(Map<String, dynamic>? json) =>
      ThreadJsonMetadata(
        tags: asList(json, 'tags').map((e) => e.toString()).toList(),
        image: _images(json),
        links: asList(json, 'links').map((e) => e.toString()).toList(),
        users: asList(json, 'users').map((e) => e.toString()).toList(),
        format: json?['format'] as String? ?? "",
        app: asString(json, 'app'),
        video: ThreadJsonVideo.fromJson(
          asMap(json, 'video'),
        ),
      );

  Map<String, dynamic> toJson() {
    return {
      'tags': tags,
      'image': image,
      'images': images,
      'links': links,
      'users': users,
      'app': app,
      'video': video?.toJson(),
      'format': format,
    };
  }

  static List<String> _images(Map<String, dynamic>? json) {
    if (json?['image'] != null && json!['image'].isNotEmpty) {
      return asList(json, 'image').map((e) => e.toString()).toList();
    } else if (json?['images'] != null && json!['images'].isNotEmpty) {
      return asList(json, 'images').map((e) => e.toString()).toList();
    } else if (json?['links'] != null && json!['links'].isNotEmpty) {
      return _linkToImage(json['links']);
    } else {
      return [];
    }
  }

  static List<String> _linkToImage(List links) {
    List<String> result = [];
    for (var link in links) {
      int lastBracketIndex = link.lastIndexOf(")");

      result.add(lastBracketIndex != -1
          ? link.substring(0, lastBracketIndex) +
              link.substring(lastBracketIndex + 1)
          : link);
    }
    return result;
  }
}
