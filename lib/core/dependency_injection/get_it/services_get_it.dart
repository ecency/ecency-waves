import 'package:waves/core/dependency_injection/dependency_injection.dart';
import 'package:waves/core/dependency_injection/get_it_feature_interface.dart';
import 'package:waves/core/services/data_service/api_service.dart';
import 'package:waves/core/services/local_service.dart';
import 'package:waves/core/services/moderation_service.dart';
import 'package:waves/core/services/user_local_service.dart';

class ServicesGetIt extends GetItFeature {
  @override
  void featureInit() {
    getIt.registerLazySingleton<ApiService>(() => ApiService());
    getIt.registerLazySingleton<ModerationService>(
        () => ModerationService(apiService: getIt.call()));
    getIt.registerLazySingleton<UserLocalService>(
        () => UserLocalService(secureStorage: getIt.call(), getStorage: getIt.call()));
    getIt.registerLazySingleton<LocalService>(
        () => LocalService(getStorage: getIt.call()));
  }
}
