// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/extensions/ui.dart';
import 'package:waves/core/common/widgets/coloured_button.dart';
import 'package:waves/core/common/widgets/images/user_profile_image.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/routes/routes.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/core/dependency_injection/dependency_injection.dart';
import 'package:waves/features/auth/models/hive_signer_auth_model.dart';
import 'package:waves/features/auth/models/posting_auth_model.dart';
import 'package:waves/features/auth/models/user_auth_model.dart';
import 'package:waves/features/threads/models/comment/comment_navigation_model.dart';
import 'package:waves/features/threads/models/post_detail/upvote_model.dart';
import 'package:waves/features/threads/presentation/comments/add_comment/controller/sign_transaction_hive_signer_controller.dart';
import 'package:waves/features/threads/presentation/comments/add_comment/controller/sign_transaction_posting_key_controller.dart';
import 'package:waves/features/threads/presentation/comments/add_comment/widgets/transaction_decision_dialog.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/upvote/upvote_percentage_buttons.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/upvote/upvote_slider.dart';
import 'package:waves/features/user/view/user_controller.dart';

class UpvoteDialog extends StatefulWidget {
  const UpvoteDialog(
      {super.key,
      required this.author,
      required this.permlink,
      required this.rootContext,
      required this.onSuccess});

  final String author;
  final String permlink;
  final BuildContext rootContext;
  final Function(ActiveVoteModel) onSuccess;

  @override
  State<UpvoteDialog> createState() => _UpvoteDialogState();
}

class _UpvoteDialogState extends State<UpvoteDialog> {
  static const double _defaultWeight = 0.01;
  static const String _voteWeightKeyPrefix = 'last_vote_weight_';

  final GetStorage _storage = getIt<GetStorage>();
  String? _userName;
  double weight = _defaultWeight;

