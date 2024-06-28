import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/extensions/ui.dart';
import 'package:waves/core/common/widgets/custom_list_tile.dart';
import 'package:waves/core/common/widgets/images/user_profile_image.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/features/auth/models/user_auth_model.dart';
import 'package:waves/features/user/presentation/multi_account/controller/multi_account_switch_controller.dart';

class MultiAccountDialogItem extends StatelessWidget {
  const MultiAccountDialogItem({
    super.key,
    required this.item,
    required this.currentUserName,
  });

  final UserAuthModel item;
  final String currentUserName;

  @override
  Widget build(BuildContext context) {
    final controller = context.read<MultiAccountController>();
    final userName = item.accountName;
    return CustomListTile(
      onTap: () => _onTap(controller, context),
      leading: UserProfileImage(radius: 17, url: userName),
      titleText: userName,
      trailing: Visibility(
        visible: currentUserName != item.accountName,
        child: IconButton(
            onPressed: () {
              controller.removeAccount(userName);
            },
            icon: const Icon(
              Icons.close,
              size: 20,
            )),
      ),
    );
  }

  void _onTap(MultiAccountController controller, BuildContext context) {
    if (currentUserName != item.accountName) {
      controller.onSelect(item);
      context.showSnackBar(LocaleText.successfullLoginMessage(item.accountName));
    }

    Navigator.pop(context);
  }
}
