import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';
import 'package:flutter_polls/flutter_polls.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_json_meta_data/thread_json_meta_data.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/post_poll/poll_header.dart';

class PostPoll extends StatelessWidget {
  const PostPoll({super.key, required this.item});

  final ThreadFeedModel item;

  @override
  Widget build(BuildContext context) {
    ThreadJsonMetadata? meta = item.jsonMetadata;

    Future<bool> onVoted(PollOption option, int total) {
      print('voted options $option');
      return Future.value(true);
    }

    if (meta == null || meta.contentType != ContentType.poll) {
      return Container();
    }


    return Container(
        margin: const EdgeInsets.only(top: 12),
        child: FlutterPolls(
          pollId: item.permlink,
          onVoted: (pollOption, newTotalVotes) =>
              onVoted(pollOption, newTotalVotes),
          pollTitle: PollHeader(meta: meta),
          pollOptions: meta.choices!.map((e) {
            return PollOption(
                id: e,
                title: 
                  Text(e, maxLines: 2),
                votes: 3);
          }).toList(),
          heightBetweenOptions: 16,
          pollOptionsHeight: 40,
          votedBackgroundColor: const Color(0xff2e3d51),
          pollOptionsFillColor: const Color(0xff2e3d51),
          leadingVotedProgessColor: const Color(0xff357ce6),
          votedProgressColor: const Color(0xff526d91),
          votedCheckmark: const Icon(Icons.check, color: Colors.white, size: 24),
        ));
  }
}

class Option {
  dynamic text;
  Option(this.text);
}
