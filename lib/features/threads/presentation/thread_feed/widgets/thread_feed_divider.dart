import 'package:flutter/material.dart';

class ThreadFeedDivider extends StatelessWidget {
  const ThreadFeedDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Divider(
        height: 1,
      ),
    );
  }
}
