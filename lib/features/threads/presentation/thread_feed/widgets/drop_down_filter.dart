import 'package:cool_dropdown/cool_dropdown.dart';
import 'package:cool_dropdown/models/cool_dropdown_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/threads/presentation/thread_feed/controller/thread_feed_controller.dart';

class DropDownFilter extends StatefulWidget {
  const DropDownFilter({super.key, required this.onChanged});

  final Function(ThreadFeedType value) onChanged;

  @override
  State<DropDownFilter> createState() => _DropDownFilterState();
}

class _DropDownFilterState extends State<DropDownFilter> {
  final DropdownController _dropdownController = DropdownController();
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    _dropdownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.read<ThreadFeedController>();
    String defaultTypeString =
        controller.gethreadName(type: controller.threadType);
    return AnimatedContainer(
      margin: const EdgeInsets.only(right: 10),
      key: const ValueKey('dropdown'),
      duration: const Duration(milliseconds: 200),
      width: 150,
      height: 30,
      child: Stack(
        children: [
          CoolDropdown<ThreadFeedType>(
            controller: _dropdownController,
            defaultItem: CoolDropdownItem<ThreadFeedType>(
                isSelected: true,
                label: defaultTypeString,
                value: controller.threadType),
            dropdownItemOptions: DropdownItemOptions(
              render: DropdownItemRender.all,
              selectedBoxDecoration:
                  BoxDecoration(color: theme.colorScheme.tertiaryContainer),
              textStyle: TextStyle(color: theme.primaryColorDark),
              selectedTextStyle: TextStyle(color: theme.primaryColorDark),
            ),
            dropdownOptions: DropdownOptions(
              color: theme.colorScheme.tertiary,
            ),
            dropdownTriangleOptions:
                const DropdownTriangleOptions(height: 5, width: 0),
            dropdownList: ThreadFeedType.values
                .map(
                  (e) => CoolDropdownItem<ThreadFeedType>(
                      isSelected: e == controller.threadType,
                      label: controller.gethreadName(type: e),
                      value: e),
                )
                .toList(),
            onChange: (type) {
              widget.onChanged(type);
              _animateToPage(ThreadFeedType.values
                  .indexWhere((element) => element == type));
              setState(() {});
              _dropdownController.close();
            },
            resultOptions: ResultOptions(
              placeholder: defaultTypeString,
              render: ResultRender.all,
              openBoxDecoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                  color: Colors.transparent,
                  border: Border.all(color: Colors.transparent)),
              boxDecoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                  border: Border.all(color: Colors.transparent)),
              textStyle: const TextStyle(color: Colors.transparent),
            ),
          ),
          Positioned.fill(
            top: 5,
            left: 10,
            child: IgnorePointer(
              child: Padding(
                padding: const EdgeInsets.only(right: 24.0),
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: List.generate(
                    ThreadFeedType.values.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(right: 5.0),
                      child: Text(
                        controller.gethreadName(
                            type: ThreadFeedType.values[index]),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _animateToPage(int index) {
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 150), curve: Curves.easeIn);
  }
}
