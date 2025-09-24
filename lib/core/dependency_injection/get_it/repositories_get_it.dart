import 'package:waves/core/dependency_injection/dependency_injection.dart';
import 'package:waves/core/dependency_injection/get_it_feature_interface.dart';
import 'package:waves/core/services/data_service/api_service.dart';
import 'package:waves/features/auth/repository/auth_repository.dart';
import 'package:waves/features/settings/repository/settings_repository.dart';
import 'package:waves/features/threads/repository/thread_local_repository.dart';
import 'package:waves/features/threads/repository/thread_repository.dart';
import 'package:waves/features/user/repository/user_local_repository.dart';
import 'package:waves/features/user/repository/user_repository.dart';
import 'package:waves/features/explore/repository/explore_repository.dart';
import 'package:waves/features/search/repository/search_repository.dart';
import 'package:waves/features/notifications/repository/notifications_repository.dart';
import 'package:waves/features/translation/repository/translation_repository.dart';

class RepositoriesGetIt extends GetItFeature {
  @override
  void featureInit() {
    getIt.registerFactory<ThreadRepository>(
        () => ThreadRepository(apiService: getIt.call()));
    getIt.registerFactory<AuthRepository>(
        () => AuthRepository(apiService: getIt.call()));
    getIt.registerFactory<UserLocalRepository>(
        () => UserLocalRepository(localService: getIt.call()));
    getIt.registerFactory<ThreadLocalRepository>(
        () => ThreadLocalRepository(localService: getIt.call()));
    getIt.registerFactory<UserRepository>(
        () => UserRepository(apiService: getIt.call()));
    getIt.registerFactory<SettingsRepository>(() =>
        SettingsRepository(localService: getIt.call(), apiService: getIt.call()));
    getIt.registerLazySingleton<ExploreRepository>(
        () => ExploreRepository(apiService: getIt<ApiService>()));
    getIt.registerLazySingleton<SearchRepository>(
        () => SearchRepository(apiService: getIt<ApiService>()));
    getIt.registerLazySingleton<NotificationsRepository>(
        () => NotificationsRepository(apiService: getIt<ApiService>()));
    getIt.registerLazySingleton<TranslationRepository>(
        () => TranslationRepository());
  }
}
