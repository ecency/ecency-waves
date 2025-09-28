import 'package:flutter/material.dart';
import 'package:waves/core/common/extensions/image_thumbs.dart';
import 'package:waves/core/common/widgets/inkwell_wrapper.dart';

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
    final mediaQuery = MediaQuery.of(context);
    const double tabletBreakpoint = 600;
    final double shortestSide = mediaQuery.size.shortestSide;
    final bool isLargeScreen = shortestSide >= tabletBreakpoint;
    final double avatarScale = isLargeScreen ? 1.15 : 1.0;
    final double baseRadius = radius ?? 20;
    final double effectiveRadius = baseRadius * avatarScale;
    final double effectiveIconSize = (defaultIconSize ?? 30) * avatarScale;
    final double effectiveVerticalPadding = verticalPadding * avatarScale;
    final String avatarSize = _avatarSizeForRadius(effectiveRadius);
    return InkWellWrapper(
        onTap: onTap,
        borderRadius:
            onTap != null ? const BorderRadius.all(Radius.circular(100)) : null,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: effectiveVerticalPadding),
          child: CircleAvatar(
            radius: effectiveRadius,
            foregroundImage: url != null && url!.isNotEmpty
                ? NetworkImage(
                    context.userOwnerThumb(url!, size: avatarSize),
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

  String _avatarSizeForRadius(double radiusValue) {
    if (radiusValue <= 20) {
      return 'small';
    } else if (radiusValue <= 40) {
      return 'medium';
    } else {
      return 'large';
    }
  }
}
