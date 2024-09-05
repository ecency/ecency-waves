import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:waves/core/locales/app_locales.dart';
import 'package:waves/core/providers/global_providers.dart';
import 'package:waves/core/routes/app_router.dart';
import 'package:waves/core/services/user_local_service.dart';
import 'package:waves/core/utilities/theme/theme_mode.dart';
import 'core/dependency_injection/dependency_injection.dart' as get_it;

void main() async {
  await get_it.init();
  await GetStorage.init();
  await EasyLocalization.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  if (packageInfo.version == "1.0.0" && packageInfo.buildNumber == "9") {
    var isCleanUpDone = GetStorage().read('did_we_clean_up') as String? ?? 'no';
    if (isCleanUpDone == "no") {
      await UserLocalService(secureStorage: const FlutterSecureStorage(), getStorage: GetStorage()).cleanup();
      await GetStorage().write('did_we_clean_up', 'yes');
    }
  }

  runApp(EasyLocalization(
      path: 'assets/translations',
      supportedLocales: AppLocales.supportedLocales,
      fallbackLocale: AppLocales.fallbackLocale,
      child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: GlobalProviders.providers,
      child: Consumer<ThemeController>(
        builder: (context, themeController, child) {
          return MaterialApp.router(
            routerConfig: AppRouter.router,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            title: 'Waves',
            theme: themeController.getLightTheme(),
            darkTheme: themeController.getDarkTheme(),
            themeMode: themeController.themeMode,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
