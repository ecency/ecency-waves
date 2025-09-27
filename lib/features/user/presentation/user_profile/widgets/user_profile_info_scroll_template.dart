import 'package:flutter/material.dart';

class UserProfileInfoScrollTemplate extends StatelessWidget {
  const UserProfileInfoScrollTemplate({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 520;
        if (isWide) {
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: children,
          );
        }

        return SizedBox(
          height: 35,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: children),
          ),
        );
      },
    );
  }
}
