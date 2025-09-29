import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/widgets/locale_aware_consumer.dart';
import 'package:waves/core/common/extensions/platform_navigation.dart';
import 'package:waves/core/common/widgets/loading_state.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/routes/routes.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/auth/models/user_auth_model.dart';
import 'package:waves/features/user/presentation/multi_account/controller/multi_account_switch_controller.dart';
import 'package:waves/features/user/presentation/multi_account/widgets/multi_account_dialog_item.dart';
import 'package:waves/features/user/view/user_controller.dart';

class MultiAccountDialog extends StatelessWidget {
  const MultiAccountDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String currentUserName =
        context.read<UserController>().userData!.accountName;
    return ChangeNotifierProvider(
      create: (context) => MultiAccountController(
          currentUserName:
              context.read<UserController>().userData!.accountName),
      builder: (context, child) {
        final controller = context.read<MultiAccountController>();
        return AlertDialog(
          buttonPadding: const EdgeInsets.only(right: 20, bottom: 20),
          contentPadding: EdgeInsets.zero,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogBar(theme, context),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                ),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.8,
                  width: MediaQuery.of(context).size.width * 0.8,
                  constraints: const BoxConstraints(
                      minWidth: 200,
                      maxWidth: 380,
                      minHeight: 250,
                      maxHeight: 300),
                  child: LocaleAwareSelector<MultiAccountController, ViewState>(
                      selector: (_, myType) => myType.viewState,
                      builder: (context, state, child) {
                        if (state == ViewState.data) {
                          return _listView(controller, currentUserName);
                        } else {
                          return const LoadingState();
                        }
                      }),
                ),
              )
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  context.popAndPlatformPushNamed(Routes.authView);
                },
                style:
                    TextButton.styleFrom(backgroundColor: theme.primaryColor),
                child: Text(
                  LocaleText.addAccount,
                  style: TextStyle(color: theme.colorScheme.onPrimary),
                ),
              ),
            )
          ],
        );
      },
    );
  }

  Widget _listView(MultiAccountController controller, String currentUserName) {
    return LocaleAwareSelector<MultiAccountController, int>(
      selector: (_, myType) => myType.userAccounts.length,
      builder: (context, items, child) {
        return ListView.builder(
          shrinkWrap: true,
          itemCount: controller.userAccounts.length,
          itemBuilder: (context, index) {
            UserAuthModel item = controller.userAccounts[index];
            return MultiAccountDialogItem(
                item: item, currentUserName: currentUserName);
          },
        );
      },
    );
  }

  Container _dialogBar(ThemeData theme, BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      decoration: BoxDecoration(
          color: theme.primaryColor,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12.0), topRight: Radius.circular(12.0))),
      child: Padding(
        padding: const EdgeInsets.only(left: 15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              LocaleText.switchAccount,
              style: TextStyle(color: theme.colorScheme.onPrimary),
            ),
            IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.cancel, color: theme.colorScheme.onPrimary),
            )
          ],
        ),
      ),
    );
  }
}
