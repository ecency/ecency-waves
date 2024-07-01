import 'package:flutter/material.dart';

class ScrollEndListener extends StatelessWidget {
  const ScrollEndListener({super.key, required this.child, required this.loadNextPage});

  final Widget child;
  final VoidCallback loadNextPage;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels ==
              notification.metrics.maxScrollExtent) {
            loadNextPage();
          }
          return true;
        },
        child: child);
  }
}
