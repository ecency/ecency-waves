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
import 'package:waves/features/user/models/follow_count_model.dart';
import 'package:waves/features/user/models/user_model.dart';

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

    final res = await _postWithFallback({
      'jsonrpc': '2.0',
      'method': 'bridge.get_account_posts',
      'params': params,
      'id': 1,
    }, stickyKey: stickyKey);

    if (res == null) {
      return http.Response('RPC error: no node responded', 500);
    }

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
      String accountName, String permlink, String? observer) async {
    try {
      final params = {
        'author': accountName,
        'permlink': permlink,
        if (observer != null) 'observer': observer,
      };

      // Sticky per discussion
      final stickyKey = 'discussion:$accountName:$permlink';

      final response = await _postWithFallback({
        'jsonrpc': '2.0',
        'method': 'bridge.get_discussion',
        'params': params,
        'id': 1,
      }, stickyKey: stickyKey);

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
      final Map<String, dynamic> comments = {};

      if (result is Map<String, dynamic>) {
        final post = result['post'];
        if (post is Map<String, dynamic>) {
          final key = '${post['author']}/${post['permlink']}';
          comments[key] = post;
        }
        final replies = result['replies'];
        if (replies is Map<String, dynamic>) {
          comments.addAll(replies);
        }
      }

      // Keep original generic <ThreadFeedModel> to avoid breaking callers.
      return ActionListDataResponse<ThreadFeedModel>(
        data: CommentModel.fromRawJson(jsonEncode(comments)),
        status: ResponseStatus.success,
        isSuccess: true,
        errorMessage: "",
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
      final jsonString =
      await validatePostingKeyFromPlatform(accountName, postingKey);
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
      double weight,
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
}
