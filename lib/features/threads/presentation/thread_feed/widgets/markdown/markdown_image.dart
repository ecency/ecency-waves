import 'package:flutter/material.dart';
import 'package:waves/core/common/extensions/image_thumbs.dart';
import 'package:waves/core/common/extensions/ui.dart';
import 'package:waves/core/common/widgets/view_image.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';

class MarkdownImage extends StatelessWidget {
  const MarkdownImage({
    super.key,
    required this.item,
    required this.theme,
    required this.image,
  });

  final ThreadFeedModel item;
  final ThemeData theme;
  final String image;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            context.fadePageRoute(
              ViewImage(
                image: image,
                images: item.images != null ? item.images! : [image],
              ),
            ),
          );
        },
        child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            child: Image.network(
              context.proxyImage(image),
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) =>
                  frame == null
                      ? Container(
                          color: theme.colorScheme.tertiary,
                          height: 250,
                          width: double.infinity,
                          child: child,
                        )
                      : child,
              loadingBuilder: (context, child, loadingProgress) =>
                  loadingProgress?.cumulativeBytesLoaded !=
                          loadingProgress?.expectedTotalBytes
                      ? Container(
                          color: theme.colorScheme.tertiary,
                          height: 250,
                          width: double.infinity,
                          child: child,
                        )
                      : child,
            )),
      ),
    );
  }
}
