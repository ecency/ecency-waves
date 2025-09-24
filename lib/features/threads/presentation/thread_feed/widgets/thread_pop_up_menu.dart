import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/extensions/ui.dart';
import 'package:waves/core/common/widgets/dialog/dialog_template.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/utilities/parser.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';
import 'package:waves/features/threads/presentation/thread_feed/controller/thread_feed_controller.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/thread_translate_bottom_sheet.dart';

enum _ThreadMenuAction { copy, translate, report }

class ThreadPopUpMenu extends StatelessWidget {
  const ThreadPopUpMenu({super.key, required this.item});

  final ThreadFeedModel item;

  @override
  Widget build(BuildContext context) {
    final controller = context.read<ThreadFeedController>();
    final theme = Theme.of(context);
    return PopupMenuButton<_ThreadMenuAction>(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<_ThreadMenuAction>>[
        PopupMenuItem<_ThreadMenuAction>(
          value: _ThreadMenuAction.copy,
          child: Text(LocaleText.copyContent),
        ),
        PopupMenuItem<_ThreadMenuAction>(
          value: _ThreadMenuAction.translate,
          child: Text(LocaleText.translate),
        ),
        PopupMenuItem<_ThreadMenuAction>(
          value: _ThreadMenuAction.report,
          child: Text(
            LocaleText.report,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
          ),
        ),
      ],
      onSelected: (_ThreadMenuAction value) async {
        switch (value) {
          case _ThreadMenuAction.copy:
            final plainText = Parser.removeAllHtmlTags(item.body);
            if (plainText.isEmpty) {
              context.showSnackBar(LocaleText.noContentFound);
              return;
            }
            await Clipboard.setData(ClipboardData(text: plainText));
            context.showSnackBar(LocaleText.contentCopied);
            break;
          case _ThreadMenuAction.translate:
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (_) => ThreadTranslateBottomSheet(item: item),
            );
            break;
          case _ThreadMenuAction.report:
            showDialog(
              context: context,
              builder: (_) {
                return DialogTemplate(
                  title: LocaleText.report,
                  content: Text(LocaleText.reportContentConfirmation),
                  declineButtonText: LocaleText.cancel,
                  proceedButtonText: LocaleText.report,
                  onProceedTap: () async {
                    context.showLoader();
                    controller
                        .reportThread(item.author, item.permlink)
                        .then((isSuccess) {
                      context.hideLoader();
                      if (isSuccess) {
                        context.showSnackBar(LocaleText.reportSuccess);
                      } else {
                        context.showSnackBar(LocaleText.reportFailed);
                      }
                    });
                  },
                );
              },
            );
            break;
        }
      },
      child: const Icon(Icons.more_vert),
    );
  }
}
