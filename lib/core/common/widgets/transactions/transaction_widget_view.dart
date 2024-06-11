import 'package:flutter/material.dart';
import 'package:waves/core/common/widgets/loading_state.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/core/providers/transaction_listeners_providers.dart';
import 'package:waves/core/common/widgets/transactions/transaction_qr_widget.dart';
import 'package:waves/core/common/widgets/transactions/transaction_redirect_widget.dart';

class TransactionWidgetView extends StatelessWidget {
  const TransactionWidgetView(
      {super.key, required this.listenerProvider,});

  final TransactionListenersProvider listenerProvider;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TransactionState>(
      valueListenable: listenerProvider.transactionState,
      builder: (context, state, child) {
          if (state == TransactionState.loading) {
          return const LoadingState();
        } else if (state == TransactionState.qr) {
          return TransactionQrWidget(
            qrListener: listenerProvider.qrListener,
            tickValueListener: listenerProvider.tickValueListener,
            timeOutvalueListener: listenerProvider.timeOutValueListener,
          );
        } else {
          return TransactionRedirectWidget(
            qrListener: listenerProvider.qrListener,
            tickValueListener: listenerProvider.tickValueListener,
            timeOutvalueListener: listenerProvider.timeOutValueListener,
          );
        }
      },
    );
  }
}
