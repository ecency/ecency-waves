import 'package:flutter/material.dart';
import 'package:waves/core/common/extensions/image_thumbs.dart';
import 'package:waves/core/common/widgets/inkwell_wrapper.dart';
import 'package:waves/core/utilities/responsive/responsive_layout.dart';

class UserProfileImage extends StatelessWidget {
  const UserProfileImage(
      {super.key,
      this.url,
      this.radius,
      this.verticalPadding = 12,
      this.fillColor,
      this.defaultIconSize,
      this.onTap});

  final String? url;
  final double? radius;
  final double verticalPadding;
  final VoidCallback? onTap;
  final double? defaultIconSize;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final responsive = ResponsiveLayout.of(context);
    final baseRadius = radius ?? 20;
    final effectiveRadius = responsive.scaleAvatar(baseRadius);
    final effectivePadding = responsive.scaleComponent(verticalPadding);
    final effectiveIconSize = responsive.scaleIcon(defaultIconSize ?? 30);

    return InkWellWrapper(
        onTap: onTap,
        borderRadius:
            onTap != null ? const BorderRadius.all(Radius.circular(100)) : null,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: effectivePadding),
          child: CircleAvatar(
            radius: effectiveRadius,
            foregroundImage: url != null && url!.isNotEmpty
                ? NetworkImage(
                    context.userOwnerThumb(
                      url!,
                      size: _avatarSize(effectiveRadius),
                    ),
                  )
                : null,
            backgroundColor: fillColor ?? theme.colorScheme.tertiary,
            child: Icon(
              Icons.account_circle,
              size: effectiveIconSize,
            ),
          ),
        ));
  }

  String _avatarSize(double radius) {
    if (radius <= 20) {
      return 'small';
    } else if (radius <= 40) {
      return 'medium';
    } else {
      return 'large';
    }
  }
}
