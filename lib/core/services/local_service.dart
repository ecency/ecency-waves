import 'package:get_storage/get_storage.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/threads/models/thread_feeds/reported/thread_info_model.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';

class LocalService {
  final GetStorage _getStorage;
  final _defaultThreadKey = 'defaultThread';
  final _reportedThreadKey = 'reportedThreads';

  LocalService({required GetStorage getStorage}) : _getStorage = getStorage;

  Future<void> writeThreads(
      List<ThreadFeedModel> threads, ThreadFeedType type) async {
    await _getStorage.remove(enumToString(type));
    await _getStorage.write(
        enumToString(type), ThreadFeedModel.toRawJson(threads));
  }

  List<ThreadFeedModel>? readThreads(ThreadFeedType type) {
    String? data = _getStorage.read(enumToString(type));
    if (data == null) return null;
    return ThreadFeedModel.fromRawJson(data);
  }

  Future<void> writeDefaultThread(ThreadFeedType type) async {
    await _getStorage.write(_defaultThreadKey, enumToString(type));
  }

  ThreadFeedType? readDefaultThread() {
    String? data = _getStorage.read(_defaultThreadKey);
    if (data == null) return null;
    return enumFromString(data, ThreadFeedType.values);
  }

  List<ThreadInfoModel> readReportedThreads() {
    String? data = _getStorage.read(_reportedThreadKey);
    if (data == null) return [];
    return ThreadInfoModel.fromRawJsonList(data);
  }

  Future<void> writeReportedThreads(ThreadInfoModel item) async {
    List<ThreadInfoModel> threads = readReportedThreads();
    threads.add(item);
    await _getStorage.write(
        _reportedThreadKey, ThreadInfoModel.toRawJsonList(threads));
  }
}
