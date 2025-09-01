import 'package:flutter/material.dart';

class BackToTopButton extends StatelessWidget {
  const BackToTopButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      heroTag: null,
      onPressed: onPressed,
      child: const Icon(Icons.arrow_upward),
    );
  }
}

