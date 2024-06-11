import 'package:flutter/material.dart';
import 'package:waves/core/utilities/enum.dart';

class TransactionListenersProvider {
  final int timeOutValue;

  late ValueNotifier<int> timeOutValueListener;

  TransactionListenersProvider({required this.timeOutValue}) {
    timeOutValueListener = ValueNotifier(timeOutValue);
  }

  ValueNotifier<TransactionState> transactionState =
      ValueNotifier(TransactionState.loading);
  ValueNotifier<String?> qrListener = ValueNotifier(null);
  ValueNotifier<int?> tickValueListener = ValueNotifier(null);

  void resetlisteners() {
    transactionState.value = TransactionState.loading;
    qrListener.value = null;
    tickValueListener.value = null;
  }
}
