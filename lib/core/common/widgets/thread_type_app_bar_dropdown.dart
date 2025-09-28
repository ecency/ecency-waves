import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/core/utilities/generics/classes/thread.dart';

class ThreadTypeAppBarDropdown extends StatelessWidget {
  const ThreadTypeAppBarDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final ThreadFeedType value;
  final ValueChanged<ThreadFeedType> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appBarTheme = theme.appBarTheme;
    final Color dropdownBackground =
        appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor;
    final Color foregroundColor =
        appBarTheme.foregroundColor ?? theme.colorScheme.onSurface;
    final TextStyle titleStyle =
        (appBarTheme.titleTextStyle ?? theme.textTheme.titleMedium)?.copyWith(
              color: foregroundColor,
            ) ??
            TextStyle(color: foregroundColor);

    final List<ThreadFeedType> types =
        ThreadFeedType.values.where((e) => e != ThreadFeedType.all).toList();
    final String selectedLabel = Thread.gethreadName(type: value);

    return PopupMenuButton<ThreadFeedType>(
      padding: EdgeInsets.zero,
      position: PopupMenuPosition.under,
      tooltip: '',
      color: dropdownBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      constraints: const BoxConstraints(minWidth: 175),
      onSelected: (type) {
        if (type != value) {
          onChanged(type);
        }
      },
      itemBuilder: (context) => types
          .map(
            (type) => PopupMenuItem<ThreadFeedType>(
              value: type,
              child: Row(
                children: [
                  if (type == value) ...[
                    Icon(
                      Icons.check,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    const Gap(8),
                  ] else
                    const SizedBox(width: 26),
                  Expanded(
                    child: Text(
                      Thread.gethreadName(type: type),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
      child: SizedBox(
        key: const ValueKey('dropdown'),
        width: 175,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: dropdownBackground,
            borderRadius: const BorderRadius.all(Radius.circular(6)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  selectedLabel,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: titleStyle,
                ),
              ),
              const Gap(2),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Icon(
                  Icons.arrow_drop_down,
                  color: foregroundColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
