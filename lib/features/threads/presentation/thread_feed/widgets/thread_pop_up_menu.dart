import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/extensions/ui.dart';
import 'package:waves/core/common/widgets/dialog/dialog_template.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';
import 'package:waves/features/threads/presentation/thread_feed/controller/thread_feed_controller.dart';

class ThreadPopUpMenu extends StatelessWidget {
  const ThreadPopUpMenu({super.key, required this.item});

  final ThreadFeedModel item;

  @override
  Widget build(BuildContext context) {
    final controller = context.read<ThreadFeedController>();
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'option1',
          child: Text(
            'Report',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
      onSelected: (String value) {
        switch (value) {
          case 'option1':
            showDialog(
                context: context,
                builder: (_) {
                  return DialogTemplate(
                    title: "Report this",
                    content: const Text(
                      "Are you sure you want to report this user?",
                    ),
                    declineButtonText: "Cancel",
                    proceedButtonText: "Report",
                    onProceedTap: () async {
                      context.showLoader();
                      controller
                          .reportThread(item.author, item.permlink)
                          .then((isSuccess) {
                        context.hideLoader();
                        if (isSuccess) {
                          context.showSnackBar(
                              "User has been reported successfully");
                        } else {
                          context.showSnackBar("Report failed");
                        }
                      });
                    },
                  );
                });
            break;
        }
      },
      child: const Icon(Icons.more_vert),
    );
  }
}
