import 'package:flutter/material.dart';
import 'package:waves/core/common/widgets/buttons/duo_text_buttons.dart';

class UserProfileFollowMuteButtons extends StatelessWidget {
  const UserProfileFollowMuteButtons({super.key, this.buttonHeight});

  final double? buttonHeight;

  @override
  Widget build(BuildContext context) {
    return DuoTextButtons(
        buttonHeight: buttonHeight,
        buttonOneText: "Follow",
        buttonTwoText: "Mute",
        buttonOneOnTap: () {},
        buttonTwoOnTap: () {});
  }
}
