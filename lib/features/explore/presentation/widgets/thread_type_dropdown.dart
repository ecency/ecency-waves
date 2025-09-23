import 'package:flutter/material.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/core/utilities/generics/classes/thread.dart';

class ThreadTypeDropdown extends StatelessWidget {
  final ThreadFeedType value;
  final ValueChanged<ThreadFeedType> onChanged;

  const ThreadTypeDropdown({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appBarTheme = theme.appBarTheme;
    final Color foregroundColor =
        appBarTheme.foregroundColor ?? theme.colorScheme.onSurface;
    final TextStyle? titleStyle = appBarTheme.titleTextStyle ??
        theme.textTheme.titleMedium?.copyWith(color: foregroundColor);

    return DropdownButtonHideUnderline(
      child: DropdownButton<ThreadFeedType>(
        value: value,
        iconEnabledColor: foregroundColor,
        iconDisabledColor: foregroundColor,
        dropdownColor:
            appBarTheme.backgroundColor ?? theme.colorScheme.surface,
        style: titleStyle,
        onChanged: (v) {
          if (v != null) {
            onChanged(v);
          }
        },
      items: ThreadFeedType.values
          .where((e) => e != ThreadFeedType.all)
          .map((e) => DropdownMenuItem(
                value: e,
                child: Text(Thread.gethreadName(type: e)),
              ))
          .toList(),
      ),
    );
  }
}
