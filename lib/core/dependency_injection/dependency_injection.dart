import 'package:waves/core/dependency_injection/get_it/controllers_get_it.dart';
import 'package:waves/core/dependency_injection/get_it/providers_get_it.dart';
import 'package:waves/core/dependency_injection/get_it/repositories_get_it.dart';
import 'package:waves/core/dependency_injection/get_it/services_get_it.dart';
import 'package:waves/core/dependency_injection/get_it/storage_get_it.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  StorageGetIt().init();
  ServicesGetIt().init();
  RepositoriesGetIt().init();
  ControllersGetIt().init();
  ProvidersGetIt().init();
}
