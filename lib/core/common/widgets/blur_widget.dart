import 'dart:ui';

import 'package:flutter/material.dart';

class Blurwidget extends StatelessWidget {
  const Blurwidget(
      {super.key,
      this.sigmaX,
      this.sigmaY,
      this.beginAlignment,
      this.endAlignment, required this.child});

  final double? sigmaX;
  final double? sigmaY;
  final Alignment? beginAlignment;
  final Alignment? endAlignment;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: beginAlignment ?? Alignment.bottomCenter,
          end: endAlignment ?? Alignment.topCenter,
          colors: [
            theme.primaryColorLight,
            theme.primaryColorLight.withOpacity(0.2)
          ],
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: sigmaX ?? 5, sigmaY: sigmaY ?? 5),
          child: child,
        ),
      ),
    );
  }
}
