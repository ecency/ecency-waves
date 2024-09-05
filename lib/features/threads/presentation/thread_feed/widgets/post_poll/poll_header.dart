import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/services/poll_service/poll_model.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_json_meta_data/thread_json_meta_data.dart';

class PollHeader extends StatelessWidget {
  const PollHeader({super.key, required this.meta});

  final ThreadJsonMetadata meta;

  @override
  Widget build(BuildContext context) {

    //compile terms list
    List<Text> termWidgets = [];
    TextStyle temsTextStyle = const TextStyle(fontSize: 12);
    if (meta.filters!.accountAge > 0) {
      String text = LocaleText.ageLimit(meta.filters!.accountAge);
      termWidgets.add(Text(text, style: temsTextStyle));
    }
    if (meta.preferredInterpretation == PollPreferredInterpretation.tokens) {
      termWidgets.add(Text(LocaleText.interpretationToken, style: temsTextStyle));
    }
    if (meta.maxChoicesVoted! > 1) {
      String text = LocaleText.maxChoices(meta.maxChoicesVoted!);
      termWidgets.add(Text(text, style: temsTextStyle));
    }

    String timeString = "";
    if(meta.endTime != null){
      timeString = meta.endTime!.isAfter(DateTime.now()) 
        ? "Ends in ${timeago.format(meta.endTime!, allowFromNow: true, locale: 'en_short')}"
        : "Ended";
    }


    return Container(
        alignment: Alignment.topLeft,
        child: Wrap(
          spacing: 8.0, // Horizontal space between children
          runSpacing: 4.0, //ivalent to align-items: center
          children: [
            Text(
              meta.question!,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Text(
                timeString,
                style: const TextStyle(fontSize: 12),
              ),
              const Gap(4),
              const Icon(
                Icons.access_time, // Clock icon
                size: 18.0, // Size of the icon
                color: Colors.white, // Color of the icon
              )
            ]),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: termWidgets,
            )
          ],
        ));
  }
}
