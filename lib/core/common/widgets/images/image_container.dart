import 'package:flutter/material.dart';

class ImageContainer extends StatelessWidget {
  const ImageContainer({super.key, this.height, this.width, required this.url});

  final double? height;
  final double? width;
  final String? url;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiary,
        image: url == null || url!.isEmpty
            ? null
            : DecorationImage(
                image: NetworkImage('https://images.ecency.com/0x500/$url'),
                fit: BoxFit.cover),
      ),
    );
  }
}
