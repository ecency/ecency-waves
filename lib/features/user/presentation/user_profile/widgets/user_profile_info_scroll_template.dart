import 'package:flutter/material.dart';
import 'package:waves/core/utilities/constants/ui_constants.dart';

class UserProfileInfoScrollTemplate extends StatelessWidget {
  const UserProfileInfoScrollTemplate({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: kScreenHorizontalPaddingDigit,
            ),
            child: SizedBox(
              height: 35,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: children),
              ),
            )),
      ],
    );
  }
}
