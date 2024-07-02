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
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      backgroundColor: theme.colorScheme.tertiaryContainer,
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium,
      ),
      duration: const Duration(seconds: 3),
    ));
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
    Navigator.of(this).pop();
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
