import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/utilities/constants/ui_constants.dart';

class ErrorState extends StatelessWidget {
  const ErrorState(
      {super.key,
      this.showRetryButton = false,
      this.onTapRetryButton,
      this.isSliver = false});

  final bool showRetryButton;
  final Function()? onTapRetryButton;
  final bool isSliver;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return isSliver
        ? SliverFillRemaining(
            child: _widget(theme),
          )
        : _widget(theme);
  }

  Center _widget(ThemeData theme) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.only(
              bottom: 70,
              left: kScreenHorizontalPaddingDigit,
              right: kScreenHorizontalPaddingDigit),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.error,
                color: theme.primaryColorDark,
                size: 80,
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                LocaleText.sorryWeAreUnableToReachOurServer,
                style: theme.textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              showRetryButton
                  ? CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: onTapRetryButton,
                      child: Text(
                        LocaleText.tryAgain,
                        style: theme.textTheme.displaySmall!
                            .copyWith(color: theme.primaryColor),
                      ))
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
