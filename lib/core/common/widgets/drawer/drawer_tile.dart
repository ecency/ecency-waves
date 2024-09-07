import 'package:flutter/material.dart';
import 'package:waves/core/common/widgets/inkwell_wrapper.dart';

class DrawerTile extends StatelessWidget {
  const DrawerTile(
      {super.key,
      this.onTap,
      required this.text,
      required this.icon,
      this.color,
      this.leftPadding, this.trailing});

  final VoidCallback? onTap;
  final String text;
  final IconData icon;
  final double? leftPadding;
  final Widget? trailing;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return InkWellWrapper(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(left: leftPadding ?? 0.0),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          leading: Icon(icon, color: color,),
          title: Text(text, style: TextStyle(color: color),),
          trailing: trailing,
        ),
      ),
    );
  }
}
