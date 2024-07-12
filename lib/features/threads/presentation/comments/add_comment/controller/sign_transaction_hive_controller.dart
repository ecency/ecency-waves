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
  final String permlink;
  final UserAuthModel<HiveAuthModel> authData;
  final String? comment;
  final List<String>? imageLinks;
  final double? weight;
  final SignTransactionType transactionType;
  String? _generatedPermlink;

  SignTransactionHiveController({
    required this.transactionType,
    required this.author,
    required this.permlink,
    required this.authData,
    required super.showError,
    required super.onSuccess,
    required super.onFailure,
    required super.ishiveKeyChainMethod,
    this.comment,
    this.imageLinks,
    this.weight,
  })  : assert(
            !(transactionType == SignTransactionType.comment &&
                    comment == null ||
                imageLinks == null),
            "comment and imageLinks parameters are required"),
        assert(!(transactionType == SignTransactionType.vote && weight == null),
            "weight parameter is required") {
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
    if (transactionType == SignTransactionType.vote) {
      return LocaleText.smVoteSuccessMessage;
    } else {
      return LocaleText.smCommentPublishMessage;
    }
  }

  String get failureMessage {
    if (transactionType == SignTransactionType.vote) {
      return LocaleText.emVoteFailureMessage;
    } else {
      return LocaleText.emCommentDeclineMessage;
    }
  }

  @override
  void initTransactionProcess() async {
    listenersProvider.transactionState.value = TransactionState.loading;
    ActionSingleDataResponse<String> response = await transactionMethod();
    if (response.isSuccess) {
      SocketSignRequestModel socketSignRequest = SocketSignRequestModel(
          accountName: authData.accountName,
          token: authData.auth.token,
          data: response.data!);
      socketProvider.sendDataToSocket(socketSignRequest.toJsonString());
    } else {
      onServerFailure();
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
        return _threadRepository.commentOnContent(
            authData.accountName,
            author,
            permlink, //parentPermlink
            _generatedPermlink!,
            Act.commentWithImages(comment!, imageLinks!),
            null,
            authData.auth.authKey,
            authData.auth.token);
      case SignTransactionType.vote:
        return _threadRepository.votecontent(
          authData.accountName,
          author,
          permlink,
          weight!,
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
