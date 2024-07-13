import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/widgets/empty_state.dart';
import 'package:waves/core/common/widgets/loading_state.dart';
import 'package:waves/core/common/widgets/server_error.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/user/models/user_model.dart';
import 'package:waves/features/user/presentation/user_profile/controller/user_profile_controller.dart';
import 'package:waves/features/user/presentation/user_profile/widgets/user_profile_widget.dart';

class UserProfileView extends StatelessWidget {
  const UserProfileView({
    super.key,
    required this.accountName,
  });

  final String accountName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MultiProvider(
      key: ValueKey(accountName),
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserProfileController(accountName: accountName),
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
            backgroundColor: theme.colorScheme.tertiaryContainer,
            body: SafeArea(
              child: Selector<UserProfileController, ViewState>(
                selector: (_, provider) => provider.viewState,
                builder: (context, value, child) {
                  if (value == ViewState.data) {
                    return _dataState(theme);
                  } else if (value == ViewState.empty) {
                    return const Emptystate(
                        icon: Icons.hourglass_empty, text: 'No Data found');
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
