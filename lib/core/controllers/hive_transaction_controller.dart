import 'dart:async';
import 'package:flutter/material.dart';
import 'package:waves/core/dependency_injection/dependency_injection.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/providers/transaction_listeners_providers.dart';
import 'package:waves/core/socket/actions/socket_auth_wait.dart';
import 'package:waves/core/socket/models/socket_response.dart';
import 'package:waves/core/socket/provider/socket_provider.dart';
import 'package:waves/core/utilities/enum.dart';

class HiveTransactionController {
  late final TransactionListenersProvider listenersProvider;
  final SocketProvider socketProvider = getIt<SocketProvider>();
  final Function(String) showError;
  final Function(dynamic) onSuccess;
  final VoidCallback onFailure;
  final bool ishiveKeyChainMethod;
  Timer? timer;

  HiveTransactionController({
    required this.onFailure,
    required this.ishiveKeyChainMethod,
    required this.showError,
    required this.onSuccess,
  }) {
    listenersProvider =
        TransactionListenersProvider(timeOutValue: socketProvider.timeOutValue);
  }

  void onSocketSignWait(SocketResponse data, SocketInputType type,
      String accountName, String authKey) {
    timer = SocketWaitAction.call(
      data: data,
      socketInputType: type,
      listenersProvider: listenersProvider,
      isHiveKeyChainMethod: ishiveKeyChainMethod,
      accountName: accountName,
      host: socketProvider.connectedServer,
      authKey: authKey,
      onTimeOut: () => onServerFailure(message: LocaleText.emTimeOutMessage),
      onHiveAuthAppMissing: ishiveKeyChainMethod
          ? null
          : () => showError(LocaleText.emHiveAuthAppNotFound),
    );
  }

  @protected
  void resetListeners() {
    timer?.cancel();
    listenersProvider.resetlisteners();
  }

  void onServerFailure({String? message}) {
    showError(message ?? LocaleText.emDefaultMessage);
    onFailure();
    resetListeners();
  }

  void initTransactionProcess() {}

  void dispose() {
    resetListeners();
  }
}
