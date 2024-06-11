import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/utilities/act.dart';
import 'package:waves/core/common/widgets/transactions/transaction_time_out_indicator.dart';

class TransactionQrWidget extends StatelessWidget {
  const TransactionQrWidget(
      {super.key,
      required this.qrListener,
      required this.tickValueListener,
      required this.timeOutvalueListener});

  final ValueNotifier<String?> qrListener;
  final ValueNotifier<int?> tickValueListener;
  final ValueNotifier<int> timeOutvalueListener;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: qrListener,
      builder: (context, qr, child) {
        if (qr == null) {
          return const SizedBox.shrink();
        } else {
          return Column(
            children: [
              const Gap(10),
              Image.asset('assets/images/auth/hive_auth_button.png'),
              const Gap(15),
              Text(LocaleText.scanTapQRCode,textAlign: TextAlign.center,),
              const Gap(20),
              _qrImage(qr),
              const Gap(30),
              TransactionTimeOutIndicator(
                  tickValueListener: tickValueListener,
                  timeOutvalueListener: timeOutvalueListener)
            ],
          );
        }
      },
    );
  }

  InkWell _qrImage(String? qr) {
    return InkWell(
      child: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: QrImageView(
          data: qr!,
          size: 200,
          gapless: true,
        ),
      ),
      onTap: () {
        Act.launchThisUrl(qr);
      },
    );
  }
}
