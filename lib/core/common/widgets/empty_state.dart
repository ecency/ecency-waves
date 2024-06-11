import 'package:flutter/material.dart';
import 'package:waves/core/utilities/constants/ui_constants.dart';

class Emptystate extends StatefulWidget {
  const Emptystate(
      {super.key,
      required this.text,
      this.icon,
      this.showButton = false,
      this.onPressed,
      this.hideIcon = false,
      this.isSliver = false,
      this.buttonText = ""})
      : assert(
            !(showButton && onPressed == null), "OnTap call back is required");

  final String text;
  final IconData? icon;
  final bool showButton;
  final String buttonText;
  final VoidCallback? onPressed;
  final bool isSliver;
  final bool hideIcon;

  @override
  State<Emptystate> createState() => _EmptystateState();
}

class _EmptystateState extends State<Emptystate> {
  late final IconData icon;

  @override
  void initState() {
    icon = Icons.hourglass_empty;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return widget.isSliver
        ? SliverFillRemaining(
            child: _state(theme),
          )
        : _state(theme);
  }

  Padding _state(ThemeData theme) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: kScreenHorizontalPaddingDigit),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
         if(!widget.hideIcon) Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Icon(
              icon,
              size: 100,
              color: theme.primaryColorDark,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(widget.text,
                textAlign: TextAlign.center,
                style: theme.textTheme.displaySmall),
          ),
          widget.showButton
              ? Center(
                  child: Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: SizedBox(
                        height: 28,
                        child: OutlinedButton(
                          onPressed: widget.onPressed,
                          style: OutlinedButton.styleFrom(
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            side: BorderSide(
                              color: theme.primaryColorDark,
                            ),
                          ),
                          child: Text(
                            widget.buttonText,
                            style: theme.textTheme.bodySmall!
                                .copyWith(color: theme.primaryColorLight),
                          ),
                        ),
                      )),
                )
              : const SizedBox.shrink()
        ],
      ),
    );
  }
}
