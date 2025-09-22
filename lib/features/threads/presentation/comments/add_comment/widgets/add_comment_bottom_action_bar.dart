import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/extensions/ui.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/routes/routes.dart';
import 'package:waves/core/services/data_service/api_service.dart';
import 'package:waves/core/utilities/act.dart';
import 'package:waves/core/utilities/constants/ui_constants.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/auth/models/hive_signer_auth_model.dart';
import 'package:waves/features/auth/models/posting_auth_model.dart';
import 'package:waves/features/auth/models/user_auth_model.dart';
import 'package:waves/features/threads/models/comment/comment_navigation_model.dart';
import 'package:waves/features/threads/models/comment/image_upload_model.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';
import 'package:waves/features/threads/presentation/comments/add_comment/controller/sign_transaction_hive_signer_controller.dart';
import 'package:waves/features/threads/presentation/comments/add_comment/controller/sign_transaction_posting_key_controller.dart';
import 'package:waves/features/threads/presentation/comments/add_comment/widgets/transaction_decision_dialog.dart';
import 'package:waves/features/threads/presentation/thread_feed/controller/thread_feed_controller.dart';
import 'package:waves/features/threads/presentation/thread_feed/view_models/view_model.dart';
import 'package:waves/features/user/view/user_controller.dart';

class AddCommentBottomActionBar extends StatefulWidget {
  const AddCommentBottomActionBar(
      {super.key,
      required this.commentTextEditingController,
      required this.isRoot,
      required this.authorParam,
      required this.permlinkParam,
      required this.depthParam,
      this.rootThreadInfo});

  final TextEditingController commentTextEditingController;
  final bool isRoot;
  final String? authorParam;
  final String? permlinkParam;
  final int? depthParam;
  // When creating a root post we might target a specific container host.
  // [rootThreadInfo] provides the author/permlink pair for that host.
  final ThreadInfo? rootThreadInfo;

  @override
  State<AddCommentBottomActionBar> createState() =>
      AddCommentBottomActionBarState();
}

class AddCommentBottomActionBarState extends State<AddCommentBottomActionBar> {
  int imageUploadId = 0;
  List<ImageUploadModel> images = [];
  List<String> uploadedImageLinks = [];

  late ThemeData theme;
  bool _isPublishing = false;

  @override
  void didChangeDependencies() {
    theme = Theme.of(context);
    super.didChangeDependencies();
  }

