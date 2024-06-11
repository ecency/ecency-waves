import 'dart:async';

import 'package:flutter/services.dart';
import 'package:waves/core/providers/transaction_listeners_providers.dart';
import 'package:waves/core/socket/models/socket_wait_model.dart';
import 'package:waves/core/socket/models/socket_response.dart';
import 'package:waves/core/utilities/act.dart';
import 'package:waves/core/utilities/enum.dart';

class SocketWaitAction {
  static void call(
      {required SocketResponse data,
      required SocketInputType socketInputType,
      required TransactionListenersProvider listenersProvider,
      required bool isHiveKeyChainMethod,
      required String accountName,
      required String authKey,
      required Timer? timer,
      required VoidCallback onTimeOut,
      required VoidCallback resetListeners}) {
    String uuid = data.value;
    String jsonString =
        SocketWaitModel(accountName: accountName, uuid: uuid, authKey: authKey)
            .toJsonString();
    String qr = Act.generateQrString(socketInputType, jsonString);
    listenersProvider.qrListener.value = qr;
    if (isHiveKeyChainMethod) {
      listenersProvider.transactionState.value = TransactionState.redirection;
      Act.launchThisUrl(qr);
    } else {
      listenersProvider.transactionState.value = TransactionState.qr;
    }
    listenersProvider.tickValueListener.value =
        listenersProvider.timeOutValueListener.value;
    timer = Timer.periodic(const Duration(seconds: 1), (tickValue) {
      if (listenersProvider.tickValueListener.value == 0) {
        tickValue.cancel();
        onTimeOut();
      } else {
        if (listenersProvider.tickValueListener.value != null) {
          listenersProvider.tickValueListener.value =
              listenersProvider.tickValueListener.value! - 1;
        }
      }
    });
  }
}
