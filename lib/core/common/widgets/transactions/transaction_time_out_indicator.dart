import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:waves/core/locales/locale_text.dart';

class TransactionTimeOutIndicator extends StatelessWidget {
  const TransactionTimeOutIndicator(
      {super.key,
      required this.tickValueListener,
      required this.timeOutvalueListener});
  final ValueNotifier<int?> tickValueListener;
  final ValueNotifier<int> timeOutvalueListener;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ValueListenableBuilder<int>(
        valueListenable: timeOutvalueListener,
        builder: (context, timeOutValue, child) {
          return ValueListenableBuilder<int?>(
            valueListenable: tickValueListener,
            builder: (context, tickValue, child) {
              return Column(
                children: [
                  LinearProgressIndicator(
                    value: getTickValue(tickValue, timeOutValue) ?? timeOutValue.toDouble(),
                    semanticsLabel: LocaleText.timeoutTimerForHiveAuthQr,
                    valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColorDark),
                    backgroundColor: theme.colorScheme.tertiary,
                  ),
                  const Gap(25),
                  Text(
                    tickValue?.toInt().toString() ?? "0",
                    style: theme.textTheme.bodyMedium,
                  )
                ],
              );
            },
          );
        },
      ),
    );
  }

  double? getTickValue(int? value,int timeOutValue){
    if(value!=null && !value.isInfinite && !value.isNaN){
      var cal = value.toDouble() / timeOutValue.toDouble();
      if(!cal.isInfinite && !cal.isNaN){
        return cal;
      }
    }
     return null;
  }
 
}
