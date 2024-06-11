import 'package:flutter/material.dart';
import 'package:waves/core/common/widgets/inkwell_wrapper.dart';

class DrawerTile extends StatelessWidget {
  const DrawerTile(
      {super.key,
      this.onTap,
      required this.text,
      required this.icon,
      this.leftPadding, this.trailing});

  final VoidCallback? onTap;
  final String text;
  final IconData icon;
  final double? leftPadding;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWellWrapper(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(left: leftPadding ?? 0.0),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          leading: Icon(icon),
          title: Text(text),
          trailing: trailing,
        ),
      ),
    );
  }
}
