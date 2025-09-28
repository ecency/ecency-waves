import 'package:flutter/material.dart';
import 'package:waves/core/common/widgets/thread_type_app_bar_dropdown.dart';
import 'package:waves/core/utilities/enum.dart';

class ThreadTypeDropdown extends StatelessWidget {
  final ThreadFeedType value;
  final ValueChanged<ThreadFeedType> onChanged;

  const ThreadTypeDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ThreadTypeAppBarDropdown(
      value: value,
      onChanged: onChanged,
    );
  }
}
