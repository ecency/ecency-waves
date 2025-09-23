import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/services/poll_service/poll_model.dart';
import 'package:waves/core/utilities/theme/theme_mode.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_json_meta_data/thread_json_meta_data.dart';
import 'package:waves/features/threads/presentation/thread_feed/controller/poll_controller.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/post_poll/poll_choices.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/post_poll/poll_header.dart';
import 'package:waves/features/user/presentation/user_profile/controller/user_profile_controller.dart';
import 'package:waves/features/user/view/user_controller.dart';

class PostPoll extends StatefulWidget {
  const PostPoll({super.key, required this.item});

  final ThreadFeedModel item;

  @override
  State<PostPoll> createState() => _PostPollState();
}

class _PostPollState extends State<PostPoll> {
  List<int> selection = [];
  bool enableRevote = false;
  bool isVoting = false;

  @override
  void initState() {
    super.initState();

    if (widget.item.jsonMetadata!.contentType == ContentType.poll) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        String author = widget.item.author, permlink = widget.item.permlink;
        context.read<PollController>().fetchPollData(author, permlink);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ThreadJsonMetadata? meta = widget.item.jsonMetadata;
    String author = widget.item.author;
    String permlink = widget.item.permlink;

    ThemeController themeController = context.watch<ThemeController>();
    String? username = context.select<UserController, String?>(
        (userController) => userController.userName);
    PollModel? poll = context.select<PollController, PollModel?>(
        (pollController) => pollController.getPollData(author, permlink));

    //evaluate voting eligibitliy based on account age limit and end time;
    int accountAgeDays = context.select<UserProfileController, int>(
        (userProfileController) => userProfileController.accountAgeDays);
    int minAgeDays = meta?.filters?.accountAge ?? 0;
    bool hasEnded = poll?.endTime.isBefore(DateTime.now()) ?? false;
    bool votingProhibited = hasEnded || minAgeDays >= accountAgeDays;

    //check if user already voted
    List<int> userVotedIds = poll?.userVotedIds(username) ?? [];
    bool hasVoted = userVotedIds.isNotEmpty;

    //setting for enabling disabling vote button
    bool voteEnabled =
        poll != null && (!hasVoted || enableRevote) && selection.isNotEmpty;

    //prepare for vote action boadcast
    onCastVote() async {
      PollController pollController = context.read<PollController>();

      if (poll?.pollTrxId != null && selection.isNotEmpty) {
        setState(() {
          isVoting = true;
        });

        await pollController.castVote(
            context, poll!.author, poll.permlink, selection);

        setState(() {
          enableRevote = false;
          isVoting = false;
          selection = [];
        });
      }
    }

    //change selection is user interact with choices
    onSelection(int choiceNum, bool value) {
      int? maxSelectable = meta?.maxChoicesVoted ?? 1;

      if (maxSelectable > 1) {
        // handle multiple choice selection
        bool maxSelected = selection.length >= maxSelectable;

        int index = selection.indexOf(choiceNum);
        if (index >= 0) {
          selection.removeAt(index);
        } else if (!maxSelected) {
          selection.add(choiceNum);
        }
        setState(() {
          selection = List.from(selection);
        });
      } else {
        // if only one choice allowed, overwrite selection
        setState(() {
          selection = [choiceNum];
        });
      }
    }

    onRevote() {
      setState(() {
        enableRevote = true;
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
              title: Text(
                e.choiceText,
                maxLines: 2,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              votes:
                  e.votes?.getInterprettedVotes(meta.preferredInterpretation) ??
                      0,
              votesPostfix:
                  e.votes?.getInterprettedSymbol(meta.preferredInterpretation)))
          .toList();
    }

    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          Theme(
              data: themeController.pollThemeData,
              child: PollChoices(
                pollId: widget.item.permlink,
                onSelection: (id, status) => onSelection(id, status),
                pollTitle: PollHeader(
                  meta: meta,
                ),
                pollOptions: pollOptions(),
                selectedIds: selection,
                pollEnded: votingProhibited,
                hasVoted: !enableRevote && hasVoted,
                heightBetweenOptions: 16,
                pollOptionsHeight: 32,
                userVotedOptionIds: userVotedIds,
                totalVotes: poll?.totalInterpretedVotes ?? 0,
                votedCheckmark:
                    const Icon(Icons.check, color: Colors.white, size: 24),
              )),
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (hasVoted && !enableRevote && (meta.voteChange ?? false))
                  TextButton(
                    onPressed: () => onRevote(),
                    child: Text(LocaleText.pollRevote),
                  ),
                if (!votingProhibited)
                  ElevatedButton.icon(
                    onPressed: voteEnabled ? () => onCastVote() : null,
                    icon: isVoting
                        ? Container(
                            width: 24.0,
                            height: 24.0,
                            padding: const EdgeInsets.all(4.0),
                            child: const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.bar_chart, color: Colors.white),
                    label: Text(LocaleText.pollVote, style: const TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 32)),
                  ),
              ],
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
