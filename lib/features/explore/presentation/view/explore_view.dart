import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/widgets/locale_aware_consumer.dart';
import 'package:waves/core/common/extensions/platform_navigation.dart';
import 'package:waves/core/common/widgets/images/user_profile_image.dart';
import 'package:waves/core/common/widgets/post_count_badge.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/routes/route_keys.dart';
import 'package:waves/core/routes/routes.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/explore/models/trending_author_model.dart';
import 'package:waves/features/explore/models/trending_tag_model.dart';
import 'package:waves/features/explore/presentation/controller/explore_controller.dart';
import 'package:waves/features/explore/presentation/widgets/thread_type_dropdown.dart';

class ExploreView extends StatefulWidget {
  const ExploreView({super.key});

  @override
  State<ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<ExploreView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final ExploreController _exploreController;

  @override
  void initState() {
    super.initState();
    _exploreController = ExploreController();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChange);
    _tabController.dispose();
    _exploreController.dispose();
    super.dispose();
  }

  void _onTabChange() {
    if (!_tabController.indexIsChanging && _tabController.index == 1) {
      _exploreController.loadAuthorsIfNeeded();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _exploreController,
      child: LocaleAwareConsumer<ExploreController>(
        builder: (context, controller, _) {
          return Scaffold(
            appBar: AppBar(
              title: ThreadTypeDropdown(
                value: controller.threadType,
                onChanged: (type) {
                  controller.onChangeThreadType(type);
                  if (_tabController.index == 1) {
                    controller.loadAuthorsIfNeeded();
                  }
                },
              ),
              bottom: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: LocaleText.tags),
                  Tab(text: LocaleText.users),
                ],
              ),
            ),
            body: SafeArea(
              top: false,
              bottom: false,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _TagsTab(),
                  _UsersTab(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TagsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = context.read<ExploreController>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LocaleAwareSelector<ExploreController, ViewState>(
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
                  trailing: PostCountBadge(count: tag.posts),
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
          } else if (state == ViewState.empty) {
            return Center(child: Text(LocaleText.noHashtagsFound));
          } else {
            return Center(child: Text(LocaleText.error));
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LocaleAwareSelector<ExploreController, ViewState>(
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
                  trailing: PostCountBadge(count: a.posts),
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
          } else if (state == ViewState.empty) {
            return Center(child: Text(LocaleText.noUsersFound));
          } else {
            return Center(child: Text(LocaleText.error));
          }
        },
      ),
    );
  }
}

