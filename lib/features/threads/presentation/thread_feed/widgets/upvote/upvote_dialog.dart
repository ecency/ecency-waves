// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:waves/core/common/extensions/ui.dart';
import 'package:waves/core/common/widgets/coloured_button.dart';
import 'package:waves/core/common/widgets/images/user_profile_image.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/routes/routes.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/core/utilities/act.dart';
import 'package:waves/core/dependency_injection/dependency_injection.dart';
import 'package:waves/features/auth/models/hive_signer_auth_model.dart';
import 'package:waves/features/auth/models/posting_auth_model.dart';
import 'package:waves/features/auth/models/user_auth_model.dart';
import 'package:waves/features/threads/models/comment/comment_navigation_model.dart';
import 'package:waves/features/threads/models/post_detail/upvote_model.dart';
import 'package:waves/features/threads/presentation/comments/add_comment/controller/sign_transaction_hive_signer_controller.dart';
import 'package:waves/features/threads/presentation/comments/add_comment/controller/sign_transaction_posting_key_controller.dart';
import 'package:waves/features/threads/presentation/comments/add_comment/widgets/transaction_decision_dialog.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/upvote/tip_dialog.dart';
import 'package:waves/features/threads/presentation/thread_feed/widgets/upvote/tip_signing_dialog.dart';
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
  static const List<double> _tipAmountOptions = [0.1, 0.5, 1, 2, 3, 5, 10, 50];
  static const List<String> _tipTokenOptions = ['HIVE', 'HBD', 'POINTS'];
  static const String _transferCallbackScheme = 'waves';
  static const String _transferCallbackHost = 'transfer';

  final GetStorage _storage = getIt<GetStorage>();
  final AppLinks _appLinks = AppLinks();
  final Set<String> _handledTransferCallbacks = <String>{};
  String? _userName;
  double weight = _defaultWeight;
  String? _tipFeedbackMessage;
  bool _tipFeedbackSuccess = false;
  StreamSubscription<Uri?>? _transferSubscription;
  String? _pendingTransferRequestId;

  @override
  void initState() {
    super.initState();
    _userName = context.read<UserController>().userName;
    final storedWeight = _readStoredWeight();
    if (storedWeight != null) {
      weight = storedWeight;
    }
    _initTransferCallbacks();
  }

  @override
  void dispose() {
    _transferSubscription?.cancel();
    super.dispose();
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

  Future<void> _onTipTap(BuildContext context) async {
    final userController = context.read<UserController>();
    final UserAuthModel? userData = userController.userData;
    if (userData == null) {
      _showTipFeedback(LocaleText.tipRequiresAuth, success: false);
      return;
    }
    if (_tipFeedbackMessage != null) {
      setState(() {
        _tipFeedbackMessage = null;
        _tipFeedbackSuccess = false;
      });
    }
    final selection = await showDialog<TipSelection>(
      context: context,
      builder: (dialogContext) => TipDialog(
        amountOptions: _tipAmountOptions,
        tokenOptions: _tipTokenOptions,
      ),
    );

    if (!mounted || selection == null) {
      return;
    }

    if (userData.isPostingKeyLogin) {
      await _handlePostingKeyTip(
        context,
        selection,
        userData as UserAuthModel<PostingAuthModel>,
      );
      return;
    }

    if (userData.isHiveSignerLogin) {
      await _hiveSignerTipTransaction(
        selection,
        userData as UserAuthModel<HiveSignerAuthModel>,
      );
      return;
    }

    if (userData.isHiveKeychainLogin || userData.isHiveAuthLogin) {
      final authType = userData.isHiveKeychainLogin
          ? AuthType.hiveKeyChain
          : AuthType.hiveAuth;
      _startTipTransaction(selection, authType);
      return;
    }

    _showTipFeedback(LocaleText.tipRequiresAuth, success: false);
  }

  void _startTipTransaction(TipSelection selection, AuthType authType) {
    final memo = _tipMemo();
    final navigationData = SignTransactionNavigationModel(
      transactionType: SignTransactionType.transfer,
      author: widget.author,
      permlink: widget.permlink,
      amount: selection.amount,
      assetSymbol: selection.tokenSymbol,
      memo: memo,
      ishiveKeyChainMethod: authType == AuthType.hiveKeyChain,
    );
    context.pushNamed(Routes.hiveSignTransactionView, extra: navigationData);
  }

  Future<void> _handlePostingKeyTip(
    BuildContext context,
    TipSelection selection,
    UserAuthModel<PostingAuthModel> userData,
  ) async {
    final availableMethods = selection.tokenSymbol == 'POINTS'
        ? const [TipSigningMethod.ecency]
        : TipSigningMethod.values;
    final method = await showDialog<TipSigningMethod>(
      context: context,
      builder: (dialogContext) => TipSigningDialog(
        availableMethods: availableMethods,
      ),
    );

    if (!mounted || method == null) {
      return;
    }

    switch (method) {
      case TipSigningMethod.hiveSigner:
        await _launchHotSigning(
          method,
          selection,
          userData.accountName,
        );
        break;
      case TipSigningMethod.hiveKeychain:
        await _launchHotSigning(
          method,
          selection,
          userData.accountName,
        );
        break;
      case TipSigningMethod.ecency:
        await _launchHotSigning(
          method,
          selection,
          userData.accountName,
        );
        break;
      case TipSigningMethod.hiveAuth:
        await _launchHotSigning(
          method,
          selection,
          userData.accountName,
        );
        break;
    }
  }

  Future<void> _launchHotSigning(
    TipSigningMethod method,
    TipSelection selection,
    String accountName,
  ) async {
    try {
      List<dynamic>? operation;
      late final Map<String, String> queryParameters;
      final isPointsTransfer =
          method == TipSigningMethod.ecency &&
              selection.tokenSymbol.toUpperCase() == 'POINTS';

      if (isPointsTransfer) {
        queryParameters =
            _buildEcencyPointsQueryParameters(selection, accountName);
      } else {
        final transferOperation =
            _buildTransferOperation(selection, accountName);
        operation = transferOperation;
        queryParameters = _buildTransferQueryParameters(
          selection,
          accountName,
          transferOperation,
        );
      }
      switch (method) {
        case TipSigningMethod.hiveSigner:
          final uri = Uri.https(
            'hivesigner.com',
            '/sign/transfer',
            queryParameters,
          );
          await Act.launchThisUrl(uri.toString());
          break;
        case TipSigningMethod.hiveKeychain:
          await _openWithKeychain(queryParameters, operation!);
          break;
        case TipSigningMethod.ecency:
          await _openWithEcency(selection, queryParameters, operation);
          break;
        case TipSigningMethod.hiveAuth:
          await _openWithHiveAuth(queryParameters, operation!);
          break;
      }
    } catch (e) {
      _showTipFeedback(e.toString(), success: false);
    }
  }

  List<dynamic> _buildTransferOperation(
    TipSelection selection,
    String accountName,
  ) {
    final formattedAmount = selection.amount.toStringAsFixed(3);
    final amountParameter = '$formattedAmount ${selection.tokenSymbol.toUpperCase()}';
    final memo = _tipMemo();
    return [
      'transfer',
      {
        'from': accountName,
        'to': widget.author,
        'amount': amountParameter,
        'memo': memo,
      },
    ];
  }

  Map<String, String> _buildTransferQueryParameters(
    TipSelection selection,
    String accountName,
    List<dynamic> operation,
  ) {
    final formattedAmount = selection.amount.toStringAsFixed(3);
    final amountParameter = '$formattedAmount ${selection.tokenSymbol.toUpperCase()}';
    final memo = _tipMemo();
    return <String, String>{
      'from': accountName,
      'to': widget.author,
      'amount': amountParameter,
      'memo': memo,
      'authority': 'active',
      'operations': jsonEncode([operation]),
    };
  }

  Map<String, String> _buildEcencyPointsQueryParameters(
    TipSelection selection,
    String accountName,
  ) {
    final formattedAmount = selection.amount.toStringAsFixed(3);
    return <String, String>{
      'from': accountName,
      'to': widget.author,
      'amount': formattedAmount,
      'assets': 'points',
      'memo': _tipMemo(),
    };
  }

  Uri _buildTransferUri({
    required String scheme,
    required Map<String, String> queryParameters,
    required List<dynamic> operation,
  }) {
    if (scheme == 'ecency' || scheme == 'hive') {
      final operationJson = jsonEncode(operation);
      final encodedOperation =
          base64Url.encode(utf8.encode(operationJson)).replaceAll('=', '');
      final sanitizedQuery = Map<String, String>.from(queryParameters)
        ..remove('operations');
      return Uri(
        scheme: scheme,
        host: 'sign',
        path: '/op/$encodedOperation',
        queryParameters: sanitizedQuery.isEmpty ? null : sanitizedQuery,
      );
    }
    return Uri(
      scheme: scheme,
      host: 'sign',
      path: '/transfer',
      queryParameters: queryParameters,
    );
  }

  Future<void> _openWithKeychain(
    Map<String, String> queryParameters,
    List<dynamic> operation,
  ) async {
    final hiveUri = _buildTransferUri(
      scheme: 'hive',
      queryParameters: queryParameters,
      operation: operation,
    );
    if (Platform.isAndroid) {
      final intent = AndroidIntent(
        action: 'action_view',
        data: hiveUri.toString(),
        package: 'com.mobilekeychain',
      );
      final canLaunchIntent = await intent.canResolveActivity() ?? false;
      if (canLaunchIntent) {
        await intent.launch();
        return;
      }
      _showTipFeedback(LocaleText.tipKeychainNotFound, success: false);
      await launchUrl(
        Uri.parse(
          'https://play.google.com/store/apps/details?id=com.mobilekeychain',
        ),
        mode: LaunchMode.externalApplication,
      );
      return;
    }

    final canLaunchHive = await canLaunchUrl(hiveUri);
    if (canLaunchHive) {
      await launchUrl(hiveUri, mode: LaunchMode.externalApplication);
      return;
    }

    _showTipFeedback(LocaleText.tipKeychainNotFound, success: false);
  }

  Future<void> _openWithEcency(
    TipSelection selection,
    Map<String, String> queryParameters,
    List<dynamic>? operation,
  ) async {
    final String requestId = DateTime.now().millisecondsSinceEpoch.toString();
    final Uri callbackUri = _buildTransferCallbackUri(requestId);
    final Map<String, String> ecencyParameters =
        Map<String, String>.from(queryParameters)
          ..['callback'] = callbackUri.toString()
          ..['request_id'] = requestId;

    final Uri ecencyUri = selection.tokenSymbol.toUpperCase() == 'POINTS'
        ? Uri(
            scheme: 'ecency',
            host: 'transfer',
            queryParameters: ecencyParameters,
          )
        : _buildTransferUri(
            scheme: 'ecency',
            queryParameters: ecencyParameters,
            operation: operation!,
          );

    bool launched = false;

    if (Platform.isAndroid) {
      final intent = AndroidIntent(
        action: 'action_view',
        data: ecencyUri.toString(),
        package: 'app.esteem.mobile.android',
      );
      final bool canLaunchIntent = await intent.canResolveActivity() ?? false;
      if (canLaunchIntent) {
        await intent.launch();
        launched = true;
      } else {
        _showTipFeedback(LocaleText.tipEcencyNotFound, success: false);
        await launchUrl(
          Uri.parse(
            'https://play.google.com/store/apps/details?id=app.esteem.mobile.android',
          ),
          mode: LaunchMode.externalApplication,
        );
      }
    } else if (Platform.isIOS) {
      final bool canLaunchEcency = await canLaunchUrl(ecencyUri);
      if (canLaunchEcency) {
        final bool launchResult = await launchUrl(
          ecencyUri,
          mode: LaunchMode.externalApplication,
        );
        launched = launchResult;
      }

      if (!launched) {
        _showTipFeedback(LocaleText.tipEcencyNotFound, success: false);
        await launchUrl(
          Uri.parse('https://apps.apple.com/app/ecency/id1450268965'),
          mode: LaunchMode.externalApplication,
        );
      }
    } else {
      _showTipFeedback(LocaleText.tipEcencyNotFound, success: false);
    }

    if (launched) {
      _pendingTransferRequestId = requestId;
    } else {
      _pendingTransferRequestId = null;
    }
  }

  Future<void> _openWithHiveAuth(
    Map<String, String> queryParameters,
    List<dynamic> operation,
  ) async {
    final hiveUri = _buildTransferUri(
      scheme: 'hive',
      queryParameters: queryParameters,
      operation: operation,
    );

    if (Platform.isAndroid) {
      final intent = AndroidIntent(
        action: 'action_view',
        data: hiveUri.toString(),
        package: 'io.hiveauth.app',
      );
      final canLaunchIntent = await intent.canResolveActivity() ?? false;
      if (canLaunchIntent) {
        await intent.launch();
        return;
      }
    }

    final canLaunchHiveAuth = await canLaunchUrl(hiveUri);
    if (canLaunchHiveAuth) {
      final launched = await launchUrl(
        hiveUri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) {
        return;
      }
    }

    _showTipFeedback(LocaleText.emHiveAuthAppNotFound, success: false);
  }

  Future<void> _hiveSignerTipTransaction(
    TipSelection selection,
    UserAuthModel<HiveSignerAuthModel> userData,
  ) async {
    widget.rootContext.showLoader();
    String? feedbackMessage;
    var success = false;
    try {
      await SignTransactionHiveSignerController().initTransferProcess(
        recipient: widget.author,
        amount: selection.amount,
        assetSymbol: selection.tokenSymbol,
        memo: _tipMemo(),
        authdata: userData,
        onSuccess: () {},
        showToast: (message) {
          feedbackMessage = message;
          success = message == LocaleText.smTipSuccessMessage;
        },
      );
    } catch (e) {
      feedbackMessage = e.toString();
    } finally {
      widget.rootContext.hideLoader();
    }
    if (feedbackMessage != null) {
      _showTipFeedback(feedbackMessage!, success: success);
    }
  }

  void _showTipFeedback(String message, {required bool success}) {
    if (!mounted) return;
    setState(() {
      _tipFeedbackMessage = message;
      _tipFeedbackSuccess = success;
    });
    widget.rootContext.showSnackBar(message);
  }

  Future<void> _initTransferCallbacks() async {
    await _handleInitialTransferUri();

    _transferSubscription = _appLinks.uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null) {
          _handleTransferUri(uri);
        }
      },
      onError: (_) {},
      cancelOnError: false,
    );
  }

  Future<void> _handleInitialTransferUri() async {
    try {
      final Uri? initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        await _handleTransferUri(initialUri);
      }
    } on PlatformException {
      // Ignore – app_links throws when no initial URI is available.
    } on FormatException catch (error) {
      debugPrint('Invalid transfer callback URI: $error');
    }
  }

  Future<void> _handleTransferUri(Uri uri) async {
    if (uri.scheme.toLowerCase() != _transferCallbackScheme ||
        uri.host.toLowerCase() != _transferCallbackHost) {
      return;
    }

    final String callbackIdentifier =
        uri.queryParameters['request_id'] ?? uri.toString();
    if (_handledTransferCallbacks.contains(callbackIdentifier)) {
      return;
    }

    if (_pendingTransferRequestId != null &&
        callbackIdentifier != _pendingTransferRequestId) {
      return;
    }

    _handledTransferCallbacks.add(callbackIdentifier);
    _pendingTransferRequestId = null;

    final String status = uri.queryParameters['status']?.toLowerCase() ?? '';
    final String? message =
        uri.queryParameters['message'] ?? uri.queryParameters['error'];

    if (status == 'success') {
      _showTipFeedback(
        message?.isNotEmpty == true
            ? message!
            : LocaleText.smTipSuccessMessage,
        success: true,
      );
      return;
    }

    if (message != null && message.isNotEmpty) {
      _showTipFeedback(message, success: false);
    } else {
      _showTipFeedback(LocaleText.emTipFailureMessage, success: false);
    }
  }

  Uri _buildTransferCallbackUri(String requestId) {
    return Uri(
      scheme: _transferCallbackScheme,
      host: _transferCallbackHost,
      queryParameters: <String, String>{'request_id': requestId},
    );
  }


  String _tipMemo() {
    return 'Tip for @${widget.author}/${widget.permlink} via Ecency Waves';
  }

  Widget _upVoteSlider(ThemeData theme, BuildContext context) {
    final UserAuthModel userData = context.read<UserController>().userData!;
    final colorScheme = theme.colorScheme;
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
        if (_tipFeedbackMessage != null) ...[
          const Gap(16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _tipFeedbackSuccess
                    ? colorScheme.secondaryContainer
                    : colorScheme.errorContainer,
                borderRadius: const BorderRadius.all(Radius.circular(12)),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _tipFeedbackSuccess
                          ? Icons.check_circle
                          : Icons.error_outline,
                      size: 20,
                      color: _tipFeedbackSuccess
                          ? colorScheme.onSecondaryContainer
                          : Colors.white,
                    ),
                    const Gap(12),
                    Expanded(
                      child: Text(
                        _tipFeedbackMessage!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: _tipFeedbackSuccess
                              ? colorScheme.onSecondaryContainer
                              : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        Row(
          children: [
            Expanded(
              child: ColoredButton(
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimary,
                icon: Icons.card_giftcard_outlined,
                isBoldText: true,
                height: 44,
                borderRadius:
                    const BorderRadius.only(bottomLeft: Radius.circular(20)),
                text: LocaleText.tip,
                onPressed: () => _onTipTap(context),
              ),
            ),
            const Gap(2),
            Expanded(
              child: ColoredButton(
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimary,
                isBoldText: true,
                height: 44,
                borderRadius:
                    const BorderRadius.only(bottomRight: Radius.circular(20)),
                text: LocaleText.upvote,
                onPressed: () {
                  Navigator.pop(context);
                  if (userData.isPostingKeyLogin) {
                    _postingKeyVoteTransaction(userData, context);
                  } else if (userData.isHiveSignerLogin) {
                    _hiveSignerTransaction(userData, context);
                  } else if (userData.isHiveKeychainLogin) {
                    _onTransactionDecision(AuthType.hiveKeyChain, context);
                  } else if (userData.isHiveAuthLogin) {
                    _onTransactionDecision(AuthType.hiveAuth, context);
                  } else {
                    _dialogForHiveTransaction(context);
                  }
                },
              ),
            ),
          ],
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
