import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/extensions/platform_navigation.dart';
import 'package:waves/core/common/widgets/images/user_profile_image.dart';
import 'package:waves/core/routes/route_keys.dart';
import 'package:waves/core/routes/routes.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/explore/models/trending_author_model.dart';
import 'package:waves/features/explore/models/trending_tag_model.dart';
import 'package:waves/features/explore/presentation/controller/explore_controller.dart';
import 'package:waves/features/explore/presentation/widgets/thread_type_dropdown.dart';

class ExploreView extends StatelessWidget {
  const ExploreView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: ChangeNotifierProvider(
        create: (_) => ExploreController(),
        child: Builder(builder: (context) {
          final controller = context.read<ExploreController>();
          return Scaffold(
            appBar: AppBar(
              title: Selector<ExploreController, ThreadFeedType>(
                selector: (_, c) => c.threadType,
                builder: (context, type, _) => ThreadTypeDropdown(
                  value: type,
                  onChanged: controller.onChangeThreadType,
                ),
              ),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Tags'),
                  Tab(text: 'Users'),
                ],
              ),
            ),
            body: SafeArea(
              child: TabBarView(
                children: [
                  _TagsTab(),
                  _UsersTab(),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _TagsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = context.read<ExploreController>();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Selector<ExploreController, ViewState>(
        selector: (_, c) => c.tagsState,
        builder: (context, state, _) {
          if (state == ViewState.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state == ViewState.data) {
            final List<TrendingTagModel> tags = controller.tags;
            return ListView.builder(
              itemCount: tags.length,
              itemBuilder: (context, index) {
                final tag = tags[index];
                return ListTile(
                  title: Text('#${tag.tag}'),
                  trailing: _PostsBadge(count: tag.posts),
                  onTap: () {
                    context.platformPushNamed(
                      Routes.tagFeedView,
                      queryParameters: {
                        RouteKeys.tag: tag.tag,
                        RouteKeys.threadType:
                            enumToString(controller.threadType),
                      },
                    );
                  },
                );
              },
            );
          } else {
            return const Center(child: Text('Error'));
          }
        },
      ),
    );
  }
}

class _UsersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = context.read<ExploreController>();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Selector<ExploreController, ViewState>(
        selector: (_, c) => c.authorsState,
        builder: (context, state, _) {
          if (state == ViewState.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state == ViewState.data) {
            final List<TrendingAuthorModel> authors = controller.authors;
            return ListView.builder(
              itemCount: authors.length,
              itemBuilder: (context, index) {
                final a = authors[index];
                return ListTile(
                  leading: UserProfileImage(
                    url: a.author,
                  ),
                  title: Text(a.author),
                  trailing: _PostsBadge(count: a.posts),
                  onTap: () {
                    context.platformPushNamed(
                      Routes.userProfileView,
                      queryParameters: {
                        RouteKeys.accountName: a.author,
                        RouteKeys.threadType:
                            enumToString(controller.threadType),
                      },
                    );
                  },
                );
              },
            );
          } else {
            return const Center(child: Text('Error'));
          }
        },
      ),
    );
  }
}

class _PostsBadge extends StatelessWidget {
  const _PostsBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CircleAvatar(
      radius: 14,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Text(
        '$count',
        style: theme.textTheme.bodySmall,
      ),
    );
  }
}
