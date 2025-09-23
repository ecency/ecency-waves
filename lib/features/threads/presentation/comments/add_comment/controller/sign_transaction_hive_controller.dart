import 'dart:async';
import 'package:waves/core/controllers/hive_transaction_controller.dart';
import 'package:waves/core/dependency_injection/dependency_injection.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/models/action_response.dart';
import 'package:waves/core/socket/actions/socket_connection_action.dart';
import 'package:waves/core/socket/models/socket_response.dart';
import 'package:waves/core/socket/models/socket_sign_request_model.dart';
import 'package:waves/core/utilities/act.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/auth/models/hive_auth_model.dart';
import 'package:waves/features/auth/models/user_auth_model.dart';
import 'package:waves/features/threads/repository/thread_repository.dart';

class SignTransactionHiveController extends HiveTransactionController {
  final ThreadRepository _threadRepository = getIt<ThreadRepository>();
  late final StreamSubscription<SocketResponse> _socketSubscription;
  final String author;
  final String? permlink;
  final UserAuthModel<HiveAuthModel> authData;
  final String? comment;
  final List<String>? imageLinks;
  final int? weight;
  final double? amount;
  final String? assetSymbol;
  final String? memo;
  final SignTransactionType transactionType;
  String? _generatedPermlink;
  final String? pollId;
  final List<int>? choices;

  SignTransactionHiveController(
      {required this.transactionType,
      required this.author,
      required this.authData,
      required super.showError,
      required super.onSuccess,
      required super.onFailure,
      required super.ishiveKeyChainMethod,
      this.permlink,
      this.comment,
      this.imageLinks,
      this.weight,
      this.amount,
      this.assetSymbol,
      this.memo,
      this.pollId,
      this.choices})
      : assert(
            !(transactionType == SignTransactionType.comment &&
                (comment == null || imageLinks == null || permlink == null)),
            "comment,permlink and imageLinks parameters are required"),
        assert(
            !(transactionType == SignTransactionType.vote &&
                (weight == null || permlink == null)),
            "weight and permlink parameters are required"),
        assert(
            !(transactionType == SignTransactionType.pollvote &&
                (weight == null || permlink == null)),
            "pollId and choices parameters are required"),
        assert(
            !(transactionType == SignTransactionType.transfer &&
                (amount == null || assetSymbol == null)),
            "amount and assetSymbol parameters are required") {
    _initSignTransactionSocketSubscription();
  }

  void _initSignTransactionSocketSubscription() {
    _socketSubscription = socketProvider.stream.listen((event) {});
    _socketSubscription.onData((data) {
      if (data.type == SocketType.connected) {
        SocketConnectionAction.call(data, listenersProvider);
      } else if (data.type == SocketType.signWait) {
        _onSocketSignWait(data);
      } else if (data.type == SocketType.signAck) {
        onSuccess(transactionType == SignTransactionType.comment
            ? _generatedPermlink
            : true);
        showError(successMessage);
        resetListeners();
      } else if (data.type == SocketType.signNack ||
          data.type == SocketType.signErr) {
        showError(failureMessage);
        onFailure();
        resetListeners();
      }
    });
  }

  String get successMessage {
    switch (transactionType) {
      case SignTransactionType.vote:
      case SignTransactionType.pollvote:
        return LocaleText.smVoteSuccessMessage;
      case SignTransactionType.comment:
        return LocaleText.smCommentPublishMessage;
      case SignTransactionType.mute:
        return "User is muted successfully";
      case SignTransactionType.transfer:
        return LocaleText.smTipSuccessMessage;
    }
  }

  String get failureMessage {
    switch (transactionType) {
      case SignTransactionType.vote:
      case SignTransactionType.pollvote:
        return LocaleText.emVoteFailureMessage;
      case SignTransactionType.comment:
        return LocaleText.emCommentDeclineMessage;
      case SignTransactionType.mute:
        return "Mute operation is failed";
      case SignTransactionType.transfer:
        return LocaleText.emTipFailureMessage;
    }
  }

  @override
  void initTransactionProcess() async {
    listenersProvider.transactionState.value = TransactionState.loading;
    try {
      ActionSingleDataResponse<String> response = await transactionMethod();
      if (response.isSuccess) {
        SocketSignRequestModel socketSignRequest = SocketSignRequestModel(
            accountName: authData.accountName,
            token: authData.auth.token,
            data: response.data!);
        socketProvider.sendDataToSocket(socketSignRequest.toJsonString());
      } else {
        onServerFailure(
          message: response.errorMessage.isNotEmpty
              ? response.errorMessage
              : null,
        );
      }
    } catch (e) {
      onServerFailure(message: e.toString());
    }
  }

  void _onSocketSignWait(SocketResponse data) {
    onSocketSignWait(data, SocketInputType.sign_req, authData.accountName,
        authData.auth.authKey);
  }

  Future<ActionSingleDataResponse<String>> transactionMethod() async {
    switch (transactionType) {
      case SignTransactionType.comment:
        _generatedPermlink = Act.generatePermlink(authData.accountName);
        List<String> tags = Act.compileTags(comment!);
        return _threadRepository.commentOnContent(
            authData.accountName,
            author,
            permlink!, //parentPermlink
            _generatedPermlink!,
            Act.commentWithImages(comment!, imageLinks!),
            tags,
            null,
            authData.auth.authKey,
            authData.auth.token);
      case SignTransactionType.vote:
        final int sanitizedWeight =
            weight!.clamp(-10000, 10000).toInt();
        return _threadRepository.votecontent(
          authData.accountName,
          author,
          permlink!,
          sanitizedWeight,
          null,
          authData.auth.authKey,
          authData.auth.token,
        );
      case SignTransactionType.pollvote:
        return _threadRepository.castPollVote(
          authData.accountName,
          pollId!,
          choices!,
          null,
          authData.auth.authKey,
          authData.auth.token,
        );
      case SignTransactionType.mute:
        return _threadRepository.muteUser(
          authData.accountName,
          author,
          null,
          authData.auth.authKey,
          authData.auth.token,
        );
      case SignTransactionType.transfer:
        return _threadRepository.transfer(
          authData.accountName,
          author,
          amount!,
          assetSymbol!,
          memo ?? '',
          null,
          authData.auth.authKey,
          authData.auth.token,
        );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _socketSubscription.cancel();
  }
}
