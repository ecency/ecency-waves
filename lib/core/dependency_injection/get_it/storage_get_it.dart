

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:waves/core/dependency_injection/dependency_injection.dart';
import 'package:waves/core/dependency_injection/get_it_feature_interface.dart';
import 'package:get_storage/get_storage.dart';

class StorageGetIt extends GetItFeature {

  @override
  void featureInit() {
    getIt.registerLazySingleton<GetStorage>(() => GetStorage());
    getIt.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
  }
}
