// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/models/action_response.dart';
import 'package:waves/core/models/auth_decryption_token_response.dart';
import 'package:waves/core/models/auth_redirection_response.dart';
import 'package:waves/core/models/broadcast_model.dart';
import 'package:waves/core/services/data_service/service.dart'
if (dart.library.io) 'package:waves/core/services/data_service/mobile_service.dart'
if (dart.library.html) 'package:waves/core/services/data_service/web_service.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/threads/models/comment/image_upload_error_response.dart';
import 'package:waves/features/threads/models/comment/image_upload_response.dart';
import 'package:waves/features/threads/models/post_detail/comment_model.dart';
import 'package:waves/features/threads/models/thread_feeds/reported/report_reponse.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';
import 'package:waves/features/notifications/models/notification_model.dart';
import 'package:waves/features/user/models/follow_count_model.dart';
import 'package:waves/features/user/models/follow_user_item_model.dart';
import 'package:waves/features/user/models/user_model.dart';
import 'package:waves/features/explore/models/trending_tag_model.dart';
import 'package:waves/features/explore/models/trending_author_model.dart';
import 'package:waves/features/search/models/search_tag_model.dart';
import 'package:waves/features/search/models/search_user_model.dart';

class ApiService {
  static const List<String> _rpcUrls = [
    'https://api.hive.blog',
    'https://hive-api.arcange.eu',
    'https://api.openhive.network',
    'https://api.deathwing.me',
  ];

  // --- Sticky node handling (prevents cross-node pagination drift) ---
  final Map<String, String> _stickyNode = {};
  String? _getSticky(String key) => _stickyNode[key];
  void _setSticky(String key, String url) => _stickyNode[key] = url;
  void _clearSticky(String key) => _stickyNode.remove(key);

  Map<String, String> get _rpcHeaders => const {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'WavesApp/1.0 (+https://ecency.com)'
  };

