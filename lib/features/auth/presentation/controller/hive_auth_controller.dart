import 'dart:async';
import 'package:waves/core/controllers/hive_transaction_controller.dart';
import 'package:waves/core/dependency_injection/dependency_injection.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/models/action_response.dart';
import 'package:waves/core/models/auth_decryption_token_response.dart';
import 'package:waves/core/models/auth_redirection_response.dart';
import 'package:waves/core/socket/actions/socket_connection_action.dart';
import 'package:waves/core/socket/models/socket_auth_request_model.dart';
import 'package:waves/core/socket/models/socket_response.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/auth/models/hive_auth_model.dart';
import 'package:waves/features/auth/models/user_auth_model.dart';
import 'package:waves/features/auth/repository/auth_repository.dart';
import 'package:waves/features/user/repository/user_local_repository.dart';
import 'package:waves/features/user/mixins/multi_account_mixin.dart';

class HiveAuthController extends HiveTransactionController {
  final AuthRepository _authRepository = getIt<AuthRepository>();
  final UserLocalRepository _localRepository = getIt<UserLocalRepository>();
  final StreamController<UserAuthModel?> _userStreamController =
      getIt<StreamController<UserAuthModel?>>();

  late final StreamSubscription<SocketResponse> _socketSubscription;
  final String accountName;

  HiveAuthController({
    required String accountName,
    required super.onFailure,
    required super.ishiveKeyChainMethod,
    required super.showError,
    required super.onSuccess,
  })  : accountName = accountName.toLowerCase() {
    _initAuthSocketSubscription();
  }

  String? authKey;

  void _initAuthSocketSubscription() {
    _socketSubscription = socketProvider.stream.listen((event) {});
    _socketSubscription.onData((data) {
      if (data.type == SocketType.connected) {
        SocketConnectionAction.call(data, listenersProvider);
      } else if (data.type == SocketType.authWait) {
        _onSocketAuthWait(data);
      } else if (data.type == SocketType.authAck) {
        _decrytDataFromSocket(data.value as String);
      } else if (data.type == SocketType.authNack) {
        showError(LocaleText.emAuthNackMessage);
        onFailure();
        resetListeners();
      }
    });
  }

  void _onSocketAuthWait(SocketResponse data) {
    onSocketSignWait(data, SocketInputType.auth_req, accountName, authKey!);
  }

  @override
  void initTransactionProcess() async {
    listenersProvider.transactionState.value = TransactionState.loading;
    ActionSingleDataResponse<AuthRedirectionResponse> redirectionResponse =
        await _authRepository.getRedirectUri(accountName);
    if (redirectionResponse.isSuccess) {
      SocketAuthRequestModel socketAuthRequest = SocketAuthRequestModel(
          accountName: accountName,
          encryptedData: redirectionResponse.data!.encryptedData);
      socketProvider.sendDataToSocket(socketAuthRequest.toJsonString());
      authKey = redirectionResponse.data!.authKey;
    } else {
      onServerFailure();
    }
  }

  void _decrytDataFromSocket(String encryptedData) async {
    ActionSingleDataResponse<AuthDecryptionResponse> decryptionResponse =
        await _authRepository.getDecryptedHASToken(
            accountName, encryptedData, authKey!);
    if (decryptionResponse.isSuccess) {
      if (decryptionResponse.data!.token == null ||
          decryptionResponse.data!.expire == null) {
        showError(LocaleText.emHiveAuthTokenMessage);
        onFailure();
      } else {
        await _saveToLocal(decryptionResponse);
        onSuccess(null);
        resetListeners();
      }
    } else {
      onServerFailure();
    }
  }

  Future<void> _saveToLocal(
      ActionSingleDataResponse<AuthDecryptionResponse>
          decryptionResponse) async {
    UserAuthModel<HiveAuthModel> data = UserAuthModel(
      accountName: accountName.toLowerCase(),
      authType:
          ishiveKeyChainMethod ? AuthType.hiveKeyChain : AuthType.hiveAuth,
      imageUploadToken: decryptionResponse.data!.hsToken!,
      auth: HiveAuthModel(
        authKey: authKey!,
        token: decryptionResponse.data!.token!,
        expiry: decryptionResponse.data!.expire!,
      ),
    );
    await Future.wait([
      _localRepository.writeCurrentUser(data),
      MultiAccountProvider().addUserAccount(data)
    ]);
    _userStreamController.add(data);
  }

  @override
  void dispose() {
    super.dispose();
    _socketSubscription.cancel();
  }
}

