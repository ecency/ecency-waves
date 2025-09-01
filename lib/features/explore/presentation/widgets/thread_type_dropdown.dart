import 'package:flutter/material.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/core/utilities/generics/classes/thread.dart';

class ThreadTypeDropdown extends StatelessWidget {
  final ThreadFeedType value;
  final ValueChanged<ThreadFeedType> onChanged;

  const ThreadTypeDropdown({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<ThreadFeedType>(
      value: value,
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
    );
  }
}
