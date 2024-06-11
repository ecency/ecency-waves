import 'dart:async';
import 'package:waves/core/dependency_injection/dependency_injection.dart';
import 'package:waves/core/dependency_injection/get_it_feature_interface.dart';
import 'package:waves/features/auth/models/user_auth_model.dart';

class ControllersGetIt extends GetItFeature {
  @override
  void featureInit() {
    getIt.registerSingleton(StreamController<UserAuthModel?>());
  }
}