  Map<String, String> get _jsonHeaders => const {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  String? currentAccountPostsNode(AccountPostType type, String account) =>
      _getSticky('acct_posts:${enumToString(type)}:$account');

  void invalidateAccountPostsSticky(AccountPostType type, String account) =>
      _clearSticky('acct_posts:${enumToString(type)}:$account');
  /// POST to bridge/condenser with sticky-node fallback.
  /// If [stickyKey] is provided, prefer the sticky node for that key and
  /// update it on success. If a sticky fails, it will be cleared and the
  /// next node will be tried.
  /// Returns the first 200; if none succeed, returns the **last** non-200 response
  /// (so caller can surface a useful error body) or null if all attempts threw.
  Future<http.Response?> _postWithFallback(
      Map<String, dynamic> payload, {
        Duration timeout = const Duration(seconds: 10),
        String? stickyKey,
      }) async {
    final body = jsonEncode(payload);

    // Build prioritized URL list: sticky first (if any), then others (shuffled).
    final urls = List<String>.from(_rpcUrls);
    if (stickyKey != null) {
      final s = _getSticky(stickyKey);
      if (s != null && urls.contains(s)) {
        urls.remove(s);
        urls.insert(0, s);
      }
    }
    if (urls.length > 1) {
      final head = urls.first;
      final tail = urls.sublist(1)..shuffle();
      urls
        ..clear()
        ..add(head)
        ..addAll(tail);
    }

    http.Response? lastNon200;

    for (final url in urls) {
      try {
        final res = await http
            .post(Uri.parse(url), headers: _rpcHeaders, body: body)
            .timeout(timeout);
        if (res.statusCode == 200) {
          if (stickyKey != null) _setSticky(stickyKey, url);
          return res;
        } else {
          lastNon200 = res;
          if (stickyKey != null && _getSticky(stickyKey) == url) {
            _clearSticky(stickyKey);
          }
        }
      } catch (_) {
        if (stickyKey != null && _getSticky(stickyKey) == url) {
          _clearSticky(stickyKey);
        }
      }
    }
    return lastNon200;
  }

  /// Safely decode JSON; returns null if invalid.
  dynamic _tryDecode(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  /// Format a concise message from a JSON-RPC error object or HTTP fallback.
  String _rpcErrorMessage(http.Response? res,
      {String fallback = 'Server Error'}) {
    if (res == null) return '$fallback: no node responded';
    final decoded = _tryDecode(res.body);
    if (decoded is Map && decoded['error'] != null) {
      final err = decoded['error'];
      if (err is Map) {
        final code = err['code'];
        final msg = err['message'];
        if (msg is String && code != null) return 'RPC error ($code): $msg';
        if (msg is String) return 'RPC error: $msg';
      } else if (err is String) {
        return 'RPC error: $err';
      }
    }
    return '$fallback (${res.statusCode})';
  }

  // -------------------------- Account Posts --------------------------

  Future<ActionListDataResponse<ThreadFeedModel>> getAccountPosts(
      String accountName,
      AccountPostType type,
      int limit,
      String? lastAuthor,
      String? lastPermlink,
      ) async {
    try {
      final response = await _getAccountPosts(
          type, accountName, lastAuthor, lastPermlink, limit);

      if (response.statusCode == 200) {
        return ActionListDataResponse<ThreadFeedModel>(
          data: ThreadFeedModel.fromRawJson(response.body),
          status: ResponseStatus.success,
          isSuccess: true,
          errorMessage: "",
        );
      } else {
        return ActionListDataResponse(
          status: ResponseStatus.failed,
          errorMessage: response.body.isNotEmpty
              ? response.body
              : "Server Error (${response.statusCode})",
        );
      }
    } catch (e) {
      return ActionListDataResponse(
        status: ResponseStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  Future<http.Response> _getAccountPosts(
      AccountPostType type,
      String accountName,
      String? lastAuthor,
      String? lastPermlink,
      int limit,
      ) async {
    final params = {
      'sort': enumToString(type),
      'account': accountName,
      'limit': limit,
      if (lastAuthor != null) 'start_author': lastAuthor,
      if (lastPermlink != null) 'start_permlink': lastPermlink,
    };

    // Sticky per feed (sort+account)
    final stickyKey = 'acct_posts:${enumToString(type)}:$accountName';

    Future<http.Response> _do(Map<String, dynamic> payload) async {
      final res = await _postWithFallback(payload,
          stickyKey: stickyKey, timeout: const Duration(seconds: 3));
      if (res == null) return http.Response('RPC error: no node responded', 500);

      try {
        final decoded = _tryDecode(res.body);
        if (decoded is Map && decoded['error'] != null) {
          return http.Response(_rpcErrorMessage(res), 500);
        }

        final result = (decoded is Map) ? decoded['result'] : decoded;
        List<dynamic> posts;

        if (result is List) {
          posts = result;
        } else if (result is Map && result['posts'] is List) {
          posts = List<dynamic>.from(result['posts'] as List);
        } else if (res.statusCode != 200) {
          return http.Response(_rpcErrorMessage(res), 500);
        } else {
          posts = const [];
        }

        return http.Response(jsonEncode(posts), 200);
      } catch (e) {
        return http.Response('Parse error: $e', 500);
      }
    }

    final payload = {
      'jsonrpc': '2.0',
      'method': 'bridge.get_account_posts',
      'params': params,
      'id': 1,
    };

    // First attempt
    final first = await _do(payload);

    // If FIRST PAGE (no start_author) came back empty, retry once on a fresh node.
    if (first.statusCode == 200 && lastAuthor == null) {
      List<dynamic> arr;
      try {
        arr = jsonDecode(first.body) as List<dynamic>;
      } catch (_) {
        arr = const [];
      }
      if (arr.isEmpty) {
        _clearSticky(stickyKey);               // drop the sticky node
        final retry = await _do(payload);      // try again on a different node
        if (retry.statusCode == 200) return retry;
      }
    }

    return first;
  }

  Future<ActionSingleDataResponse<ThreadFeedModel>> getFirstAccountPost(
      String accountName,
      AccountPostType type,
      int limit,
      String? lastAuthor,
      String? lastPermlink,
      ) async {
    try {
      final response = await _getAccountPosts(
          type, accountName, lastAuthor, lastPermlink, limit);

      if (response.statusCode == 200) {
        final list = ThreadFeedModel.fromRawJson(response.body);
        if (list.isEmpty) {
          return ActionSingleDataResponse(
            status: ResponseStatus.failed,
            errorMessage: "No posts found",
          );
        }
        return ActionSingleDataResponse<ThreadFeedModel>(
          data: list.first,
          status: ResponseStatus.success,
          isSuccess: true,
          errorMessage: "",
        );
      } else {
        return ActionSingleDataResponse(
          status: ResponseStatus.failed,
          errorMessage: response.body.isNotEmpty
              ? response.body
              : "Server Error (${response.statusCode})",
        );
      }
    } catch (e) {
      return ActionSingleDataResponse(
        status: ResponseStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  // -------------------------- Discussion / Comments --------------------------

  Future<ActionListDataResponse<ThreadFeedModel>> getComments(
      String accountName,
      String permlink,
      String? observer,
      ) async {
    try {
      List<Map<String, dynamic>> _normalize(List<dynamic> entries) {
        return entries.map<Map<String, dynamic>>((e) {
          final m = Map<String, dynamic>.from(e as Map);
          m['post_id'] ??= m['id']; // ThreadFeedModel requires post_id
          return m;
        }).toList();
      }

      List<dynamic> entries = [];

      // Always fetch the root post first so payout fields are present
      final rootRes = await _postWithFallback({
        'jsonrpc': '2.0',
        'method': 'condenser_api.get_content',
        'params': [accountName, permlink],
        'id': 1,
      });
      if (rootRes != null) {
        final decoded = jsonDecode(rootRes.body);
        final root = (decoded is Map) ? decoded['result'] : null;
        if (root is Map && (root['id'] ?? 0) != 0) {
          entries.add(root);
        }
      }

      // Fetch top-level replies
      final repliesRes = await _postWithFallback({
        'jsonrpc': '2.0',
        'method': 'condenser_api.get_content_replies',
        'params': [accountName, permlink],
        'id': 1,
      });
      if (repliesRes != null) {
        final decoded = jsonDecode(repliesRes.body);
        if (!(decoded is Map && decoded['error'] != null)) {
          final result = (decoded is Map) ? decoded['result'] : decoded;
          if (result is List) {
            entries.addAll(result);
          }
        }
      }

      // If we still only have the root (no replies), try bridge.get_discussion
      if (entries.length <= 1) {
        final discussionRes = await _postWithFallback({
          'jsonrpc': '2.0',
          'method': 'bridge.get_discussion',
          'params': {
            'author': accountName,
            'permlink': permlink,
            if (observer != null) 'observer': observer,
          },
          'id': 1,
        });

        if (discussionRes != null) {
          final decoded = jsonDecode(discussionRes.body);
          if (!(decoded is Map && decoded['error'] != null)) {
            final result = (decoded is Map) ? decoded['result'] : decoded;
            if (result is Map<String, dynamic>) {
              final post = result['post'];
              if (post is Map<String, dynamic>) entries.add(post);
              final replies = result['replies'];
              if (replies is List) {
                entries.addAll(replies);
              } else if (replies is Map) {
                entries.addAll((replies as Map).values);
              }
            } else if (result is List) {
              entries.addAll(result);
            }
          }
        }
      }

      // Deduplicate entries based on author/permlink
      final seen = <String>{};
      entries = entries.where((e) {
        if (e is Map) {
          final key = '${e['author']}/${e['permlink']}';
          if (seen.contains(key)) return false;
          seen.add(key);
        }
        return true;
      }).toList();

      final normalizedEntries = _normalize(entries);
      final list = await ThreadFeedModel.parseThreadsAsync(normalizedEntries);
      return ActionListDataResponse<ThreadFeedModel>(
        data: list,
        status: ResponseStatus.success,
        isSuccess: true,
        errorMessage: '',
      );
    } catch (e) {
      return ActionListDataResponse(
        status: ResponseStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  // -------------------------- Auth redirect / decrypt / validation --------------------------

  Future<ActionSingleDataResponse<AuthRedirectionResponse>> getRedirectUri(
      String accountName) async {
    try {
      final jsonString = await getRedirectUriDataFromPlatform(accountName);
      final response =
      ActionSingleDataResponse<AuthRedirectionResponse>.fromJsonString(
        jsonString,
        AuthRedirectionResponse.fromJson,
      );
      return response;
    } catch (e) {
      return ActionSingleDataResponse(
        status: ResponseStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  Future<ActionSingleDataResponse<AuthDecryptionResponse>> getDecryptedHASToken(
      String accountName, String encryptedData, String authKey) async {
    try {
      final jsonString = await getDecryptedHASTokenFromPlatform(
          accountName, encryptedData, authKey);
      final response =
      ActionSingleDataResponse<AuthDecryptionResponse>.fromJsonString(
        jsonString,
        AuthDecryptionResponse.fromJson,
      );
      return response;
    } catch (e) {
      return ActionSingleDataResponse(
        status: ResponseStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  Future<ActionSingleDataResponse<String>> validatePostingKey(
      String accountName, String postingKey) async {
    try {
      final accountRes = await _postWithFallback({
        'jsonrpc': '2.0',
        'method': 'condenser_api.get_accounts',
        'params': [
          [accountName],
        ],
        'id': 1,
      });

      if (accountRes == null || accountRes.statusCode != 200) {
        return ActionSingleDataResponse(
          status: ResponseStatus.failed,
          errorMessage: _rpcErrorMessage(accountRes,
              fallback: 'Account lookup failed'),
        );
      }

      final decoded = _tryDecode(accountRes.body);
      if (decoded is! Map || decoded['result'] == null) {
        return ActionSingleDataResponse(
          status: ResponseStatus.failed,
          errorMessage: 'Account lookup failed',
        );
      }

      final accounts = decoded['result'];
      if (accounts is! List || accounts.isEmpty) {
        return ActionSingleDataResponse(
          status: ResponseStatus.failed,
          errorMessage: 'Account not found',
        );
      }

      final accountJson = jsonEncode(accounts.first);

      final jsonString = await validatePostingKeyFromPlatform(
        accountName,
        postingKey,
        accountJson,
      ).timeout(const Duration(seconds: 15));
      final response = ActionSingleDataResponse<String>.fromJsonString(
        jsonString,
        null,
        ignoreFromJson: true,
      );
      return response;
    } on TimeoutException {
      return ActionSingleDataResponse(
        status: ResponseStatus.failed,
        errorMessage: 'Request timed out',
      );
    } catch (e) {
      return ActionSingleDataResponse(
        status: ResponseStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  // -------------------------- Mutations (comment/vote/mute/poll) --------------------------

  Future<ActionSingleDataResponse<String>> commentOnContent(
      String username,
      String author,
      String parentPermlink,
      String permlink,
      String comment,
      List<String> tags,
      String? postingKey,
      String? authKey,
      String? token,
      ) async {
    try {
      final jsonString = await commentOnContentFromPlatform(
        username,
        author,
        parentPermlink,
        permlink,
        comment,
        tags,
        postingKey,
        authKey,
        token,
      ).timeout(const Duration(seconds: 15));

      final response = ActionSingleDataResponse<String>.fromJsonString(
        jsonString,
        null,
        ignoreFromJson: true,
      );
      return response;
    } on TimeoutException {
      final confirmed = await _confirmCommentOnChain(
        commentAuthor: username,
        permlink: permlink,
      );
      if (confirmed) {
        return ActionSingleDataResponse(
          status: ResponseStatus.success,
          errorMessage: '',
          isSuccess: true,
          valid: true,
        );
      }
      return ActionSingleDataResponse(
        status: ResponseStatus.failed,
        errorMessage: 'Request timed out',
      );
    } catch (e) {
      return ActionSingleDataResponse(
        status: ResponseStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  Future<bool> _confirmCommentOnChain({
    required String commentAuthor,
    required String permlink,
  }) async {
    final payload = {
      'jsonrpc': '2.0',
      'method': 'condenser_api.get_content',
      'params': [commentAuthor, permlink],
      'id': 1,
    };

    var delay = const Duration(seconds: 1);
    for (var i = 0; i < 3; i++) {
      try {
        final res = await _postWithFallback(
          payload,
          timeout: const Duration(seconds: 3),
          // optional sticky across checks:
          stickyKey: 'confirm:$commentAuthor:$permlink',
        );
        if (res != null) {
          final decoded = _tryDecode(res.body);
          final result = (decoded is Map) ? decoded['result'] : null;
          if (result is Map &&
              result['author'] == commentAuthor &&
              result['permlink'] == permlink &&
              result['id'] != 0) {
            return true;
          }
        }
      } catch (_) {}
      await Future.delayed(delay);
      delay += const Duration(seconds: 1); // light backoff
    }

    return false;
  }

  Future<ActionSingleDataResponse<String>> voteContent(
      String username,
      String author,
      String permlink,
      int weight,
      String? postingKey,
      String? authKey,
      String? token,
      ) async {
    try {
      final jsonString = await voteContentFromPlatform(
          username, author, permlink, weight, postingKey, authKey, token);
      final response = ActionSingleDataResponse<String>.fromJsonString(
        jsonString,
        null,
        ignoreFromJson: true,
      );
      return response;
    } catch (e) {
      return ActionSingleDataResponse(
        status: ResponseStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  Future<ActionSingleDataResponse<String>> castPollVote(
      String username,
      String pollId,
      List<int> choices,
      String? postingKey,
      String? authKey,
      String? token,
      ) async {
    try {
      final jsonString = await castPollVoteFromPlatform(
          username, pollId, choices, postingKey, authKey, token);
      final response = ActionSingleDataResponse<String>.fromJsonString(
        jsonString,
        null,
        ignoreFromJson: true,
      );
      return response;
    } catch (e) {
      return ActionSingleDataResponse(
        status: ResponseStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  Future<ActionSingleDataResponse<String>> transfer(
      String username,
      String recipient,
      double amount,
      String assetSymbol,
      String memo,
      String? postingKey,
      String? authKey,
      String? token,
      ) async {
    try {
      final formattedAmount = amount.toStringAsFixed(3);
      final jsonString = await transferFromPlatform(
        username,
        recipient,
        formattedAmount,
        assetSymbol,
        memo,
        postingKey,
        authKey,
        token,
      );
      final response = ActionSingleDataResponse<String>.fromJsonString(
        jsonString,
        null,
        ignoreFromJson: true,
      );
      return response;
    } catch (e) {
      return ActionSingleDataResponse(
        status: ResponseStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  Future<ActionSingleDataResponse<String>> muteUser(
      String username,
      String author,
      String? postingKey,
      String? authKey,
      String? token,
      ) async {
    try {
      final jsonString = await muteUserFromPlatform(
          username, author, postingKey, authKey, token);
      final response = ActionSingleDataResponse<String>.fromJsonString(
        jsonString,
        null,
        ignoreFromJson: true,
      );
      return response;
    } catch (e) {
      return ActionSingleDataResponse(
        status: ResponseStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  Future<ActionSingleDataResponse<String>> setFollowStatus(
    String username,
    String author,
    bool follow,
    String? postingKey,
    String? authKey,
    String? token,
  ) async {
    try {
      final jsonString = await setFollowStatusFromPlatform(
        username,
        author,
        follow,
        postingKey,
        authKey,
        token,
      );
      final response = ActionSingleDataResponse<String>.fromJsonString(
        jsonString,
        null,
        ignoreFromJson: true,
      );
      return response;
    } catch (e) {
      return ActionSingleDataResponse(
        status: ResponseStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  Future<ActionSingleDataResponse<String>> updateFollowStatus(
    String username,
    String author,
    bool follow,
    String? postingKey,
    String? authKey,
    String? token,
  ) async {
    try {
      final jsonString = await updateFollowStatusFromPlatform(
        username,
        author,
        follow,
        postingKey,
        authKey,
        token,
      );
      final response = ActionSingleDataResponse<String>.fromJsonString(
        jsonString,
        null,
        ignoreFromJson: true,
      );
      return response;
    } catch (e) {
      return ActionSingleDataResponse(
        status: ResponseStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  Future<ActionSingleDataResponse<bool>> _fetchFollowRelationship(
    String follower,
    String following,
  ) async {
    try {
      final response = await _postWithFallback({
        'jsonrpc': '2.0',
        'method': 'bridge.get_relationship_between_accounts',
        'params': {
          // Both naming conventions are provided to remain compatible with
          // different bridge node versions (some expect `account1/account2`
          // while others still honour `account/target`).
          'account': follower,
          'target': following,
          'account1': follower,
          'account2': following,
        },
        'id': 1,
      });

      if (response == null) {
        return ActionSingleDataResponse(
          status: ResponseStatus.failed,
          errorMessage: 'RPC error: no node responded',
        );
      }

      final decoded = _tryDecode(response.body);
      if (decoded is Map && decoded['error'] != null) {
        return ActionSingleDataResponse(
          status: ResponseStatus.failed,
          errorMessage: _rpcErrorMessage(response),
        );
      }

      final result = (decoded is Map) ? decoded['result'] : null;
      if (result is Map) {
        final follows = result['follows'];
        final isFollowing = follows is bool
            ? follows
            : (follows is String
                ? (follows.toLowerCase() == 'true' || follows == '1')
                : (follows is num ? follows != 0 : false));
        return ActionSingleDataResponse<bool>(
          data: isFollowing,
          status: ResponseStatus.success,
          isSuccess: true,
          errorMessage: '',
        );
      } else if (result is bool) {
        return ActionSingleDataResponse<bool>(
          data: result,
          status: ResponseStatus.success,
          isSuccess: true,
          errorMessage: '',
        );
      }

      return ActionSingleDataResponse(
        status: ResponseStatus.failed,
        errorMessage: 'Unexpected response',
      );
    } catch (e) {
      return ActionSingleDataResponse(
        status: ResponseStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  Future<ActionSingleDataResponse<bool>> fetchFollowRelationship(
    String follower,
    String following,
  ) async {
    return _fetchFollowRelationship(follower, following);
  }

  Future<ActionSingleDataResponse<bool>> loadFollowRelationship(
    String follower,
    String following,
  ) async {
    return _fetchFollowRelationship(follower, following);
  }

  Future<ActionListDataResponse<FollowUserItemModel>> getFollowers(
    String accountName, {
    String? start,
    int limit = 20,
  }) async {
    return _fetchFollowUsers(
      method: 'condenser_api.get_followers',
      accountName: accountName,
      start: start,
      limit: limit,
      parser: FollowUserItemModel.fromFollowerJson,
    );
  }

  Future<ActionListDataResponse<FollowUserItemModel>> getFollowing(
    String accountName, {
    String? start,
    int limit = 20,
  }) async {
    return _fetchFollowUsers(
      method: 'condenser_api.get_following',
      accountName: accountName,
      start: start,
      limit: limit,
      parser: FollowUserItemModel.fromFollowingJson,
    );
  }

  Future<ActionListDataResponse<FollowUserItemModel>> _fetchFollowUsers({
    required String method,
    required String accountName,
    String? start,
    required int limit,
    required FollowUserItemModel Function(Map<String, dynamic>) parser,
  }) async {
    try {
      final response = await _postWithFallback({
        'jsonrpc': '2.0',
        'method': method,
        'params': [accountName, start ?? '', 'blog', limit],
        'id': 1,
      });

      if (response == null) {
        return ActionListDataResponse(
          status: ResponseStatus.failed,
          errorMessage: 'RPC error: no node responded',
        );
      }

      final decoded = _tryDecode(response.body);
      if (decoded is Map && decoded['error'] != null) {
        return ActionListDataResponse(
          status: ResponseStatus.failed,
          errorMessage: _rpcErrorMessage(response),
        );
      }

      final result = (decoded is Map) ? decoded['result'] : null;
      if (result is List) {
        final items = <FollowUserItemModel>[];
        for (final entry in result) {
          if (entry is Map) {
            final map = Map<String, dynamic>.from(entry as Map);
            final item = parser(map);
            if (item.name.isNotEmpty) {
              items.add(item);
            }
          }
        }
        if (start != null && start.isNotEmpty && items.isNotEmpty) {
          if (items.first.name == start) {
            items.removeAt(0);
          }
        }
        return ActionListDataResponse<FollowUserItemModel>(
          data: items,
          status: ResponseStatus.success,
          isSuccess: true,
          errorMessage: '',
        );
      }

      return ActionListDataResponse(
        status: ResponseStatus.failed,
        errorMessage: 'Unexpected response',
      );
    } catch (e) {
      return ActionListDataResponse(
        status: ResponseStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  // -------------------------- HiveSigner broadcast --------------------------

  Future<ActionSingleDataResponse> broadcastTransactionUsingHiveSigner<T>(
      String accessToken, BroadcastModel<T> args) async {
    final url = Uri.parse('https://hivesigner.com/api/broadcast');
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final body = json.encode({
      'operations': [
        [enumToString(args.type), args.toJson()]
      ]
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      final decoded = _tryDecode(response.body);

      if (response.statusCode == 200) {
        if (decoded is Map && decoded['error'] == null) {
          return ActionSingleDataResponse(
            data: null,
            errorMessage: "",
            status: ResponseStatus.success,
            isSuccess: true,
          );
        }
        final errMsg = (decoded is Map && decoded['error'] != null)
            ? decoded['error'].toString()
            : 'Unknown error';
        return ActionSingleDataResponse(
          data: null,
          errorMessage: errMsg,
          status: ResponseStatus.failed,
          isSuccess: false,
        );
      } else {
        final msg = (decoded is Map && decoded['error_description'] is String)
            ? decoded['error_description'] as String
            : 'HiveSigner error (${response.statusCode})';
        return ActionSingleDataResponse(
          data: null,
          errorMessage: msg,
          status: ResponseStatus.failed,
          isSuccess: false,
        );
      }
    } catch (e) {
      return ActionSingleDataResponse(
        data: null,
        errorMessage: e.toString(),
        status: ResponseStatus.failed,
        isSuccess: false,
      );
    }
  }

  // -------------------------- Accounts / Follows --------------------------

  Future<ActionSingleDataResponse<UserModel>> getAccountInfo(
      String accountName,
      ) async {
    try {
      final response = await _postWithFallback({
        'jsonrpc': '2.0',
        'method': 'condenser_api.get_accounts',
        'params': [
          [accountName]
        ],
        'id': 1,
      });

      if (response == null) {
        return ActionSingleDataResponse(
          status: ResponseStatus.failed,
          errorMessage: 'RPC error: no node responded',
        );
      }

      final decoded = _tryDecode(response.body);
      if (decoded is Map && decoded['error'] != null) {
        return ActionSingleDataResponse(
          status: ResponseStatus.failed,
          errorMessage: _rpcErrorMessage(response),
        );
      }

      final result = (decoded is Map) ? decoded['result'] : null;
      if (result is List) {
        final usersJson = jsonEncode(result);
        final users = UserModel.fromJsonString(usersJson);
        if (users.isEmpty) {
          return ActionSingleDataResponse(
            status: ResponseStatus.failed,
            errorMessage: "Account not found",
          );
        }
        return ActionSingleDataResponse<UserModel>(
          data: users.first,
          status: ResponseStatus.success,
          isSuccess: true,
          errorMessage: "",
        );
      }

      return ActionSingleDataResponse(
        status: ResponseStatus.failed,
        errorMessage: 'Unexpected response',
      );
    } catch (e) {
      return ActionSingleDataResponse(
        status: ResponseStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  Future<ActionSingleDataResponse<FollowCountModel>> getFollowCount(
      String accountName,
      ) async {
    try {
      final response = await _postWithFallback({
        'jsonrpc': '2.0',
        'method': 'condenser_api.get_follow_count',
        'params': [accountName],
        'id': 1,
      });

      if (response == null) {
        return ActionSingleDataResponse(
          status: ResponseStatus.failed,
          errorMessage: 'RPC error: no node responded',
        );
      }

      final decoded = _tryDecode(response.body);
      if (decoded is Map && decoded['error'] != null) {
        return ActionSingleDataResponse(
          status: ResponseStatus.failed,
          errorMessage: _rpcErrorMessage(response),
        );
      }

      final result = (decoded is Map) ? decoded['result'] : null;
      if (result != null) {
        final countJson = jsonEncode(result);
        return ActionSingleDataResponse<FollowCountModel>(
          data: FollowCountModel.fromJsonString(countJson),
          status: ResponseStatus.success,
          isSuccess: true,
          errorMessage: "",
        );
      }

      return ActionSingleDataResponse(
        status: ResponseStatus.failed,
        errorMessage: 'Unexpected response',
      );
    } catch (e) {
      return ActionSingleDataResponse(
        status: ResponseStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  // -------------------------- Image upload --------------------------

  Future<ActionSingleDataResponse<String>> getImageUploadProofWithPostingKey(
      String accountName, String postingKey) async {
    try {
      final jsonString = await getImageUploadProofWithPostingKeyFromPlatform(
          accountName, postingKey);
      return ActionSingleDataResponse(
        errorMessage: "",
        status: ResponseStatus.success,
        isSuccess: true,
        valid: true,
        data: jsonString,
      );
    } catch (e) {
      return ActionSingleDataResponse(
        status: ResponseStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  Future<ActionSingleDataResponse<ImageUploadResponse>> uploadAndGetImageUrl(
      XFile image, String imageUploadToken) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://images.ecency.com/hs/$imageUploadToken'),
      );

      String imageExtension = image.name.split(".").last;
      if (imageExtension.toLowerCase() == 'jpg') {
        imageExtension = "jpeg";
      }

      final multipartFile = http.MultipartFile(
        'file',
        image.readAsBytes().asStream(),
        await image.length(),
        filename: image.name,
        contentType: MediaType("image", imageExtension),
      );
      request.files.add(multipartFile);

      final response = await request.send();
      final responseString = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return ActionSingleDataResponse<ImageUploadResponse>(
          data: ImageUploadResponse.fromJsonString(responseString),
          status: ResponseStatus.success,
          isSuccess: true,
          errorMessage: "",
        );
      } else {
        try {
          final parsed =
          ImageUploadErrorResponse.fromJsonString(responseString);
          final msg = parsed.error?.message ?? "Upload failed";
          return ActionSingleDataResponse(
            status: ResponseStatus.failed,
            errorMessage: msg,
          );
        } catch (_) {
          return ActionSingleDataResponse(
            status: ResponseStatus.failed,
            errorMessage: "Upload failed (${response.statusCode})",
          );
        }
      }
    } catch (e) {
      return ActionSingleDataResponse(
        status: ResponseStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  // -------------------------- Notifications --------------------------

  Future<ActionSingleDataResponse<int>> getUnreadNotificationCount({
    required String userName,
    String? code,
  }) async {
    final url = Uri.parse(
        'https://ecency.com/private-api/pub-notifications/$userName');
    final headers = {
      ..._jsonHeaders,
      if (code != null && code.isNotEmpty) 'code': code,
    };

    try {
      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = _tryDecode(response.body);
        if (decoded is Map && decoded['count'] is num) {
          return ActionSingleDataResponse<int>(
            data: (decoded['count'] as num).toInt(),
            status: ResponseStatus.success,
            isSuccess: true,
            valid: true,
            errorMessage: '',
          );
        }

        return ActionSingleDataResponse(
          status: ResponseStatus.failed,
          errorMessage: 'Unexpected response',
        );
      }

      return ActionSingleDataResponse(
        status: ResponseStatus.failed,
        errorMessage: response.body.isNotEmpty
            ? response.body
            : 'Server Error (${response.statusCode})',
      );
    } on TimeoutException {
      return ActionSingleDataResponse(
        status: ResponseStatus.failed,
        errorMessage: 'Request timed out',
      );
    } catch (e) {
      return ActionSingleDataResponse(
        status: ResponseStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  Future<ActionListDataResponse<NotificationModel>> getNotifications({
    required String userName,
    String? filter,
    String? since,
    int? limit,
    String? code,
  }) async {
    final url = Uri.parse('https://ecency.com/private-api/notifications');
    final body = <String, dynamic>{'user': userName};

    if (code != null && code.isNotEmpty) {
      body['code'] = code;
    }

    if (filter != null && filter.isNotEmpty) {
      body['filter'] = filter;
    }
    if (since != null && since.isNotEmpty) {
      body['since'] = since;
    }
    if (limit != null) {
      body['limit'] = limit;
    }

    final headers = {
      ..._jsonHeaders,
    };

    try {
      final response = await http
          .post(url, headers: headers, body: json.encode(body))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = _tryDecode(response.body);

        if (decoded is List) {
          final notifications = decoded
              .map((item) {
                if (item is Map<String, dynamic>) {
                  return NotificationModel.fromJson(item);
                }
                if (item is Map) {
                  return NotificationModel.fromJson(
                      Map<String, dynamic>.from(item as Map));
                }
                return null;
              })
              .whereType<NotificationModel>()
              .toList();

          return ActionListDataResponse<NotificationModel>(
            data: notifications,
            status: ResponseStatus.success,
            isSuccess: true,
            valid: true,
            errorMessage: '',
          );
        }

        if (decoded is Map && decoded['count'] is num) {
          return ActionListDataResponse<NotificationModel>(
            data: const <NotificationModel>[],
            status: ResponseStatus.success,
            isSuccess: true,
            valid: true,
            errorMessage: '',
          );
        }

        return ActionListDataResponse(
          status: ResponseStatus.failed,
          errorMessage: 'Unexpected response',
        );
      }

      return ActionListDataResponse(
        status: ResponseStatus.failed,
        errorMessage: response.body.isNotEmpty
            ? response.body
            : 'Server Error (${response.statusCode})',
      );
    } on TimeoutException {
      return ActionListDataResponse(
        status: ResponseStatus.failed,
        errorMessage: 'Request timed out',
      );
    } catch (e) {
      return ActionListDataResponse(
        status: ResponseStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  Future<ActionSingleDataResponse<void>> markNotification({
    required String userName,
    String? id,
    String? code,
  }) async {
    final url = Uri.parse('https://ecency.com/private-api/notifications/mark');
    final headers = {
      ..._jsonHeaders,
    };

    final body = <String, dynamic>{'user': userName};
    if (code != null && code.isNotEmpty) {
      body['code'] = code;
    }
    if (id != null && id.isNotEmpty) {
      body['id'] = id;
    }

    try {
      final response = await http
          .post(url, headers: headers, body: json.encode(body))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ActionSingleDataResponse<void>(
          data: null,
          status: ResponseStatus.success,
          isSuccess: true,
          valid: true,
          errorMessage: '',
        );
      }

      return ActionSingleDataResponse<void>(
        status: ResponseStatus.failed,
        errorMessage: response.body.isNotEmpty
            ? response.body
            : 'Server Error (${response.statusCode})',
      );
    } on TimeoutException {
      return ActionSingleDataResponse<void>(
        status: ResponseStatus.failed,
        errorMessage: 'Request timed out',
      );
    } catch (e) {
      return ActionSingleDataResponse<void>(
        status: ResponseStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  // -------------------------- Private API (report/delete) --------------------------

  Future<ActionSingleDataResponse<ReportResponse>> reportThread(
      String author, String permlink) async {
    try {
      final url = Uri.parse("https://ecency.com/private-api/report");
      final response = await http.post(
        url,
        headers: _jsonHeaders,
        body: json.encode({
          "type": "content",
          "data": "https://ecency.com/@$author/$permlink",
        }),
      );

      if (response.statusCode == 200) {
        return ActionSingleDataResponse<ReportResponse>(
          data: ReportResponse.fromRawJson(response.body),
          status: ResponseStatus.success,
          isSuccess: true,
          errorMessage: "",
        );
      } else {
        final decoded = _tryDecode(response.body);
        final msg = (decoded is Map && decoded['message'] is String)
            ? decoded['message'] as String
            : "Server Error (${response.statusCode})";
        return ActionSingleDataResponse(
          status: ResponseStatus.failed,
          errorMessage: msg,
        );
      }
    } catch (e) {
      return ActionSingleDataResponse(
        status: ResponseStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  Future<ActionSingleDataResponse<ReportResponse>> deleteAccount(
      String accountName) async {
    try {
      final url = Uri.parse("https://ecency.com/private-api/request-delete");
      final response = await http.post(
        url,
        headers: _jsonHeaders,
        body: json.encode({
          "type": "content",
          "data": {"account": accountName},
        }),
      );

      if (response.statusCode == 200) {
        return ActionSingleDataResponse<ReportResponse>(
          data: ReportResponse.fromRawJson(response.body),
          status: ResponseStatus.success,
          isSuccess: true,
          errorMessage: "",
        );
      } else {
        final decoded = _tryDecode(response.body);
        final msg = (decoded is Map && decoded['message'] is String)
            ? decoded['message'] as String
            : "Server Error (${response.statusCode})";
        return ActionSingleDataResponse(
          status: ResponseStatus.failed,
          errorMessage: msg,
        );
      }
    } catch (e) {
      return ActionSingleDataResponse(
        status: ResponseStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  // -------------------------- Ecency Waves APIs --------------------------

  Future<ActionListDataResponse<ThreadFeedModel>> getTagWaves(
      String container, String tag,
      {int limit = 20, String? lastAuthor, String? lastPermlink}) async {
    try {
      final query = StringBuffer(
          'https://ecency.com/private-api/waves/tags?container=$container&tag=$tag&limit=$limit');
      if (lastAuthor != null) {
        query.write('&start_author=$lastAuthor');
      }
      if (lastPermlink != null) {
        query.write('&start_permlink=$lastPermlink');
      }
      final url = Uri.parse(query.toString());
      final res = await http
          .get(url, headers: _jsonHeaders)
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final decoded = _tryDecode(res.body);
        if (decoded is List) {
          final items = decoded.map((e) {
            final map = Map<String, dynamic>.from(e as Map);
            map['post_id'] ??= map['id'];
            map['created'] ??= map['timestamp'];
            return ThreadFeedModel.fromJson(map);
          }).toList();
          return ActionListDataResponse<ThreadFeedModel>(
            data: items,
            status: ResponseStatus.success,
            isSuccess: true,
            errorMessage: '',
          );
        }
      }
      return ActionListDataResponse(
        status: ResponseStatus.failed,
        errorMessage: res.body.isNotEmpty
            ? res.body
            : 'Server Error (${res.statusCode})',
      );
    } on TimeoutException {
      return ActionListDataResponse(
        status: ResponseStatus.failed,
        errorMessage: 'API seems slow or inaccessible, try again later.',
      );
    } catch (e) {
      return ActionListDataResponse(
        status: ResponseStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  Future<ActionListDataResponse<ThreadFeedModel>> getAccountWaves(
      String container, String username,
      {int limit = 20, String? lastAuthor, String? lastPermlink}) async {
    try {
      final query = StringBuffer(
          'https://ecency.com/private-api/waves/account?container=$container&username=$username&limit=$limit');
      if (lastAuthor != null) {
        query.write('&start_author=$lastAuthor');
      }
      if (lastPermlink != null) {
        query.write('&start_permlink=$lastPermlink');
      }
      final url = Uri.parse(query.toString());
      final res = await http
          .get(url, headers: _jsonHeaders)
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final decoded = _tryDecode(res.body);
        if (decoded is List) {
          final items = decoded.map((e) {
            final map = Map<String, dynamic>.from(e as Map);
            map['post_id'] ??= map['id'];
            map['created'] ??= map['timestamp'];
            return ThreadFeedModel.fromJson(map);
          }).toList();
          return ActionListDataResponse<ThreadFeedModel>(
            data: items,
            status: ResponseStatus.success,
            isSuccess: true,
            errorMessage: '',
          );
        }
      }
      return ActionListDataResponse(
        status: ResponseStatus.failed,
        errorMessage: res.body.isNotEmpty
            ? res.body
            : 'Server Error (${res.statusCode})',
      );
    } on TimeoutException {
      return ActionListDataResponse(
        status: ResponseStatus.failed,
        errorMessage: 'API seems slow or inaccessible, try again later.',
      );
    } catch (e) {
      return ActionListDataResponse(
        status: ResponseStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  Future<ActionListDataResponse<ThreadFeedModel>> fetchFollowingFeed(
      String container, String username,
      {int limit = 20, String? lastAuthor, String? lastPermlink}) async {
    try {
      final queryParameters = <String, String>{
        'container': container,
        'username': username,
        'limit': '$limit',
      };
      if (lastAuthor != null && lastAuthor.isNotEmpty) {
        queryParameters['start_author'] = lastAuthor;
      }
      if (lastPermlink != null && lastPermlink.isNotEmpty) {
        queryParameters['start_permlink'] = lastPermlink;
      }
      final url = Uri.https(
        'ecency.com',
        '/api/waves/following',
        queryParameters,
      );
      final res = await http
          .get(url, headers: _jsonHeaders)
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final decoded = _tryDecode(res.body);
        if (decoded is List) {
          final items = decoded.map((e) {
            final map = Map<String, dynamic>.from(e as Map);
            map['post_id'] ??= map['id'];
            map['created'] ??= map['timestamp'];
            return ThreadFeedModel.fromJson(map);
          }).toList();
          return ActionListDataResponse<ThreadFeedModel>(
            data: items,
            status: ResponseStatus.success,
            isSuccess: true,
            errorMessage: '',
          );
        }
      }
      return ActionListDataResponse(
        status: ResponseStatus.failed,
        errorMessage: res.body.isNotEmpty
            ? res.body
            : 'Server Error (${res.statusCode})',
      );
    } on TimeoutException {
      return ActionListDataResponse(
        status: ResponseStatus.failed,
        errorMessage: 'API seems slow or inaccessible, try again later.',
      );
    } catch (e) {
      return ActionListDataResponse(
        status: ResponseStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  Future<ActionListDataResponse<SearchUserModel>> searchUsers(String query,
      {int limit = 20}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return ActionListDataResponse<SearchUserModel>(
        data: const <SearchUserModel>[],
        status: ResponseStatus.success,
        isSuccess: true,
        valid: true,
        errorMessage: '',
      );
    }

    try {
      final response = await _postWithFallback({
        'jsonrpc': '2.0',
        'method': 'condenser_api.lookup_accounts',
        'params': [trimmed, limit],
        'id': 1,
      });

      if (response == null || response.statusCode != 200) {
        return ActionListDataResponse(
          status: ResponseStatus.failed,
          errorMessage:
              _rpcErrorMessage(response, fallback: 'Account search failed'),
        );
      }

      final decoded = _tryDecode(response.body);
      if (decoded is Map && decoded['result'] is List) {
        final accounts = (decoded['result'] as List)
            .whereType<String>()
            .map(SearchUserModel.fromName)
            .where((user) => user.name.isNotEmpty)
            .toList();
        return ActionListDataResponse<SearchUserModel>(
          data: accounts,
          status: ResponseStatus.success,
          isSuccess: true,
          valid: true,
          errorMessage: '',
        );
      }

      return ActionListDataResponse(
        status: ResponseStatus.failed,
        errorMessage: 'Account search failed',
      );
    } catch (e) {
      return ActionListDataResponse(
        status: ResponseStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  Future<ActionListDataResponse<SearchTagModel>> searchTags(String query,
      {int limit = 250}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return ActionListDataResponse<SearchTagModel>(
        data: const <SearchTagModel>[],
        status: ResponseStatus.success,
        isSuccess: true,
        valid: true,
        errorMessage: '',
      );
    }

    final sanitizedQuery =
        trimmed.startsWith('#') ? trimmed.substring(1) : trimmed;
    if (sanitizedQuery.isEmpty) {
      return ActionListDataResponse<SearchTagModel>(
        data: const <SearchTagModel>[],
        status: ResponseStatus.success,
        isSuccess: true,
        valid: true,
        errorMessage: '',
      );
    }

    try {
      final response = await _postWithFallback({
        'jsonrpc': '2.0',
        'method': 'condenser_api.get_trending_tags',
        'params': [sanitizedQuery, limit],
        'id': 1,
      });

      if (response == null || response.statusCode != 200) {
        return ActionListDataResponse(
          status: ResponseStatus.failed,
          errorMessage:
              _rpcErrorMessage(response, fallback: 'Tag search failed'),
        );
      }

      final decoded = _tryDecode(response.body);
      if (decoded is Map && decoded['result'] is List) {
        final lowerQuery = sanitizedQuery.toLowerCase();
        final tagResults = (decoded['result'] as List)
            .whereType<Map<String, dynamic>>()
            .map(SearchTagModel.fromJson)
            .where((tag) => tag.name.isNotEmpty)
            .where(
              (tag) => tag.name.toLowerCase().contains(lowerQuery),
            )
            .toList();
        return ActionListDataResponse<SearchTagModel>(
          data: tagResults,
          status: ResponseStatus.success,
          isSuccess: true,
          valid: true,
          errorMessage: '',
        );
      }

      return ActionListDataResponse(
        status: ResponseStatus.failed,
        errorMessage: 'Tag search failed',
      );
    } catch (e) {
      return ActionListDataResponse(
        status: ResponseStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  Future<ActionListDataResponse<TrendingTagModel>> getTrendingTags(
      String container) async {
    try {
      final url = Uri.parse(
          'https://ecency.com/private-api/waves/trending/tags?container=$container');
      final res = await http
          .get(url, headers: _jsonHeaders)
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final decoded = _tryDecode(res.body);
        if (decoded is List) {
          final items = decoded
              .map((e) => TrendingTagModel.fromJson(e))
              .toList();
          return ActionListDataResponse<TrendingTagModel>(
              data: items,
              status: ResponseStatus.success,
              isSuccess: true,
              errorMessage: '');
        }
      }
      return ActionListDataResponse(
        status: ResponseStatus.failed,
        errorMessage: res.body.isNotEmpty
            ? res.body
            : 'Server Error (${res.statusCode})',
      );
    } on TimeoutException {
      return ActionListDataResponse(
        status: ResponseStatus.failed,
        errorMessage:
            'API seems slow or inaccessible, try again later.',
      );
    } catch (e) {
      return ActionListDataResponse(
        status: ResponseStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  Future<ActionListDataResponse<TrendingAuthorModel>> getTrendingAuthors(
      String container) async {
    try {
      final url = Uri.parse(
          'https://ecency.com/private-api/waves/trending/authors?container=$container');
      final res = await http
          .get(url, headers: _jsonHeaders)
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final decoded = _tryDecode(res.body);
        if (decoded is List) {
          final items = decoded
              .map((e) => TrendingAuthorModel.fromJson(e))
              .toList();
          return ActionListDataResponse<TrendingAuthorModel>(
              data: items,
              status: ResponseStatus.success,
              isSuccess: true,
              errorMessage: '');
        }
      }
      return ActionListDataResponse(
        status: ResponseStatus.failed,
        errorMessage: res.body.isNotEmpty
            ? res.body
            : 'Server Error (${res.statusCode})',
      );
    } on TimeoutException {
      return ActionListDataResponse(
        status: ResponseStatus.failed,
        errorMessage:
            'API seems slow or inaccessible, try again later.',
      );
    } catch (e) {
      return ActionListDataResponse(
        status: ResponseStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }
}
