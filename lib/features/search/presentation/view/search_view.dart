import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/extensions/platform_navigation.dart';
import 'package:waves/core/common/widgets/images/user_profile_image.dart';
import 'package:waves/core/routes/route_keys.dart';
import 'package:waves/core/routes/routes.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/search/models/search_tag_model.dart';
import 'package:waves/features/search/models/search_user_model.dart';
import 'package:waves/features/search/presentation/controller/search_view_controller.dart';

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: ChangeNotifierProvider(
        create: (_) => SearchViewController(),
        child: Consumer<SearchViewController>(
          builder: (context, controller, _) {
            return Scaffold(
              appBar: AppBar(
                titleSpacing: 0,
                title: _SearchInput(controller: controller),
                bottom: const TabBar(
                  tabs: [
                    Tab(text: 'Users'),
                    Tab(text: 'Hashtags'),
                  ],
                ),
              ),
              body: const SafeArea(
                child: TabBarView(
                  children: [
                    _UsersTab(),
                    _TagsTab(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SearchInput extends StatelessWidget {
  const _SearchInput({required this.controller});

  final SearchViewController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller.queryController,
        focusNode: controller.focusNode,
        autofocus: true,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search users or hashtags',
          prefixIcon: const Icon(Icons.search),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          filled: true,
          fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.4),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }
}

class _UsersTab extends StatelessWidget {
  const _UsersTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchViewController>(
      builder: (context, controller, _) {
        if (!controller.hasQuery) {
          return const _EmptyPlaceholder(
            message: 'Type to search for users',
          );
        }

        switch (controller.usersState) {
          case ViewState.loading:
            return const Center(child: CircularProgressIndicator());
          case ViewState.error:
            return const _EmptyPlaceholder(
              message: 'Unable to load users. Please try again.',
            );
          case ViewState.empty:
            return const _EmptyPlaceholder(
              message: 'No users found',
            );
          case ViewState.data:
            return _UsersList(users: controller.users, threadType: controller.threadType);
        }
      },
    );
  }
}

class _UsersList extends StatelessWidget {
  const _UsersList({required this.users, required this.threadType});

  final List<SearchUserModel> users;
  final ThreadFeedType threadType;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final user = users[index];
        return ListTile(
          leading: UserProfileImage(url: user.name),
          title: Text(user.name),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            context.platformPushNamed(
              Routes.userProfileView,
              queryParameters: {
                RouteKeys.accountName: user.name,
                RouteKeys.threadType: enumToString(threadType),
              },
            );
          },
        );
      },
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemCount: users.length,
    );
  }
}

class _TagsTab extends StatelessWidget {
  const _TagsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchViewController>(
      builder: (context, controller, _) {
        if (!controller.hasQuery) {
          return const _EmptyPlaceholder(
            message: 'Type to search for hashtags',
          );
        }

        switch (controller.tagsState) {
          case ViewState.loading:
            return const Center(child: CircularProgressIndicator());
          case ViewState.error:
            return const _EmptyPlaceholder(
              message: 'Unable to load hashtags. Please try again.',
            );
          case ViewState.empty:
            return const _EmptyPlaceholder(
              message: 'No hashtags found',
            );
          case ViewState.data:
            return _TagsList(tags: controller.tags, threadType: controller.threadType);
        }
      },
    );
  }
}

class _TagsList extends StatelessWidget {
  const _TagsList({required this.tags, required this.threadType});

  final List<SearchTagModel> tags;
  final ThreadFeedType threadType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final tag = tags[index];
        return ListTile(
          title: Text('#${tag.name}'),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('${tag.totalPosts}'),
          ),
          onTap: () {
            context.platformPushNamed(
              Routes.tagFeedView,
              queryParameters: {
                RouteKeys.tag: tag.name,
                RouteKeys.threadType: enumToString(threadType),
              },
            );
          },
        );
      },
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemCount: tags.length,
    );
  }
}

class _EmptyPlaceholder extends StatelessWidget {
  const _EmptyPlaceholder({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
      ),
    );
  }
}
