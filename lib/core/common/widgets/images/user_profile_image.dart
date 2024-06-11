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
      this.resize = false,
      this.fit,
      this.defaultIconSize,
      this.onTap});

  final String? url;
  final double? radius;
  final double verticalPadding;
  final BoxFit? fit;
  final bool resize;
  final VoidCallback? onTap;
  final double? defaultIconSize;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWellWrapper(
        onTap: onTap,
        borderRadius:
            onTap != null ? const BorderRadius.all(Radius.circular(100)) : null,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: verticalPadding),
          child: CircleAvatar(
            radius: radius ?? 20,
            foregroundImage:url!=null && url!.isNotEmpty ?  NetworkImage(
              context.resizedImage(
                resize
                    ? context.resizedImage(context.userOwnerThumb(url!),
                        height: height, width: width)
                    : context.userOwnerThumb(url!),
                height: height,
                width: width,
              ),
            ) : null,
            backgroundColor: fillColor ?? theme.colorScheme.tertiary,
            child: Icon(
              Icons.account_circle,
              size: defaultIconSize ?? 30,
            ),
          ),
        ));
  }

  int? get width {
    if (radius == null) {
      return null;
    } else {
      return radius!.toInt() * 10;
    }
  }

  int? get height {
    if (radius == null) {
      return null;
    } else {
      return radius!.toInt() * 6;
    }
  }
}
