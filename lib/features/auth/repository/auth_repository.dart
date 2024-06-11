import 'package:waves/core/models/action_response.dart';
import 'package:waves/core/models/auth_decryption_token_response.dart';
import 'package:waves/core/models/auth_redirection_response.dart';
import 'package:waves/core/services/data_service/api_service.dart';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository({required ApiService apiService}) : _apiService = apiService;

  Future<ActionSingleDataResponse<AuthRedirectionResponse>> getRedirectUri(
    String accountName,
  ) async {
    return await _apiService.getRedirectUri(accountName);
  }

  Future<ActionSingleDataResponse<AuthDecryptionResponse>> getDecryptedHASToken(
      String accountName, String encryptedData, String authKey) async {
    return await _apiService.getDecryptedHASToken(
        accountName, encryptedData, authKey);
  }

  Future<ActionSingleDataResponse<bool>> validatePostingKey(
      String accountName, String postingKey) async {
    return await _apiService.validatePostingKey(accountName, postingKey);
  }
}
