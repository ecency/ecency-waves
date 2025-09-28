import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/extensions/ui.dart';
import 'package:waves/core/common/widgets/dialog/dialog_template.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/routes/route_keys.dart';
import 'package:waves/core/routes/routes.dart';
import 'package:waves/core/utilities/parser.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';
import 'package:waves/features/threads/presentation/comments/comment_detail/controller/comment_detail_controller.dart';
import 'package:waves/features/threads/presentation/thread_feed/controller/thread_feed_controller.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/thread_translate_bottom_sheet.dart';
import 'package:waves/features/user/utils/block_user_helper.dart';
import 'package:waves/features/user/view/user_controller.dart';

enum _ThreadMenuAction { copy, translate, edit, block, report }

class ThreadPopUpMenu extends StatelessWidget {
  const ThreadPopUpMenu({super.key, required this.item});

  final ThreadFeedModel item;

  @override
  Widget build(BuildContext context) {
    final controller = context.read<ThreadFeedController>();
    final theme = Theme.of(context);
    final userName = context.select<UserController, String?>(
      (userController) => userController.userName,
    );
    final canEdit = userName != null && userName == item.author;
    final entries = <PopupMenuEntry<_ThreadMenuAction>>[
      PopupMenuItem<_ThreadMenuAction>(
        value: _ThreadMenuAction.copy,
        child: Text(LocaleText.copyContent),
      ),
      PopupMenuItem<_ThreadMenuAction>(
        value: _ThreadMenuAction.translate,
        child: Text(LocaleText.translate),
      ),
    ];
    if (canEdit) {
      entries.add(
        PopupMenuItem<_ThreadMenuAction>(
          value: _ThreadMenuAction.edit,
          child: Text(LocaleText.edit),
        ),
      );
    } else {
      entries.add(
        const PopupMenuItem<_ThreadMenuAction>(
          value: _ThreadMenuAction.block,
          child: Text("Block"),
        ),
      );
    }
    entries.add(
      PopupMenuItem<_ThreadMenuAction>(
        value: _ThreadMenuAction.report,
        child: Text(
          LocaleText.report,
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
        ),
      ),
    );
    return PopupMenuButton<_ThreadMenuAction>(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      itemBuilder: (BuildContext context) => entries,
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
          case _ThreadMenuAction.edit:
            context.authenticatedAction(action: () async {
              final queryParameters = <String, String>{
                RouteKeys.depth: item.depth.toString(),
              };
              if (item.parentAuthor != null) {
                queryParameters[RouteKeys.accountName] = item.parentAuthor!;
              }
              if (item.parentPermlink != null) {
                queryParameters[RouteKeys.permlink] = item.parentPermlink!;
              }
              final result = await context.pushNamed(
                Routes.addCommentView,
                queryParameters: queryParameters,
                extra: item,
              );
              if (result is ThreadFeedModel) {
                controller.refreshOnCommentUpdated(result);
                try {
                  context
                      .read<CommentDetailController>()
                      .onCommentUpdated(result);
                } catch (_) {}
              }
            });
            break;
          case _ThreadMenuAction.block:
            BlockUserHelper.blockUser(
              context,
              author: item.author,
              onSuccess: () {
                Future.delayed(
                  const Duration(seconds: 3),
                  controller.refresh,
                );
              },
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
