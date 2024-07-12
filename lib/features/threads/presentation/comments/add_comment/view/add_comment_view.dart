import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:waves/core/common/widgets/images/user_profile_image.dart';
import 'package:waves/core/utilities/constants/ui_constants.dart';
import 'package:waves/features/threads/presentation/comments/add_comment/widgets/add_comment_bottom_action_bar.dart';

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

  @override
  void initState() {
    if (widget.author == null && widget.permlink == null) {
      isRoot = true;
    } else {
      isRoot = false;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: SafeArea(
          child: Padding(
        padding: kScreenPadding,
        child: TextField(
          controller: commentTextEditingController,
          expands: true,
          maxLines: null,
          minLines: null,
          decoration:
              InputDecoration(hintText: hintText, border: InputBorder.none),
        ),
      )),
      bottomNavigationBar: SafeArea(
        child: AddCommentBottomActionBar(
            commentTextEditingController: commentTextEditingController,
            isRoot: isRoot,
            authorParam: widget.author,
            permlinkParam: widget.permlink,
            depthParam: widget.depth),
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
