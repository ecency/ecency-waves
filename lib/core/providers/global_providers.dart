import 'package:provider/single_child_widget.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/utilities/theme/theme_mode.dart';
import 'package:waves/features/threads/presentation/thread_feed/controller/thread_feed_controller.dart';
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
    ChangeNotifierProvider(
      create: (context) => ThreadFeedController(),
    )
  ];
}
