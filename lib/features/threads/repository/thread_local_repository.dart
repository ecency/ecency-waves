import 'package:waves/core/services/local_service.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/settings/repository/settings_repository.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';

class ThreadLocalRepository extends SettingsRepository{
  final LocalService _localService;

  ThreadLocalRepository({required super.localService})
      : _localService = localService;

  List<ThreadFeedModel>? readLocalThreads(ThreadFeedType type){
    return  _localService.readThreads(type);
  }

  Future<void> writeLocalThreads(
      List<ThreadFeedModel> threads, ThreadFeedType type) async {
    return await _localService.writeThreads(threads, type);
  }
}
