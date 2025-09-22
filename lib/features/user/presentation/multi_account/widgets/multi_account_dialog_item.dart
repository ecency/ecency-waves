import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/extensions/ui.dart';
import 'package:waves/core/common/widgets/custom_list_tile.dart';
import 'package:waves/core/common/widgets/images/user_profile_image.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/utilities/enum.dart';
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
    final showRemoveButton = currentUserName != item.accountName;
    return CustomListTile(
      onTap: () => _onTap(controller, context),
      leading: UserProfileImage(radius: 17, url: userName),
      titleText: userName,
      trailing: _TrailingIcons(
        authType: item.authType,
        showRemoveButton: showRemoveButton,
        onRemove: () => controller.removeAccount(userName),
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

class _TrailingIcons extends StatelessWidget {
  const _TrailingIcons({
    required this.authType,
    required this.showRemoveButton,
    required this.onRemove,
  });

  final AuthType authType;
  final bool showRemoveButton;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    final loginIcon = _buildLoginIcon();

    if (loginIcon != null) {
      children.add(loginIcon);
    }

    if (showRemoveButton) {
      if (children.isNotEmpty) {
        children.add(const SizedBox(width: 8));
      }
      children.add(IconButton(
        onPressed: onRemove,
        icon: const Icon(
          Icons.close,
          size: 20,
        ),
      ));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  Widget? _buildLoginIcon() {
    final asset = _authAssetForType(authType);
    if (asset != null) {
      return SizedBox(
        height: 24,
        width: 24,
        child: Image.asset(
          asset,
          fit: BoxFit.contain,
        ),
      );
    }

    return const Icon(
      Icons.key,
      size: 20,
    );
  }

  String? _authAssetForType(AuthType type) {
    switch (type) {
      case AuthType.postingKey:
        return 'assets/images/auth/hive-signer-logo.png';
      case AuthType.ecency:
        return 'assets/images/auth/ecency-logo.png';
      case AuthType.hiveKeyChain:
        return 'assets/images/auth/hive-keychain-logo.png';
      case AuthType.hiveAuth:
        return 'assets/images/auth/hiveauth_icon.png';
      case AuthType.hiveSign:
        return 'assets/images/auth/hive-signer-logo.png';
    }
  }
}
