import 'package:waves/core/dependency_injection/dependency_injection.dart';
import 'package:waves/core/dependency_injection/get_it_feature_interface.dart';
import 'package:waves/features/auth/repository/auth_repository.dart';
import 'package:waves/features/threads/repository/thread_repository.dart';
import 'package:waves/features/user/repository/user_local_repository.dart';

class RepositoriesGetIt extends GetItFeature {
  @override
  void featureInit() {
    getIt.registerFactory<ThreadRepository>(
        () => ThreadRepository(apiService: getIt.call()));
    getIt.registerFactory<AuthRepository>(
        () => AuthRepository(apiService: getIt.call()));
    getIt.registerFactory<UserLocalRepository>(
        () => UserLocalRepository(localService: getIt.call()));
  }
}
