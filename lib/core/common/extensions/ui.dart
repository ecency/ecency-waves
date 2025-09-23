import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/common/widgets/dialog/log_in_dialog.dart';
import 'package:waves/features/user/view/user_controller.dart';

extension UI on BuildContext {
  PageRouteBuilder fadePageRoute(Widget screen) {
    return PageRouteBuilder(
      fullscreenDialog: false,
      opaque: false,
      barrierColor: Colors.black.withOpacity(0.9),
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 200),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (BuildContext context, _, __) {
        return screen;
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  void showSnackBar(String message) {
    final theme = Theme.of(this);
    final messenger = ScaffoldMessenger.of(this);
    final colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final Color backgroundColor =
        isDark ? colorScheme.surface : colorScheme.primary;
    final Color foregroundColor =
        isDark ? colorScheme.onSurface : colorScheme.onPrimary;

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        dismissDirection: DismissDirection.horizontal,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 5),
        content: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: foregroundColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                textAlign: TextAlign.start,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PopScope _loader(BuildContext context, bool canPop) {
    return PopScope(
      canPop: canPop,
      child: MediaQuery.removeViewInsets(
        removeLeft: true,
        removeTop: true,
        removeRight: true,
        removeBottom: true,
        context: context,
        child: Container(
          color: Colors.transparent,
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: BoxConstraints.tight(
              const Size.fromRadius(60),
            ),
            child: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
                strokeWidth: 4,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showLoader({bool canPop = false}) {
    showDialog<dynamic>(
      context: this,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (context) => _loader(context, canPop),
    );
  }

  void hideLoader() {
    Navigator.of(this, rootNavigator: true).pop();
  }

  void authenticatedAction({required VoidCallback action}) {
    if (read<UserController>().isUserLoggedIn) {
      action();
    } else {
      showLoginDialog();
    }
  }

  void showLoginDialog() {
    showDialog(
      context: this,
      builder: (_) {
        return const LogInDialog();
      },
    );
  }
}
