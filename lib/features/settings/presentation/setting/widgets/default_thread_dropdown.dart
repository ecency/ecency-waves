import 'package:cool_dropdown/cool_dropdown.dart';
import 'package:cool_dropdown/models/cool_dropdown_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/core/utilities/generics/classes/thread.dart';
import 'package:waves/features/settings/presentation/setting/controller/settings_controller.dart';

class DefaultThreadDropdown extends StatefulWidget {
  const DefaultThreadDropdown({super.key});

  @override
  State<DefaultThreadDropdown> createState() => _DefaultThreadDropdownState();
}

class _DefaultThreadDropdownState extends State<DefaultThreadDropdown> {
  final DropdownController _dropdownController = DropdownController();
  late ThreadFeedType selectedThreadType;

  @override
  void initState() {
    selectedThreadType = context.read<SettingsController>().readThreadType();
    super.initState();
  }

  @override
  void dispose() {
    _dropdownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settingsController = context.read<SettingsController>();
    final List types = ThreadFeedType.values.sublist(1);
    String defaultTypeString = Thread.gethreadName(type: selectedThreadType);
    return SizedBox(
      width: 130,
      height: 40,
      child: CoolDropdown<ThreadFeedType>(
        key: UniqueKey(),
        controller: _dropdownController,
        defaultItem: CoolDropdownItem<ThreadFeedType>(
            isSelected: true,
            label: defaultTypeString,
            value: selectedThreadType),
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
        dropdownList: types
            .map(
              (e) => CoolDropdownItem<ThreadFeedType>(
                  isSelected: e == selectedThreadType,
                  selectedIcon: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 12,
                      backgroundImage:
                          AssetImage(Thread.getThreadImage(type: e)),
                    ),
                  ),
                  label: Thread.gethreadName(type: e),
                  value: e),
            )
            .toList(),
        onChange: (type) {
          if (selectedThreadType != type) {
            setState(() {
              selectedThreadType = type;
              settingsController.saveThreadType(type);
            });
          }
          _dropdownController.close();
        },
        resultOptions: ResultOptions(
            placeholder: defaultTypeString,
            render: ResultRender.all,
            openBoxDecoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(6)),
                color: theme.colorScheme.tertiary,
                border: Border.all(color: Colors.transparent)),
            boxDecoration: BoxDecoration(
                color: theme.colorScheme.tertiary,
                borderRadius: const BorderRadius.all(Radius.circular(6)),
                border: Border.all(color: Colors.transparent)),
            textStyle: theme.textTheme.bodyMedium!),
      ),
    );
  }
}
