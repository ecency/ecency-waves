import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout(
      {super.key, required this.isVertical, required this.children, this.gap});

  final bool isVertical;
  final List<Widget> children;
  final double? gap;

  @override
  Widget build(BuildContext context) {
    return isVertical
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: columnChildren,
          )
        : Row(
            children: rowChildren,
          );
  }

  List<Widget> get rowChildren {
    List<Widget> result = [];
    int i = 0;
    for (Widget child in children) {
      if (i != children.length - 1) {
        result.add(Expanded(child: child));
      } else {
        result.add(
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: gap ?? 5),
              child: child,
            ),
          ),
        );
      }
      i++;
    }
    return result;
  }

  List<Widget> get columnChildren {
    List<Widget> result = [];
    int i = 0;
    for (Widget child in children) {
      if (i != children.length - 1) {
        result.add(
          Padding(
            padding: EdgeInsets.only(bottom: gap ?? 5),
            child: child,
          ),
        );
      } else {
        result.add(child);
      }
      i++;
    }
    return result;
  }
}
