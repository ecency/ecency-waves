import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class UserProfileManaBar extends StatefulWidget {
  const UserProfileManaBar(
      {super.key,
      required this.icon,
      required this.mana,
      required this.toolTip,
      required this.manabarColor});

  final IconData icon;
  final int mana;
  final String toolTip;
  final Color manabarColor;

  @override
  State<UserProfileManaBar> createState() => _UserProfileManaBarState();
}

class _UserProfileManaBarState extends State<UserProfileManaBar> {
  double width = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final renderBox = context.findRenderObject() as RenderBox;
      final size = renderBox.size;
      setState(() {
        width = size.width;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: widget.toolTip,
      child: Row(
        children: [
          Icon(
            widget.icon,
            size: 18,
            color: widget.manabarColor,
          ),
          const Gap(15),
          Expanded(
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: 30,
                  decoration: BoxDecoration(
                      border: Border.all(color: widget.manabarColor),
                      color: Colors.transparent,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(40))),
                ),
                AnimatedContainer(
                  height: 30,
                  width: width,
                  duration: const Duration(milliseconds: 500),
                  decoration: BoxDecoration(
                    border: Border.all(color: widget.manabarColor),
                    color: widget.manabarColor,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(40),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    "100 %",
                    style: theme.textTheme.bodySmall!
                        .copyWith(color: theme.colorScheme.onPrimary),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
