import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/widgets/locale_aware_consumer.dart';
import 'package:waves/core/common/widgets/thread_type_app_bar_dropdown.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/threads/presentation/thread_feed/controller/thread_feed_controller.dart';

class DropDownFilter extends StatelessWidget {
  const DropDownFilter({super.key, required this.onChanged});

  final ValueChanged<ThreadFeedType> onChanged;

  @override
  Widget build(BuildContext context) {
    return LocaleAwareSelector<ThreadFeedController, ThreadFeedType>(
      selector: (_, controller) => controller.threadType,
      builder: (context, selectedType, _) {
        return ThreadTypeAppBarDropdown(
          value: selectedType,
          onChanged: (type) {
            if (type != selectedType) {
              onChanged(type);
            }
          },
        );
      },
    );
  }
}
