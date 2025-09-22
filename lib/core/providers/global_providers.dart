import 'package:provider/single_child_widget.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/dependency_injection/dependency_injection.dart';
import 'package:waves/core/utilities/theme/theme_mode.dart';
import 'package:waves/features/notifications/presentation/controller/notifications_controller.dart';
import 'package:waves/features/notifications/repository/notifications_repository.dart';
import 'package:waves/features/threads/presentation/thread_feed/controller/poll_controller.dart';
import 'package:waves/features/threads/presentation/thread_feed/controller/thread_feed_controller.dart';
import 'package:waves/features/user/presentation/user_profile/controller/user_profile_controller.dart';
import 'package:waves/features/user/view/user_controller.dart';

class GlobalProviders {
  static List<SingleChildWidget> providers = [
    ChangeNotifierProvider(
      create: (context) => ThemeController(),
    ),
    ChangeNotifierProvider(
      lazy: false,
      create: (context) => UserController(),
    ),
    ChangeNotifierProxyProvider<UserController, UserProfileController>(
      create: (context) => UserProfileController(accountName: null),
      update: (context, userController, previousProfileController) {
         if (previousProfileController == null) {
          return UserProfileController(accountName: userController.userName);
        } else {
          previousProfileController.updateAccountName(userController.userName);
          return previousProfileController;
        }
      }
    ),
    ChangeNotifierProxyProvider<UserController, ThreadFeedController>(
      create: (context) => ThreadFeedController(observer: null),
      update: (context, userController, previousThreadFeedController) {
        if (previousThreadFeedController == null) {
          return ThreadFeedController(observer: userController.userName);
        } else {
          previousThreadFeedController.updateObserver(userController.userName);
          return previousThreadFeedController;
        }
      },
    ),
    ChangeNotifierProxyProvider<UserController, PollController>(
      create: (context) => PollController(userData: null),
      update: (context, userController, prevPollController) {
        if (prevPollController == null) {
          return PollController(userData: userController.userData);
        } else {
          prevPollController.updateUserData(userController.userData);
          return prevPollController;
        }
      },
    ),
    ChangeNotifierProxyProvider<UserController, NotificationsController>(
      create: (context) => NotificationsController(
        repository: getIt<NotificationsRepository>(),
        user: null,
      ),
      update: (context, userController, previousController) {
        if (previousController == null) {
          return NotificationsController(
            repository: getIt<NotificationsRepository>(),
            user: userController.userData,
          );
        } else {
          previousController.updateUser(userController.userData);
          return previousController;
        }
      },
    ),
  ];
}
