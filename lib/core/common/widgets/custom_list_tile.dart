import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:waves/core/common/widgets/inkwell_wrapper.dart';

class CustomListTile extends StatelessWidget {
  const CustomListTile(
      {super.key,
      required this.leading,
      required this.titleText,
      this.trailing,
      this.onTap,
      this.color,
      this.padding,
      this.subTitle,
      this.titleTrailing,
      this.borderRadius});

  final Widget leading;
  final String titleText;
  final Widget? trailing;
  final Widget? titleTrailing;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Color? color;
  final BorderRadius? borderRadius;
  final Widget? subTitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWellWrapper(
      onTap: onTap,
      borderRadius: borderRadius,
      child: Container(
        decoration: BoxDecoration(color: color, borderRadius: borderRadius),
        padding:
            padding ?? const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            leading,
            const Gap(12.5),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        titleText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium,
                      ),
                      if (titleTrailing != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: titleTrailing!,
                        )
                    ],
                  ),
                  if (subTitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: subTitle!,
                    )
                ],
              ),
            ),
            const Gap(20),
            trailing ?? const SizedBox.shrink()
          ],
        ),
      ),
    );
  }
}
