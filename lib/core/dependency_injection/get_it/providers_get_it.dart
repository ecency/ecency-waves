import 'package:waves/core/dependency_injection/dependency_injection.dart';
import 'package:waves/core/dependency_injection/get_it_feature_interface.dart';
import 'package:waves/core/socket/provider/socket_provider.dart';

class ProvidersGetIt extends GetItFeature {
  @override
  void featureInit() {
    getIt.registerLazySingleton(SocketProvider.new);
  }
}
