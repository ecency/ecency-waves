import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:waves/core/common/extensions/ui.dart';
import 'package:waves/core/models/action_response.dart';
import 'package:waves/core/routes/routes.dart';
import 'package:waves/core/services/poll_service/poll_api.dart';
import 'package:waves/core/services/poll_service/poll_model.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/auth/models/hive_signer_auth_model.dart';
import 'package:waves/features/auth/models/posting_auth_model.dart';
import 'package:waves/features/auth/models/user_auth_model.dart';
import 'package:waves/features/threads/models/comment/comment_navigation_model.dart';
import 'package:waves/features/threads/presentation/comments/add_comment/controller/sign_transaction_hive_signer_controller.dart';
import 'package:waves/features/threads/presentation/comments/add_comment/controller/sign_transaction_posting_key_controller.dart';

class PollController with ChangeNotifier {
  UserAuthModel? userData;

  bool _isLoading = false;
  final Map<String, PollModel> _pollMap = {};

  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  PollController({required this.userData});

  void updateUserData(UserAuthModel? user) {
    userData = user;
  }

  Future<void> fetchPollData(String author, String permlink) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate a network request
      ActionSingleDataResponse<PollModel> response =
          await fetchPoll(author, permlink);
      if (response.isSuccess && response.data != null) {
        String pollKey = _getLocalPollKey(author, permlink);
        PollModel? data = response.data;
        if (data != null) {
          _pollMap[pollKey] = data;
        }
      }
    } catch (error) {
      _errorMessage = 'Error: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }



  Future<bool> castVote(BuildContext context,
      String author, String permlink, List<int> selection) async {
    print("cast vote for $author $permlink using choice $selection");

    String pollKey = _getLocalPollKey(author, permlink);
    PollModel? poll = _pollMap[pollKey];

    if (userData == null) {
      return false;
    }

    if (poll == null) {
      return false;
    }

    // bool status = await Future.delayed(const Duration(seconds: 2), () => true);
    if (userData!.isPostingKeyLogin) {
      await SignTransactionPostingKeyController().initPollVoteProcess(
        pollId:poll.pollTrxId,
        choices: selection,
        authdata: userData as UserAuthModel<PostingAuthModel>,
        onSuccess: () {
           poll.injectPollVoteCache(userData!.accountName, selection);
           notifyListeners();
        },
        showToast: (message) => context.showSnackBar(message));
    } else if (userData!.isHiveSignerLogin) {
       await SignTransactionHiveSignerController().initPollVoteProcess(
        pollId:poll.pollTrxId,
        choices: selection,
        authdata: userData as UserAuthModel<HiveSignerAuthModel>,
        onSuccess: () {
           poll.injectPollVoteCache(userData!.accountName, selection);
           notifyListeners();
        },
        showToast: (message) =>  context.showSnackBar(message));
    } else {
          SignTransactionNavigationModel navigationData =
        SignTransactionNavigationModel(
            transactionType: SignTransactionType.pollvote,
            author: userData!.accountName,
            pollId: poll.pollTrxId,
            choices: selection,
            ishiveKeyChainMethod: true);
    context.pushNamed(Routes.hiveSignTransactionView, extra: navigationData)
        .then((value) {
      if (value != null) {
        poll.injectPollVoteCache(userData!.accountName, selection);
           notifyListeners();
      }
    });
    }

    return true;
  }

  List<int> userVotedIds(String author, String permlink) =>
      _pollMap[_getLocalPollKey(author, permlink)]
          ?.userVotedIds(userData!.accountName) ??
      [];

  PollModel? getPollData(String author, String permlink) =>
      _pollMap[_getLocalPollKey(author, permlink)];

  String _getLocalPollKey(String author, String permlink) {
    return "$author/$permlink";
  }
}
