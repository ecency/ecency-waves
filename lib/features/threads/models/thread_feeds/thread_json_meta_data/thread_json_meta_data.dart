import 'package:waves/core/services/poll_service/poll_model.dart';
import 'package:waves/core/utilities/save_convert.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_json_meta_data/thread_json_meta_data_video.dart';

enum ContentType implements Comparable<ContentType> {
  poll(value: 'poll'),
  general(value: 'general');

  const ContentType({
    required this.value,
  });

  final String value;

  @override
  int compareTo(ContentType other) => 0;
}



class PollFilters {
  final int accountAge;

  // Constructor
  PollFilters({required this.accountAge});

  // Optional: Method to convert to a map if needed
  Map<String, dynamic> toMap() {
    return {
      'account_age': accountAge,
    };
  }

  // Optional: Method to create a PollFilter from a map
  factory PollFilters.fromMap(Map<String, dynamic> map) {
    return PollFilters(
      accountAge: map['account_age'] ?? 0,
    );
  }
}

class ThreadJsonMetadata {
  final List<String>? tags;
  final List<String>? image;
  final List<String>? images;
  final List<String>? links;
  final List<String>? users;
  final String? app;
  final ThreadJsonVideo? video;
  final String? format;

  final ContentType? contentType;
  final double? version;
  final String? question;
  final PollPreferredInterpretation? preferredInterpretation;
  final int? maxChoicesVoted;
  final List<String>? choices;
  final PollFilters? filters;
  final DateTime? endTime;
  final bool? uiHideResUntilVoted;
  final bool? voteChange;
  final bool? hideVotes;

  const ThreadJsonMetadata({
    required this.tags,
    required this.image,
    this.images = const [],
    this.app = "",
    this.format,
    this.links = const [],
    this.users = const [],
    required this.video,
    this.contentType,
    this.preferredInterpretation,
    this.version,
    this.question,
    this.maxChoicesVoted,
    this.choices,
    this.filters,
    this.endTime,
    this.voteChange,
    this.hideVotes,
    this.uiHideResUntilVoted,
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
        contentType:
            (json?['content_type'] != null && json?['content_type'] == 'poll')
                ? ContentType.poll
                : ContentType.general,

        version: json?['version'] as double?,
        question: json?['question'] as String?,
        choices: asList(json, 'choices').map((e) => e.toString()).toList(),
        filters: json?['filters'] != null ? PollFilters.fromMap(json?['filters']) : null,
        maxChoicesVoted: json?['max_choices_voted'] as int? ?? 1,
        endTime: json?['end_time'].runtimeType == int ? (DateTime.fromMillisecondsSinceEpoch(json?['end_time'] * 1000)) : null,
        voteChange: json?['vote_change'] as bool?,
        hideVotes: json?['hide_votes'] as bool?,
        uiHideResUntilVoted: json?['ui_hide_res_until_voted'] as bool?,
        preferredInterpretation: PollPreferredInterpretation.fromString(json?['preferred_interpretation'])
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
      'content_type':contentType!.value,
      'version':version,
      'question':question,
      'choices': choices,
      'filters':filters?.toMap(),
      'max_choices_voted':maxChoicesVoted,
      'end_time':endTime != null ? (endTime!.millisecondsSinceEpoch / 1000).ceil() : null,
      'vote_change':voteChange,
      'hide_votes':hideVotes,
      'ui_hide_res_until_voted':uiHideResUntilVoted,
      'preferred_interpretation':preferredInterpretation?.value
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
