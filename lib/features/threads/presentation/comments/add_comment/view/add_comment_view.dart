import 'package:auto_size_text/auto_size_text.dart';
import 'package:characters/characters.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/widgets/images/user_profile_image.dart';
import 'package:waves/core/dependency_injection/dependency_injection.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/utilities/constants/ui_constants.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/core/utilities/generics/classes/thread.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';
import 'package:waves/features/threads/presentation/comments/add_comment/widgets/add_comment_bottom_action_bar.dart';
import 'package:waves/features/threads/presentation/thread_feed/controller/thread_feed_controller.dart';
import 'package:waves/features/threads/presentation/thread_feed/view_models/view_model.dart';
import 'package:waves/features/threads/repository/thread_repository.dart';
import 'package:waves/features/explore/presentation/widgets/thread_type_dropdown.dart';

class AddCommentView extends StatefulWidget {
  const AddCommentView({
    super.key,
    required this.author,
    required this.permlink,
    required this.depth,
    this.editingThread,
  });

  final String? author;
  final String? permlink;
  final int? depth;
  final ThreadFeedModel? editingThread;

  @override
  State<AddCommentView> createState() => _AddCommentViewState();
}

class _AddCommentViewState extends State<AddCommentView> {
  static const int _maxCommentLength = 250;
  static const double _keyboardActionsBarHeight = 45;

  final TextEditingController commentTextEditingController =
      TextEditingController();
  late final bool isRoot;
  final FocusNode _nodeText = FocusNode();
  ThreadFeedType? _selectedType;
  ThreadInfo? _rootThreadInfo;
  final GlobalKey<AddCommentBottomActionBarState> _bottomActionBarKey =
      GlobalKey<AddCommentBottomActionBarState>();

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
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    LocaleText.done,
                    style: const TextStyle(color: Colors.white),
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
    super.initState();

    final editingThread = widget.editingThread;
    if (editingThread != null) {
      commentTextEditingController.text = editingThread.body;
      commentTextEditingController.selection = TextSelection.fromPosition(
        TextPosition(offset: commentTextEditingController.text.length),
      );
      isRoot = editingThread.depth <= 1;
    } else if (widget.author == null && widget.permlink == null) {
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusScope.of(context).requestFocus(_nodeText);
      }
    });
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
  void dispose() {
    commentTextEditingController.dispose();
    _nodeText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final keyboardViewInsets = MediaQuery.viewInsetsOf(context).bottom;
    final keyboardActionsPadding =
        keyboardViewInsets > 0 ? _keyboardActionsBarHeight : 0;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _appBar(theme),
      body: KeyboardActions(
        disableScroll: true,
        config: _buildConfig(context),
        child: SafeArea(
          child: Padding(
            padding: kScreenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () =>
                        FocusScope.of(context).requestFocus(_nodeText),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: 120,
                        maxHeight: 220,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                          border: Border.all(
                            color: theme.dividerColor.withOpacity(0.4),
                          ),
                        ),
                        child: TextField(
                          keyboardType: TextInputType.multiline,
                          controller: commentTextEditingController,
                          focusNode: _nodeText,
                          textInputAction: TextInputAction.newline,
                          autofocus: true,
                          minLines: 3,
                          maxLines: 8,
                          maxLength: _maxCommentLength,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          buildCounter: (
                            _, {
                            required int currentLength,
                            required bool isFocused,
                            int? maxLength,
                          }) =>
                              const SizedBox.shrink(),
                          textAlignVertical: TextAlignVertical.top,
                          decoration: InputDecoration(
                            hintText: hintText,
                            border: InputBorder.none,
                            hintStyle:
                                theme.inputDecorationTheme.hintStyle ??
                                    TextStyle(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.6),
                                    ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 8,
                            ),
                            isCollapsed: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: commentTextEditingController,
                  builder: (context, value, _) {
                    final currentLength = value.text.characters.length;
                    final isLimitReached = currentLength >= _maxCommentLength;
                    final counterColor = isLimitReached
                        ? theme.colorScheme.error
                        : theme.textTheme.bodySmall?.color ??
                            theme.colorScheme.onSurface.withOpacity(0.6);

                    return Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '$currentLength/$_maxCommentLength',
                        style: theme.textTheme.bodySmall?.copyWith(
                              color: counterColor,
                            ) ??
                            TextStyle(color: counterColor),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(
          bottom: keyboardViewInsets + keyboardActionsPadding,
        ),
        child: AddCommentBottomActionBar(
            key: _bottomActionBarKey,
            commentTextEditingController: commentTextEditingController,
            isRoot: isRoot,
            authorParam: widget.author,
            permlinkParam: widget.permlink,
            depthParam: widget.depth,
            rootThreadInfo: _rootThreadInfo,
            editingThread: widget.editingThread),
      ),
    );
  }

  AppBar _appBar(theme) {
    if (widget.editingThread != null) {
      return AppBar(
        title: Text(LocaleText.edit),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              onPressed: () => _bottomActionBarKey.currentState?.publish(),
              child: Text(LocaleText.save),
            ),
          ),
        ],
      );
    }

    return isRoot
        ? AppBar(
            title: ThreadTypeDropdown(
              value: _selectedType ?? ThreadFeedType.ecency,
              onChanged: (val) {
                setState(() {
                  _selectedType = val;
                  _rootThreadInfo = null;
                });
                _loadRootThreadInfo(val);
              },
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  onPressed: () =>
                      _bottomActionBarKey.currentState?.publish(),
                  child: Text(LocaleText.post),
                ),
              ),
            ],
          )
        : AppBar(
            leadingWidth: 30,
            title: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: UserProfileImage(
                url: widget.author,
              ),
              title: AutoSizeText(
                LocaleText.replyToUser(widget.author!),
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
    return isRoot
        ? LocaleText.whatsHappening
        : LocaleText.replyEngageExchangeIdeas;
  }
}
