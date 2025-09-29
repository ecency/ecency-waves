import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/widgets/locale_aware_consumer.dart';
import 'package:waves/core/common/extensions/platform_navigation.dart';
import 'package:waves/core/common/widgets/empty_state.dart';
import 'package:waves/core/common/widgets/images/user_profile_image.dart';
import 'package:waves/core/common/widgets/loading_state.dart';
import 'package:waves/core/common/widgets/server_error.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/routes/route_keys.dart';
import 'package:waves/core/routes/routes.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/user/presentation/user_profile/controller/follow_list_controller.dart';

class FollowListView extends StatelessWidget {
  const FollowListView({
    super.key,
    required this.accountName,
    required this.followType,
  });

  final String accountName;
  final FollowType followType;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FollowListController(
        accountName: accountName,
        followType: followType,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            followType == FollowType.followers ? 'Followers' : 'Following',
          ),
        ),
        body: const _FollowListBody(),
      ),
    );
  }
}

class _FollowListBody extends StatelessWidget {
  const _FollowListBody();

  @override
  Widget build(BuildContext context) {
    return LocaleAwareConsumer<FollowListController>(
      builder: (context, controller, _) {
        switch (controller.viewState) {
          case ViewState.loading:
            return const LoadingState();
          case ViewState.error:
            return ErrorState(
              showRetryButton: true,
              onTapRetryButton: controller.refresh,
            );
          case ViewState.empty:
            return Emptystate(text: LocaleText.noDataFound);
          case ViewState.data:
            return RefreshIndicator(
              onRefresh: controller.refresh,
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification.metrics.axis == Axis.vertical &&
                      notification.metrics.pixels >=
                          notification.metrics.maxScrollExtent - 120 &&
                      controller.hasMore &&
                      !controller.isLoadingMore) {
                    controller.loadMore();
                  }
                  return false;
                },
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.items.length +
                      (controller.isLoadingMore ? 1 : 0),
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    if (index >= controller.items.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final item = controller.items[index];
                    return ListTile(
                      leading: UserProfileImage(url: item.name),
                      title: Text(item.name),
                      onTap: () {
                        context.platformPushNamed(
                          Routes.userProfileView,
                          queryParameters: {
                            RouteKeys.accountName: item.name,
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            );
        }
      },
    );
  }
}
