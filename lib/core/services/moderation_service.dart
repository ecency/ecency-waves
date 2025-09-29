import 'dart:async';

import 'package:waves/core/models/action_response.dart';
import 'package:waves/core/services/data_service/api_service.dart';

/// Keeps track of observer-specific moderation data such as muted accounts and
/// provides cached lookups so multiple controllers can reuse the same list
/// without hammering the API on every refresh.
class ModerationService {
  ModerationService({required ApiService apiService}) : _apiService = apiService;

  final ApiService _apiService;

  Set<String> _mutedAccounts = const <String>{};
  String? _observer;
  bool _hasLoaded = false;
  Future<Set<String>>? _ongoingRequest;

  /// Returns the cached list of muted accounts for the provided [observer]. The
  /// first call for a given observer triggers an RPC fetch; subsequent calls use
  /// the cached set unless [forceRefresh] is `true`.
  Future<Set<String>> loadMutedAccounts(
    String? observer, {
    bool forceRefresh = false,
  }) async {
    final String? normalizedObserver = observer?.trim().toLowerCase();

    if (normalizedObserver == null || normalizedObserver.isEmpty) {
      _observer = null;
      _mutedAccounts = const <String>{};
      _hasLoaded = false;
      _ongoingRequest = null;
      return _mutedAccounts;
    }

    if (!forceRefresh &&
        _hasLoaded &&
        _observer == normalizedObserver &&
        _ongoingRequest == null) {
      return _mutedAccounts;
    }

    if (_ongoingRequest != null) {
      await _ongoingRequest;
      if (!forceRefresh &&
          _hasLoaded &&
          _observer == normalizedObserver &&
          _ongoingRequest == null) {
        return _mutedAccounts;
      }
    }

    _observer = normalizedObserver;
    final Future<Set<String>> future =
        _fetchMutedAccounts(normalizedObserver, forceRefresh);
    _ongoingRequest = future;
    final Set<String> result = await future;
    _ongoingRequest = null;
    return result;
  }

  Future<Set<String>> _fetchMutedAccounts(String observer, bool forceRefresh) async {
    try {
      final ActionListDataResponse<String> response =
          await _apiService.getMutedAccounts(observer);

      if (response.isSuccess && response.data != null) {
        _mutedAccounts = response.data!
            .map((String account) => account.toLowerCase())
            .toSet();
      } else if (!response.isSuccess && forceRefresh) {
        // If a forced refresh fails, clear the cache so subsequent attempts can
        // retry with a clean slate.
        _mutedAccounts = const <String>{};
      }
    } finally {
      _hasLoaded = true;
    }

    return _mutedAccounts;
  }

  /// Drops the cached moderation data so the next call reloads it from the
  /// network.
  void invalidateCache() {
    _mutedAccounts = const <String>{};
    _observer = null;
    _hasLoaded = false;
    _ongoingRequest = null;
  }

  /// Returns the currently cached muted accounts without triggering any RPC
  /// calls.
  Set<String> get cachedMutedAccounts => _mutedAccounts;
}
