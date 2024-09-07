import 'package:waves/core/services/local_service.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/core/utilities/generics/classes/thread.dart';
import 'package:waves/features/threads/models/thread_feeds/reported/thread_info_model.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';

class ThreadLocalRepository {
  final LocalService _localService;

  ThreadLocalRepository({required LocalService localService})
      : _localService = localService;

  List<ThreadFeedModel>? readLocalThreads(ThreadFeedType type) {
    return _localService.readThreads(type);
  }

  Future<void> writeLocalThreads(
      List<ThreadFeedModel> threads, ThreadFeedType type) async {
    return await _localService.writeThreads(threads, type);
  }

  List<ThreadInfoModel> readReportedThreads() {
    return _localService.readReportedThreads();
  }

  Future<void> writeReportedThreads(ThreadInfoModel item) async {
    return await _localService.writeReportedThreads(item);
  }

  ThreadFeedType readDefaultThread() {
    return _localService.readDefaultThread() ?? Thread.defaultThreadType;
  }

  Future<void> writeDefaultThread(ThreadFeedType type) async {
    return await _localService.writeDefaultThread(type);
  }
}
