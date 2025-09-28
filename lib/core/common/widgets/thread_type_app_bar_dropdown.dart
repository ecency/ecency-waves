import 'package:cool_dropdown/cool_dropdown.dart';
import 'package:cool_dropdown/models/cool_dropdown_item.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/core/utilities/generics/classes/thread.dart';

class ThreadTypeAppBarDropdown extends StatefulWidget {
  const ThreadTypeAppBarDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final ThreadFeedType value;
  final ValueChanged<ThreadFeedType> onChanged;

  @override
  State<ThreadTypeAppBarDropdown> createState() =>
      _ThreadTypeAppBarDropdownState();
}

class _ThreadTypeAppBarDropdownState
    extends State<ThreadTypeAppBarDropdown> {
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
    final String selectedLabel =
        Thread.gethreadName(type: widget.value);

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
              label: selectedLabel,
              value: widget.value,
            ),
            dropdownItemOptions: DropdownItemOptions(
              render: DropdownItemRender.all,
              selectedBoxDecoration:
                  BoxDecoration(color: Colors.grey.shade600),
              textStyle: TextStyle(color: theme.primaryColorDark),
              selectedTextStyle: TextStyle(color: theme.primaryColorDark),
            ),
            dropdownOptions: DropdownOptions(
              color: dropdownBackground,
            ),
            dropdownTriangleOptions:
                const DropdownTriangleOptions(height: 5, width: 0),
            dropdownList: types
                .map(
                  (e) => CoolDropdownItem<ThreadFeedType>(
                    isSelected: e == widget.value,
                    label: Thread.gethreadName(type: e),
                    value: e,
                  ),
                )
                .toList(),
            onChange: (ThreadFeedType type) {
              if (widget.value != type) {
                widget.onChanged(type);
              }
              _dropdownController.close();
            },
            resultOptions: ResultOptions(
              placeholder: selectedLabel,
              render: ResultRender.all,
              openBoxDecoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(6)),
                color: dropdownBackground,
                border: Border.all(color: Colors.transparent),
              ),
              boxDecoration: BoxDecoration(
                color: dropdownBackground,
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
                color: dropdownBackground,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      Thread.gethreadName(type: widget.value),
                      textAlign: TextAlign.center,
                      style: titleStyle,
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
          ),
        ],
      ),
    );
  }
}
