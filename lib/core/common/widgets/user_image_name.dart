import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:waves/core/common/widgets/images/user_profile_image.dart';

class UserImageName extends StatelessWidget {
  const UserImageName(
      {super.key,
      required this.name,
      this.onTap,
      this.imageRadius,
      this.reverse = false,
      this.textStyle,
      this.isExpanded = false,
      this.displayName,
      this.maxLines});

  final String name;
  final String? displayName;
  final VoidCallback? onTap;
  final double? imageRadius;
  final bool reverse;
  final TextStyle? textStyle;
  final bool isExpanded;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          color: Colors.transparent,
          child: Row(
            children: [
              !reverse ? _userProfileImage() : _userText(),
              const Gap(15),
              !reverse
                  ? isExpanded
                      ? Expanded(child: _userText())
                      : _userText()
                  : _userProfileImage(),
            ],
          ),
        ),
      ),
    );
  }

  AutoSizeText _userText() => AutoSizeText(
        displayName ?? name,
        style: textStyle,
        maxLines: maxLines ?? 1,
        minFontSize: 11,
        overflow: TextOverflow.ellipsis,
      );

  UserProfileImage _userProfileImage() {
    return UserProfileImage(
      url: name,
      radius: imageRadius,
    );
  }
}
