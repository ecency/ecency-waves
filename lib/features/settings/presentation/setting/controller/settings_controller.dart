import 'package:waves/core/dependency_injection/dependency_injection.dart';
import 'package:waves/core/models/action_response.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/settings/repository/settings_repository.dart';
import 'package:waves/features/threads/models/thread_feeds/reported/report_reponse.dart';
import 'package:waves/features/user/repository/user_local_repository.dart';

class SettingsController {
  final SettingsRepository _repository = getIt<SettingsRepository>();
  final UserLocalRepository _userLocalRepository = getIt<UserLocalRepository>();

  ThreadFeedType readThreadType() {
    return _repository.readDefaultThread();
  }

  void saveThreadType(ThreadFeedType type) async {
    await _repository.writeDefaultThread(type);
  }

  Future<ActionSingleDataResponse<ReportResponse>> deleteAccount(
      String accountName) async {
    ActionSingleDataResponse<ReportResponse> response =
        await _repository.deleteAccount(accountName);
    if (response.isSuccess) {
      await _userLocalRepository.writeDeleteAccount(accountName);
    }
    return response;
  }
}