  void _setPublishing(bool value) {
    if (!mounted) {
      _isPublishing = value;
      return;
    }
    if (_isPublishing == value) {
      return;
    }
    setState(() {
      _isPublishing = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: kScreenHorizontalPaddingDigit, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (images.isNotEmpty) imagePreviewWidget(),
            Row(
              children: [
                Row(
                  children: [
                    FloatingActionButton(
                      heroTag: "gallery",
                      onPressed: _isPublishing
                          ? null
                          : () => pickImageAndUpload(
                              ImageSource.gallery, context),
                      child: const Icon(Icons.image),
                    ),
                    const Gap(10),
                    FloatingActionButton(
                      heroTag: "camera",
                      onPressed: _isPublishing
                          ? null
                          : () => pickImageAndUpload(
                              ImageSource.camera, context),
                      child: const Icon(Icons.camera),
                    ),
                  ],
                ),
                const Spacer(),
                if (!widget.isRoot) _publishButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void publish() {
    if (_isPublishing) {
      return;
    }
    FocusScope.of(context).unfocus();
    final userData = context.read<UserController>().userData!;
    _onPublish(userData);
  }

  FloatingActionButton _publishButton() {
    return FloatingActionButton(
      onPressed: _isPublishing ? null : publish,
      child: _isPublishing
          ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.reply),
    );
  }

  void _onPublish(UserAuthModel<dynamic> userData) {
    String comment = widget.commentTextEditingController.text.trim();
    if (comment.isEmpty) {
      context.showSnackBar(LocaleText.replyCannotBeEmpty);
    } else if (widget.isRoot &&
        widget.rootThreadInfo == null &&
        context.read<ThreadFeedController>().rootThreadInfo == null) {
      // Unable to determine which container to post to
      context.pop();
    } else if (userData.isPostingKeyLogin) {
      _setPublishing(true);
      _postingKeyCommentTransaction(comment, userData, context);
    } else if (userData.isHiveSignerLogin) {
      _setPublishing(true);
      _hiveSignerCommentTransaction(comment, userData, context);
    } else if (userData.isHiveKeychainLogin) {
      _onTransactionDecision(
        comment,
        AuthType.hiveKeyChain,
        context,
        userData,
      );
    } else if (userData.isHiveAuthLogin) {
      _onTransactionDecision(
        comment,
        AuthType.hiveAuth,
        context,
        userData,
      );
    } else {
      _dialogForHiveTransaction(context, comment, userData);
    }
  }

  Future<List<XFile>> imagePicker(
    ImageSource source,
  ) async {
    List<XFile> pickedImages = [];
    if (source == ImageSource.gallery) {
      pickedImages = await ImagePicker().pickMultiImage(limit: 5);
      int limit = 5 - images.length;
      if (pickedImages.length > limit) {
        if (mounted) context.showSnackBar("Cannot attach more than 5 images");
        pickedImages = pickedImages.sublist(0, limit);
      }
    } else {
      XFile? pickedImage =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedImage != null) {
        pickedImages = [pickedImage];
      }
    }
    return pickedImages;
  }

  void pickImageAndUpload(ImageSource source, BuildContext context) async {
    if (images.length < 5) {
      imagePicker(source).then((pickedImages) {
        if (pickedImages.isNotEmpty) {
          for (var item in pickedImages) {
            upload(item, imageUploadId);
          }
        }
      }).catchError((e) {
        context.showSnackBar(e.toString());
      });
    } else {
      context.showSnackBar("Cannot attach more than 5 images");
    }
  }

  Widget imagePreviewWidget() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 10),
      child: SizedBox(
        height: 60,
        child: Align(
          alignment: Alignment.centerLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(images.length, (index) {
                ImageUploadModel item = images[index];
                return Stack(
                  children: [
                    Container(
                      height: 60,
                      width: 60,
                      margin: const EdgeInsets.only(right: 5),
                      decoration: BoxDecoration(
                          color: theme.colorScheme.tertiary,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(4)),
                          image: item.imageLink != null
                              ? DecorationImage(
                                  image: NetworkImage(item.imageLink!),
                                  fit: BoxFit.cover)
                              : null),
                      child: item.imageLink == null
                          ? const Center(
                              child: SizedBox(
                                  height: 25,
                                  width: 25,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  )),
                            )
                          : null,
                    ),
                    if (item.imageLink != null)
                      Positioned(
                        top: 3,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => setState(() {
                            uploadedImageLinks
                                .removeWhere((e) => e == item.imageLink);
                            images.removeAt(index);
                          }),
                          child: CircleAvatar(
                              backgroundColor: theme.scaffoldBackgroundColor
                                  .withOpacity(0.7),
                              radius: 10,
                              child: const Icon(
                                Icons.remove,
                                size: 15,
                              )),
                        ),
                      )
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  void upload(
    XFile file,
    int id,
  ) async {
    if (mounted) {
      setState(() {
        images.add(ImageUploadModel(id: id, uploadingImage: true));
        imageUploadId++;
      });
    }
    ApiService()
        .uploadAndGetImageUrl(
            file, context.read<UserController>().imageUploadToken)
        .then((response) {
      if (response.isSuccess) {
        String uploadedImageUrl = response.data!.url;
        setState(() {
          uploadedImageLinks.add(uploadedImageUrl);
        });
        log(uploadedImageUrl);
        int index = images.indexWhere((element) => element.id == id);
        images[index] = images[index]
            .copyWith(uploadingImage: false, imageLink: uploadedImageUrl);
      } else {
        int index = images.indexWhere((element) => element.id == id);
        setState(() {
          images.removeAt(index);
        });
        context.showSnackBar(response.errorMessage);
      }
    });
  }

  void _postingKeyCommentTransaction(String comment,
      UserAuthModel<dynamic> userData, BuildContext context) async {
    context.showLoader();
    await SignTransactionPostingKeyController().initCommentProcess(comment,
        imageLinks: uploadedImageLinks,
        author: author(context),
        parentPermlink: permlink(context),
        authData: userData as UserAuthModel<PostingAuthModel>,
        onSuccess: (generatedPermlink) {
          if (!mounted) {
            return;
          }
          context.hideLoader();
          _setPublishing(false);
          context.pop(
              generateCommentModel(generatedPermlink, userData.accountName));
        },
        onFailure: () {
          if (!mounted) {
            return;
          }
          context.hideLoader();
          _setPublishing(false);
        },
        showToast: (message) => context.showSnackBar(message));
  }

  void _hiveSignerCommentTransaction(String comment,
      UserAuthModel<dynamic> userData, BuildContext context) async {
    context.showLoader();
    await SignTransactionHiveSignerController().initCommentProcess(comment,
        imageLinks: uploadedImageLinks,
        parentAuthor: author(context),
        parentPermlink: permlink(context),
        authData: userData as UserAuthModel<HiveSignerAuthModel>,
        onSuccess: (generatedPermlink) {
          if (!mounted) {
            return;
          }
          context.hideLoader();
          _setPublishing(false);
          context.pop(
              generateCommentModel(generatedPermlink, userData.accountName));
        },
        onFailure: () {
          if (!mounted) {
            return;
          }
          context.hideLoader();
          _setPublishing(false);
        },
        showToast: (message) => context.showSnackBar(message));
  }

  Future<dynamic> _dialogForHiveTransaction(
      BuildContext context, String comment, UserAuthModel userData) {
    return showDialog(
      useRootNavigator: true,
      context: context,
      builder: (_) => TransactionDecisionDialog(
        onContinue: (authType) {
          _onTransactionDecision(comment, authType, context, userData);
        },
      ),
    );
  }

  void _onTransactionDecision(String comment, AuthType authType,
      BuildContext context, UserAuthModel userData) async {
    _setPublishing(true);
    SignTransactionNavigationModel navigationData =
        SignTransactionNavigationModel(
            transactionType: SignTransactionType.comment,
            author: author(context),
            permlink: permlink(context),
            comment: comment,
            imageLinks: uploadedImageLinks,
            ishiveKeyChainMethod: authType == AuthType.hiveKeyChain);
    context
        .pushNamed(Routes.hiveSignTransactionView, extra: navigationData)
        .then((generatedPermlink) {
      if (!mounted) {
        return;
      }
      _setPublishing(false);
      context.pop(
        generateCommentModel(generatedPermlink, userData.accountName),
      );
    });
  }

  ThreadFeedModel? generateCommentModel(Object? permlink, String userName) {
    if (permlink != null && permlink is String) {
      return ThreadFeedModel(
          postId: Act.generateRandomNumber(6),
          parentAuthor: widget.authorParam,
          parentPermlink: widget.permlinkParam,
          author: userName,
          permlink: permlink,
          category: "",
          depth: widget.isRoot ? 1 : widget.depthParam! + 1,
          title: '',
          body: widget.commentTextEditingController.text.trim(),
          created: DateTime.now());
    }
    return null;
  }

  String author(BuildContext context) {
    return threadInfo(context).author;
  }

  String permlink(BuildContext context) {
    return threadInfo(context).permlink;
  }

  ThreadInfo threadInfo(BuildContext context) {
    if (widget.isRoot) {
      return widget.rootThreadInfo ??
          context.read<ThreadFeedController>().rootThreadInfo!;
    } else {
      return ThreadInfo(
          author: widget.authorParam!, permlink: widget.permlinkParam!);
    }
  }
}
