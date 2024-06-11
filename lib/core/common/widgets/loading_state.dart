import 'package:flutter/material.dart';

class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.isSliver = false});

  final bool isSliver;

  @override
  Widget build(BuildContext context) {
    return isSliver
        ? SliverFillRemaining(child: _widget(context))
        : _widget(context);
  }

  Center _widget(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}
