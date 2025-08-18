import 'package:cool_dropdown/cool_dropdown.dart';
import 'package:cool_dropdown/models/cool_dropdown_item.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/core/utilities/generics/classes/thread.dart';
import 'package:waves/features/threads/presentation/thread_feed/controller/thread_feed_controller.dart';

class DropDownFilter extends StatefulWidget {
  const DropDownFilter({super.key, required this.onChanged});

  final Function(ThreadFeedType value) onChanged;

  @override
  State<DropDownFilter> createState() => _DropDownFilterState();
}

class _DropDownFilterState extends State<DropDownFilter> {
  final DropdownController<ThreadFeedType> _dropdownController =
  DropdownController<ThreadFeedType>();

  @override
  void dispose() {
    _dropdownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.read<ThreadFeedController>();
    final List<ThreadFeedType> types = ThreadFeedType.values.sublist(1);
    final String defaultTypeString =
    Thread.gethreadName(type: controller.threadType);

    return AnimatedContainer(
      key: const ValueKey('dropdown'),
      duration: const Duration(milliseconds: 200),
      width: 175,
      child: Stack(
        children: [
          CoolDropdown<ThreadFeedType>(
            controller: _dropdownController,
            defaultItem: CoolDropdownItem<ThreadFeedType>(
              isSelected: true,
              label: defaultTypeString,
              value: controller.threadType,
            ),
            dropdownItemOptions: DropdownItemOptions(
              render: DropdownItemRender.all,
              selectedBoxDecoration: BoxDecoration(color: Colors.grey.shade600),
              textStyle: TextStyle(color: theme.primaryColorDark),
              selectedTextStyle: TextStyle(color: theme.primaryColorDark),
            ),
            dropdownOptions: DropdownOptions(
              color: theme.colorScheme.tertiary,
            ),
            dropdownTriangleOptions:
            const DropdownTriangleOptions(height: 5, width: 0),
            dropdownList: types
                .map(
                  (e) => CoolDropdownItem<ThreadFeedType>(
                isSelected: e == controller.threadType,
                label: Thread.gethreadName(type: e),
                value: e,
              ),
            )
                .toList(),
            onChange: (ThreadFeedType type) {
              if (controller.threadType != type) {
                widget.onChanged(type);
                setState(() {});
              }
              _dropdownController.close();
            },
            resultOptions: ResultOptions(
              placeholder: defaultTypeString,
              render: ResultRender.all,
              openBoxDecoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(6)),
                color: Colors.transparent,
                border: Border.all(color: Colors.transparent),
              ),
              boxDecoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: const BorderRadius.all(Radius.circular(6)),
                border: Border.all(color: Colors.transparent),
              ),
              textStyle: const TextStyle(color: Colors.transparent),
            ),
          ),
          Positioned.fill(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                color: theme.cardColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      Thread.gethreadName(type: controller.threadType),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(2),
                    const Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Icon(Icons.arrow_drop_down),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
