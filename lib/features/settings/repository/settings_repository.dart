import 'package:waves/core/services/local_service.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/core/utilities/generics/classes/thread.dart';

class SettingsRepository {
  final LocalService _localService;

  SettingsRepository({required LocalService localService})
      : _localService = localService;

  ThreadFeedType readDefaultThread() {
    return _localService.readDefaultThread() ?? Thread.defaultThreadType;
  }

  Future<void> writeDefaultThread(ThreadFeedType type) async {
    return await _localService.writeDefaultThread(type);
  }
}
