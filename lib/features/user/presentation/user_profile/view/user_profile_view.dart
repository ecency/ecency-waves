import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/widgets/empty_state.dart';
import 'package:waves/core/common/widgets/loading_state.dart';
import 'package:waves/core/common/widgets/server_error.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/explore/presentation/waves/controller/waves_feed_controller.dart';
import 'package:waves/features/user/models/user_model.dart';
import 'package:waves/features/user/presentation/user_profile/controller/user_profile_controller.dart';
import 'package:waves/features/user/presentation/user_profile/widgets/user_profile_widget.dart';
import 'package:waves/features/user/view/user_controller.dart';

class UserProfileView extends StatelessWidget {
  const UserProfileView({
    super.key,
    required this.accountName,
    required this.threadType,
  });

  final String accountName;
  final ThreadFeedType threadType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MultiProvider(
      key: ValueKey(accountName),
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserProfileController(accountName: accountName),
        ),
        ChangeNotifierProxyProvider<UserController, WavesFeedController>(
          create: (context) => WavesFeedController.account(
            username: accountName,
            threadType: threadType,
            observer: context.read<UserController>().userName,
          ),
          update: (context, userController, previous) {
            if (previous == null) {
              return WavesFeedController.account(
                username: accountName,
                threadType: threadType,
                observer: userController.userName,
              );
            }
            previous.updateObserver(userController.userName);
            return previous;
          },
        ),
      ],
      builder: (context, child) {
        final controller = context.read<UserProfileController>();
        return Scaffold(
            appBar: AppBar(
              leading: BackButton(
                onPressed: () {
                  context.pop();
                },
              ),
            ),
            backgroundColor: theme.scaffoldBackgroundColor,
            body: SafeArea(
              child: Selector<UserProfileController, ViewState>(
                selector: (_, provider) => provider.viewState,
                builder: (context, value, child) {
                  if (value == ViewState.data) {
                    return _dataState(theme);
                  } else if (value == ViewState.empty) {
                    return Emptystate(
                        icon: Icons.hourglass_empty, text: LocaleText.noDataFound);
                  } else if (value == ViewState.error) {
                    return ErrorState(
                        showRetryButton: true,
                        onTapRetryButton: controller.refresh);
                  } else {
                    return const LoadingState();
                  }
                },
              ),
            ));
      },
    );
  }

  Widget _dataState(ThemeData theme) {
    return Selector<UserProfileController, UserModel>(
      selector: (_, provider) => provider.data!,
      builder: (context, data, chidld) {
        return UserProfileViewWidget(
          accountName: accountName,
          data: data,
        );
      },
    );
  }
}
