import 'package:waves/core/dependency_injection/dependency_injection.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/settings/repository/settings_repository.dart';

class SettingsController {
  final SettingsRepository _repository = getIt<SettingsRepository>();

  ThreadFeedType readThreadType() {
    return _repository.readDefaultThread();
  }

  void saveThreadType(ThreadFeedType type) async {
    await _repository.writeDefaultThread(type);
  }
}
