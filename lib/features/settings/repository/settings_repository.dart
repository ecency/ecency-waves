import 'package:waves/core/models/action_response.dart';
import 'package:waves/core/services/data_service/api_service.dart';
import 'package:waves/core/services/local_service.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/core/utilities/generics/classes/thread.dart';
import 'package:waves/features/threads/models/thread_feeds/reported/report_reponse.dart';

class SettingsRepository {
  final LocalService _localService;
  final ApiService _apiService;

  SettingsRepository(
      {required LocalService localService, required ApiService apiService})
      : _localService = localService,
        _apiService = apiService;

  ThreadFeedType readDefaultThread() {
    return _localService.readDefaultThread() ?? Thread.defaultThreadType;
  }

  Future<void> writeDefaultThread(ThreadFeedType type) async {
    return await _localService.writeDefaultThread(type);
  }

  Future<ActionSingleDataResponse<ReportResponse>> deleteAccount(
      String accountName) async {
    return await _apiService.deleteAccount(accountName);
  }
}
