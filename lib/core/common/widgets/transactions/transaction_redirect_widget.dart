import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/utilities/act.dart';
import 'package:waves/core/common/widgets/transactions/transaction_time_out_indicator.dart';

class TransactionRedirectWidget extends StatelessWidget {
  const TransactionRedirectWidget(
      {super.key,
      required this.qrListener,
      required this.tickValueListener,
      required this.timeOutvalueListener});

  final ValueNotifier<String?> qrListener;
  final ValueNotifier<int?> tickValueListener;
  final ValueNotifier<int> timeOutvalueListener;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ValueListenableBuilder<String?>(
      valueListenable: qrListener,
      builder: (context, qr, child) {
        if (qr == null) {
          return const SizedBox.shrink();
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Gap(10),
               Text(
                LocaleText.authorizeThisRequestWithKeyChainForHiveApp,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 25),
                child: ElevatedButton(
                  onPressed: () {
                    Act.launchThisUrl(qr);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  child: Image.asset('assets/images/auth/hive-keychain-image.png',
                      width: 220),
                ),
              ),
              const Gap(20),
              TransactionTimeOutIndicator(
                  tickValueListener: tickValueListener,
                  timeOutvalueListener: timeOutvalueListener)
            ],
          );
        }
      },
    );
  }
}
