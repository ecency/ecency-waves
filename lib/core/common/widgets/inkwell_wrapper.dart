import 'package:flutter/material.dart';

class InkWellWrapper extends StatelessWidget {
  const InkWellWrapper(
      {super.key,
      required this.child,
      this.onTap,
      this.borderRadius,
      this.isStackWrapper = false});

  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final bool isStackWrapper;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (!isStackWrapper)
          InkWell(
            onTap: onTap,
            borderRadius: borderRadius,
            child: child,
          )
        else
          child,
        if (isStackWrapper)
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              borderRadius: borderRadius,
              child: InkWell(
                onTap: onTap,
                borderRadius: borderRadius,
                child: const IgnorePointer(child: SizedBox()),
              ),
            ),
          )
      ],
    );
  }
}
