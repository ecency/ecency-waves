import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:waves/core/common/widgets/text_box.dart';
import 'package:waves/core/routes/route_keys.dart';
import 'package:waves/core/routes/routes.dart';

class TagScroll extends StatelessWidget {
  const TagScroll({super.key, required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 50,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(tags.length, (index) {
            String tag = tags[index];
            return Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: TextBox(
                borderRadius: 30,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                backgroundColor: theme.colorScheme.tertiary,
                text: tag,
                onTap: () {
                  context.pushNamed(
                    Routes.tagFeedView,
                    queryParameters: {RouteKeys.tag: tag},
                  );
                },
              ),
            );
          }),
        ),
      ),
    );
  }
}
