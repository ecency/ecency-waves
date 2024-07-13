import 'package:flutter/material.dart';

class PaginationLoader extends StatelessWidget {
  const PaginationLoader({super.key, required this.pageVisibilityListener});

  final bool Function(BuildContext) pageVisibilityListener;

  @override
  Widget build(BuildContext context) {
    final bool showLoader = pageVisibilityListener(context);
    return Visibility(
      visible: showLoader,
      child: Padding(
        padding: const EdgeInsets.only(top: 15.0,bottom: 10),
        child: Center(
          child: SizedBox(
            height: 25,
            width: 25,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