  @override
  void initState() {
    super.initState();
    _userName = context.read<UserController>().userName;
    final storedWeight = _readStoredWeight();
    if (storedWeight != null) {
      weight = storedWeight;
    }
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiary,
        border: Border.all(color: theme.colorScheme.tertiary, width: 4),
        borderRadius: const BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: _upVoteSlider(theme, context),
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      toolbarHeight: 60,
      leadingWidth: 0,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          UserProfileImage(
            url: widget.author,
          ),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleText.upvote,
                  style: theme.textTheme.bodyLarge!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  "@${widget.author}/${widget.permlink}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          splashRadius: 30,
          icon: const Icon(
            Icons.cancel,
            size: 28,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Widget _upVoteSlider(ThemeData theme, BuildContext context) {
    final UserAuthModel userData = context.read<UserController>().userData!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _appBar(context),
        Container(
          decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.all(Radius.circular(6))),
          child: Column(
            children: [
              const Gap(35),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  percentageButtons(0.1),
                  const Gap(15),
                  percentageButtons(0.25),
                  const Gap(15),
                  percentageButtons(0.5),
                  const Gap(15),
                  percentageButtons(0.75),
                  const Gap(15),
                  percentageButtons(1),
                ],
              ),
              const Gap(10),
              UpvoteSlider(
                initialWeight: weight,
                onChanged: _onWeightChanged,
              ),
              const Gap(30),
            ],
          ),
        ),
        SizedBox(
          height: 45,
          child: ColoredButton(
            backgroundColor: theme.colorScheme.tertiary,
            isBoldText: true,
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20)),
            text: LocaleText.upvote,
            onPressed: () {
              Navigator.pop(context);
              if (userData.isPostingKeyLogin) {
                _postingKeyVoteTransaction(userData, context);
              } else if (userData.isHiveSignerLogin) {
                _hiveSignerTransaction(userData, context);
              } else {
                _onTransactionDecision(AuthType.hiveKeyChain, context);
              }
            },
          ),
        ),
      ],
    );
  }

  void _postingKeyVoteTransaction(
      UserAuthModel userData, BuildContext context) async {
    widget.rootContext.showLoader();
    try {
      await SignTransactionPostingKeyController().initVoteProcess(
        weight * 10000,
        author: widget.author,
        permlink: widget.permlink,
        authdata: userData as UserAuthModel<PostingAuthModel>,
        onSuccess: () =>
            widget.onSuccess(generateVoteModel(widget.rootContext)),
        showToast: (message) => widget.rootContext.showSnackBar(message),
      );
    } catch (e) {
      widget.rootContext.showSnackBar(e.toString());
    } finally {
      widget.rootContext.hideLoader();
    }
  }

  void _hiveSignerTransaction(
      UserAuthModel userData, BuildContext context) async {
    widget.rootContext.showLoader();
    try {
      await SignTransactionHiveSignerController().initVoteProcess(
        weight * 10000,
        author: widget.author,
        permlink: widget.permlink,
        authdata: userData as UserAuthModel<HiveSignerAuthModel>,
        onSuccess: () =>
            widget.onSuccess(generateVoteModel(widget.rootContext)),
        showToast: (message) => widget.rootContext.showSnackBar(message),
      );
    } catch (e) {
      widget.rootContext.showSnackBar(e.toString());
    } finally {
      widget.rootContext.hideLoader();
    }
  }

  Future<dynamic> _dialogForHiveTransaction(BuildContext context) {
    return showDialog(
      context: context,
      barrierColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.98),
      builder: (context) => TransactionDecisionDialog(
        onContinue: (authType) {
          _onTransactionDecision(authType, context);
        },
      ),
    );
  }

  void _onTransactionDecision(AuthType authType, BuildContext context) {
    SignTransactionNavigationModel navigationData =
        SignTransactionNavigationModel(
            transactionType: SignTransactionType.vote,
            author: widget.author,
            permlink: widget.permlink,
            weight: weight * 10000,
            ishiveKeyChainMethod: authType == AuthType.hiveKeyChain);
    context
        .pushNamed(Routes.hiveSignTransactionView, extra: navigationData)
        .then((value) {
      if (value != null) {
        widget.onSuccess(generateVoteModel(widget.rootContext));
      }
    });
  }

  ActiveVoteModel generateVoteModel(BuildContext context) {
    return ActiveVoteModel(
        weight: (weight * 10000).toInt(),
        voter: context.read<UserController>().userName!);
  }

  Widget percentageButtons(double value) {
    return UpVotePercentageButtons(
        onTap: (weight) {
          _onWeightChanged(weight, shouldUpdateUI: true);
        },
        percentageValue: value);
  }

  void _onWeightChanged(double newWeight, {bool shouldUpdateUI = false}) {
    final double normalizedWeight = _normalizeWeight(newWeight);
    if (shouldUpdateUI) {
      if (!mounted) return;
      setState(() {
        weight = normalizedWeight;
      });
    } else {
      weight = normalizedWeight;
    }
    _persistWeight(normalizedWeight);
  }

  double? _readStoredWeight() {
    if (_userName == null) return null;
    final storedValue = _storage.read(_storageKey(_userName!));
    if (storedValue == null) {
      return null;
    }
    if (storedValue is num) {
      return _normalizeWeight(storedValue.toDouble());
    }
    if (storedValue is String) {
      final parsedValue = double.tryParse(storedValue);
      if (parsedValue != null) {
        return _normalizeWeight(parsedValue);
      }
    }
    return null;
  }

  void _persistWeight(double value) {
    if (_userName == null) return;
    _storage.write(_storageKey(_userName!), value);
  }

  double _normalizeWeight(double value) {
    if (value.isNaN) {
      return _defaultWeight;
    }
    final num normalized = value.clamp(_defaultWeight, 1.0);
    return normalized.toDouble();
  }

  String _storageKey(String userName) {
    return '$_voteWeightKeyPrefix$userName';
  }
}
