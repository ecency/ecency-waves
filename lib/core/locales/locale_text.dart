import 'package:easy_localization/easy_localization.dart';

class LocaleText {
  static String isAddedToYourBookmarks(String content) =>
      "is_added_to_your_bookmarks".tr(args: [content]);
  static String isRemovedToYourBookmarks(String content) =>
      "is_removed_from_your_bookmarks".tr(args: [content]);
  static String successfullLoginMessage(String content) =>
      "successfull_login_message".tr(args: [content]);
  static String get notLoggedIn => "not_logged_in".tr();
  static String get pleaseLoginFirst => "please_login_first".tr();
  static String get cancel => "cancel".tr();
  static String get login => "login".tr();
  static String get bookmarks => "bookmarks".tr();
  static String get darkMode => "dark_mode".tr();
  static String get lightMode => "light_mode".tr();
  static String get deleteAccount => "delete_account".tr();
  static String get logOut => "log_out".tr();
  static String get scanTapQRCode => "scan_tap_qr_code".tr();
  static String get authorizeThisRequestWithKeyChainForHiveApp =>
      "authorize_this_request_with_keychain_for_hive_app".tr();
  static String get timeoutTimerForHiveAuthQr =>
      "timeout_timer_for_hiveAuth_qr".tr();
  static String get sorryWeAreUnableToReachOurServer =>
      "sorry_we_are_unable_to_reach_our_server".tr();
  static String get tryAgain => "try_again".tr();
  static String get replyCannotBeEmpty => "reply_cannot_be_empty".tr();
  static String get addAComment => "add_a_comment".tr();
  static String get addYourReply => "add_your_reply".tr();
  static String get keyChain => "key_chain".tr();
  static String get hiveAuth => "hive_auth".tr();
  static String get continueUsing => "continue_using".tr();
  static String get upvote => "upvote".tr();
  static String get tip => "tip".tr();
  static String get activePrivateKey => "active_private_key".tr();
  static String get tipEnterActiveKey => "tip_enter_active_key".tr();
  static String get tipActiveKeyRequired => "tip_active_key_required".tr();
  static String tipActiveKeyInstructions(String account) =>
      "tip_active_key_instructions".tr(args: [account]);
  static String get done => "done".tr();
  static String get addAccount => "add_account".tr();
  static String get switchAccount => "switch_account".tr();
  static String get emDefaultMessage => "em_default_message".tr();
  static String get emHiveAuthTokenMessage => "em_hive_auth_token_message".tr();
  static String get emHiveAuthAppNotFound => "em_hiveauth_app_not_found".tr();
  static String get emAuthNackMessage => "em_auth_nack_message".tr();
  static String get emPostingLoginMessage => "em_posting_login_message".tr();
  static String get emCommentDeclineMessage =>
      "em_comment_decline_message".tr();
  static String get emTimeOutMessage => "em_time_out_message".tr();
  static String get emVoteFailureMessage => "em_vote_failure_message".tr();
  static String get smHiveAuthLoginMessage => "sm_hive_auth_login_message".tr();
  static String get smPostingLoginMessage => "sm_posting_login_message".tr();
  static String get smCommentPublishMessage =>
      "sm_comment_publish_message".tr();
  static String get smVoteSuccessMessage => "sm_vote_success_message".tr();
  static String get smTipSuccessMessage => "sm_tip_success_message".tr();
  static String get emTipFailureMessage => "em_tip_failure_message".tr();
  static String get tipRequiresAuth => "tip_requires_auth".tr();
  static String get tipKeychainNotFound => "tip_keychain_not_found".tr();
  static String get tipEcencyNotFound => "tip_ecency_not_found".tr();
  static String get ecencyAppNotFound => "ecency_app_not_found".tr();
  static String get ecencyLoginFailed => "ecency_login_failed".tr();
  static String get selectTipAmount => "select_tip_amount".tr();
  static String get selectToken => "select_token".tr();
  static String get somethingWentWrong => "something_went_wrong".tr();
  static const String loginWithPostingKey = "login_with_posting_key";
  static const String loginWithEcency = "login_with_ecency";
  static const String continueInEcency = "continue_in_ecency";
  static const String pleaseEnterTheUsername = "please_enter_the_username";
  static const String pleaseEnterThePostingKey = "please_enter_the_posting_key";
  static const String username = "username";
  static const String postingKey = "posting_key";
  static const String noThreadsFound = "no_threads_found";

  //polls related texts
  static String ageLimit(int days) => "age_limit".tr(args: [days.toString()]);
  static String get interpretationToken => "interpretation_token".tr();
  static String maxChoices(int choices) =>
      "max_choices".tr(args: [choices.toString()]);
  static String get pollVote => "poll_vote".tr();
  static String get pollVoted => "poll_voted".tr();
  static String get pollRevote => "poll_revote".tr();
  static String get theAccountDoesntExist => "the_account_doesnt_exist";


}
