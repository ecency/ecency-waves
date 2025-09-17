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
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await get_it.init();
  await GetStorage.init();
  await EasyLocalization.ensureInitialized();
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  if (packageInfo.version == "1.0.0" && packageInfo.buildNumber == "9") {
    var isCleanUpDone = GetStorage().read('did_we_clean_up') as String? ?? 'no';
    if (isCleanUpDone == "no") {
      await UserLocalService(secureStorage: const FlutterSecureStorage(), getStorage: GetStorage()).cleanup();
      await GetStorage().write('did_we_clean_up', 'yes');
    }
  }

  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://5fa2d9d54d3fda955c613c6b3182c60c@o4507985141956608.ingest.de.sentry.io/4510033051779152';
      // Adds request headers and IP for users, for more info visit:
      // https://docs.sentry.io/platforms/dart/guides/flutter/data-management/data-collected/
      options.sendDefaultPii = true;
      options.enableLogs = true;
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for tracing.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
      // The sampling rate for profiling is relative to tracesSampleRate
      // Setting to 1.0 will profile 100% of sampled transactions:
      options.profilesSampleRate = 1.0;
      // Configure Session Replay
      options.replay.sessionSampleRate = 0.1;
      options.replay.onErrorSampleRate = 1.0;
    },
    appRunner: () => runApp(SentryWidget(child: EasyLocalization(
      path: 'assets/translations',
      supportedLocales: AppLocales.supportedLocales,
      fallbackLocale: AppLocales.fallbackLocale,
      child: const MyApp()))),
  );
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
            routerConfig: AppRouter.router(context),
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
