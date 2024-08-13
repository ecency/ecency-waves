import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/services/poll_service/poll_model.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_json_meta_data/thread_json_meta_data.dart';
import 'package:waves/features/threads/presentation/thread_feed/controller/poll_controller.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/post_poll/poll_choices.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/post_poll/poll_header.dart';

class PostPoll extends StatefulWidget {
  const PostPoll({super.key, required this.item});

  final ThreadFeedModel item;

  @override
  State<PostPoll> createState() => _PostPollState();
}

class _PostPollState extends State<PostPoll> {
  Map<int, bool> selection = {};
  bool hasVoted = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (widget.item.jsonMetadata!.contentType == ContentType.poll) {
      String author = widget.item.author, permlink = widget.item.permlink;
      context.read<PollController>().fetchPollData(author, permlink);
    }
  }

  @override
  Widget build(BuildContext context) {
    ThreadJsonMetadata? meta = widget.item.jsonMetadata;
    String author = widget.item.author;
    String permlink = widget.item.permlink;

    PollModel? poll = context.select<PollController, PollModel?>(
        (pollController) => pollController.getPollData(author, permlink));

    bool hasEnded = poll?.endTime.isBefore(DateTime.now()) ?? false;

    bool voteEnabled = poll != null &&
        !hasEnded &&
        !hasVoted &&
        selection.entries
            .fold(false, (prevVal, entry) => entry.value || prevVal);

    onCastVote() async {
      bool status = await Future.delayed(Duration(seconds: 2), () => true);

      if (status) {
        setState(() {
          hasVoted = true;
        });
      }

      return status;
    }

    onSelection(int id, bool value) {
      setState(() {
        selection = {...selection, id: value};
      });
    }

    if (meta == null || meta.contentType != ContentType.poll) {
      return Container();
    }

    List<PollOption> pollOptions() {
      List<PollChoice> choices =
          poll?.pollChoices ?? PollChoice.fromValues(meta.choices!);

      return choices
          .map((e) => PollOption(
              id: e.choiceNum,
              title: Text(e.choiceText, maxLines: 2),
              votes: e.votes?.totalVotes ?? 0))
          .toList();
    }

    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          PollChoices(
            pollId: widget.item.permlink,
            onSelection: (id, status) => onSelection(id, status),
            pollTitle: PollHeader(
              meta: meta,
            ),
            pollOptions: pollOptions(),
            selectedIds: selection,
            pollEnded: hasEnded,
            hasVoted: hasVoted,
            heightBetweenOptions: 16,
            pollOptionsHeight: 40,
            userVotedOptionIds: poll?.userVotedIds("tahir"), 
            totalVotes: poll?.pollStats.totalVotingAccountsNum.toDouble() ?? 0,
            votedBackgroundColor: const Color(0xff2e3d51),
            pollOptionsFillColor: const Color(0xff2e3d51),
            leadingVotedProgessColor: const Color(0xff357ce6),
            votedProgressColor: const Color(0xff526d91),
            votedCheckmark:
                const Icon(Icons.check, color: Colors.white, size: 24),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: voteEnabled ? () => onCastVote() : null,
              icon: const Icon(Icons.bar_chart),
              label: const Text("Vote"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 32)),
            ),
          )
        ],
      ),
    );
  }
}

class Option {
  dynamic text;
  Option(this.text);
}
