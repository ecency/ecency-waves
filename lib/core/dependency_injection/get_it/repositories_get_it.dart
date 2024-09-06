import 'package:waves/core/dependency_injection/dependency_injection.dart';
import 'package:waves/core/dependency_injection/get_it_feature_interface.dart';
import 'package:waves/features/auth/repository/auth_repository.dart';
import 'package:waves/features/settings/repository/settings_repository.dart';
import 'package:waves/features/threads/repository/thread_local_repository.dart';
import 'package:waves/features/threads/repository/thread_repository.dart';
import 'package:waves/features/user/repository/user_local_repository.dart';
import 'package:waves/features/user/repository/user_repository.dart';

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
    getIt.registerFactory<SettingsRepository>(
        () => SettingsRepository(localService: getIt.call(),apiService: getIt.call()));
  }
}
