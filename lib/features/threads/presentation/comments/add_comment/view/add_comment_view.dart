import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/widgets/images/user_profile_image.dart';
import 'package:waves/core/dependency_injection/dependency_injection.dart';
import 'package:waves/core/utilities/constants/ui_constants.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/core/utilities/generics/classes/thread.dart';
import 'package:waves/features/threads/presentation/comments/add_comment/widgets/add_comment_bottom_action_bar.dart';
import 'package:waves/features/threads/presentation/thread_feed/controller/thread_feed_controller.dart';
import 'package:waves/features/threads/presentation/thread_feed/view_models/view_model.dart';
import 'package:waves/features/threads/repository/thread_repository.dart';

class AddCommentView extends StatefulWidget {
  const AddCommentView({
    super.key,
    required this.author,
    required this.permlink,
    required this.depth,
  });

  final String? author;
  final String? permlink;
  final int? depth;

  @override
  State<AddCommentView> createState() => _AddCommentViewState();
}

class _AddCommentViewState extends State<AddCommentView> {
  final TextEditingController commentTextEditingController =
      TextEditingController();
  late final bool isRoot;
  final FocusNode _nodeText = FocusNode();
  ThreadFeedType? _selectedType;
  ThreadInfo? _rootThreadInfo;

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: Colors.black,
      actions: [
        KeyboardActionsItem(
          focusNode: _nodeText,
          toolbarButtons: [
            (node) {
              return GestureDetector(
                onTap: () => node.unfocus(),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Done",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            }
          ],
        ),
      ],
    );
  }

  @override
  void initState() {
    if (widget.author == null && widget.permlink == null) {
      isRoot = true;
      final controller = context.read<ThreadFeedController>();
      _selectedType = controller.threadType == ThreadFeedType.all
          ? ThreadFeedType.ecency
          : controller.threadType;
      _rootThreadInfo = controller.threadType == ThreadFeedType.all
          ? null
          : controller.rootThreadInfo;
      if (_rootThreadInfo == null && _selectedType != null) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _loadRootThreadInfo(_selectedType!));
      }
    } else {
      isRoot = false;
    }
    super.initState();
  }

  Future<void> _loadRootThreadInfo(ThreadFeedType type) async {
    final repo = getIt<ThreadRepository>();
    final res = await repo.getFirstAccountPost(
      Thread.getThreadAccountName(type: type),
      AccountPostType.posts,
      1,
    );
    if (res.isSuccess && res.data != null) {
      setState(() {
        _rootThreadInfo =
            ThreadInfo(author: res.data!.author, permlink: res.data!.permlink);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: _appBar(),
      body: KeyboardActions(
        config: _buildConfig(context),
        child: SafeArea(
          child: Padding(
            padding: kScreenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isRoot)
                  Center(
                    child: DropdownButton<ThreadFeedType>(
                      value: _selectedType,
                      items: ThreadFeedType.values
                          .where((e) => e != ThreadFeedType.all)
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(Thread.gethreadName(type: e)),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedType = val;
                            _rootThreadInfo = null;
                          });
                          _loadRootThreadInfo(val);
                        }
                      },
                    ),
                  ),
                TextField(
                  keyboardType: TextInputType.multiline,
                  controller: commentTextEditingController,
                  maxLines: 5,
                  minLines: 1,
                  focusNode: _nodeText,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                      hintText: hintText,
                      border: InputBorder.none,
                      hintStyle: theme.inputDecorationTheme.hintStyle ??
                          TextStyle(
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.6),
                          )),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: AddCommentBottomActionBar(
            commentTextEditingController: commentTextEditingController,
            isRoot: isRoot,
            authorParam: widget.author,
            permlinkParam: widget.permlink,
            depthParam: widget.depth,
            rootThreadInfo: _rootThreadInfo),
      ),
    );
  }

  AppBar _appBar() {
    return isRoot
        ? AppBar(
            title: const Text("Publish"),
          )
        : AppBar(
            leadingWidth: 30,
            title: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: UserProfileImage(
                url: widget.author,
              ),
              title: AutoSizeText(
                "Reply to ${widget.author!}",
                minFontSize: 14,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                widget.permlink!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
  }

  String get hintText {
    return isRoot ? "What's happening?" : "Reply, engage, exchange ideas";
  }
}
