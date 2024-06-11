import 'package:flutter/material.dart';

class ExpandableItem extends StatefulWidget {
  const ExpandableItem(
      {super.key,
      required this.header,
      required this.children,
      this.expandedColor,
      this.isExpanded});

  final Widget header;
  final List<Widget> children;
  final Color? expandedColor;
  final bool? isExpanded;

  @override
  State<ExpandableItem> createState() => _ExpandableItemState();
}

class _ExpandableItemState extends State<ExpandableItem> {
  late bool isExpanded;

  @override
  void initState() {
    isExpanded = widget.isExpanded ?? true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _buildPanel(theme);
  }

  Widget _buildPanel(ThemeData theme) {
    return ExpansionPanelList(
      elevation: 0,
      materialGapSize: 0,
      expandedHeaderPadding: const EdgeInsets.only(top: 5),
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          this.isExpanded = isExpanded;
        });
      },
      children: [
        ExpansionPanel(
          backgroundColor: isExpanded
              ? widget.expandedColor ?? Colors.transparent
              : Colors.transparent,
          headerBuilder: (BuildContext context, bool isExpanded) {
            return widget.header;
          },
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.children,
          ),
          isExpanded: isExpanded,
        )
      ],
    );
  }
}
