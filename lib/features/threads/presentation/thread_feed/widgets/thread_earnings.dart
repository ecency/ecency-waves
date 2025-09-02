import 'package:flutter/material.dart';
import 'package:waves/core/common/widgets/icon_with_text.dart';

class ThreadEarnings extends StatelessWidget {
  const ThreadEarnings(
      {super.key,
      required this.pendingPayoutvalue,
      this.iconColor,
      this.iconGap,
      this.textStyle});

  final String? pendingPayoutvalue;
  final Color? iconColor;
  final double? iconGap;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    var value =
        double.parse(pendingPayoutvalue?.replaceAll(" HBD", "") ?? "0.0");
    return IconWithText(
      padding: const EdgeInsets.only(top: 2, right: 2, bottom: 2),
      icon: Icons.attach_money,
      iconColor: iconColor,
      text: value.toStringAsFixed(3),
      textStyle: textStyle,
      iconGap: iconGap,
      borderRadius: const BorderRadius.all(Radius.circular(8)),
    );
  }
}
