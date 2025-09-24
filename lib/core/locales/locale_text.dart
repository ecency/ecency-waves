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
  static String get notifications => "notifications".tr();
  static String get report => "report".tr();
  static String get copyContent => "copy_content".tr();
  static String get contentCopied => "content_copied".tr();
  static String get translate => "translate".tr();
  static String get autoDetectLanguage => "auto_detect_language".tr();
  static String get sourceLanguage => "source_language".tr();
  static String get targetLanguage => "target_language".tr();
  static String get originalText => "original_text".tr();
  static String get translatedText => "translated_text".tr();
  static String get translationUnavailable => "translation_unavailable".tr();
  static String get translationError => "translation_error".tr();
  static String detectedLanguage(String language, String confidence) =>
      "detected_language".tr(args: [language, confidence]);
  static String get reportSuccess => "report_success".tr();
  static String get reportFailed => "report_failed".tr();
  static String get reportContentConfirmation =>
      "report_content_confirmation".tr();
  static String get myWaves => "my_waves".tr();
  static String get explore => "explore".tr();
  static String get darkMode => "dark_mode".tr();
  static String get lightMode => "light_mode".tr();
  static String get settings => "settings".tr();
  static String get language => "language".tr();
  static String get defaultFeed => "default_feed".tr();
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
  static String get removeAccount => "remove_account".tr();
  static String get remove => "remove".tr();
  static String removeAccountConfirmation(String account) =>
      "remove_account_confirmation".tr(args: [account]);
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
  static String get loginWithPostingKey => "login_with_posting_key".tr();
  static String get loginWithEcency => "login_with_ecency".tr();
  static String get loginWithSigner => "login_with_signer".tr();
  static String get loginWithKeychain => "login_with_keychain".tr();
  static String get loginWithAuth => "login_with_auth".tr();
  static String get signWithSigner => "sign_with_signer".tr();
  static String get signWithKeychain => "sign_with_keychain".tr();
  static String get signWithEcency => "sign_with_ecency".tr();
  static String get signWithAuth => "sign_with_auth".tr();
  static String get continueInEcency => "continue_in_ecency".tr();
  static String get pleaseEnterTheUsername => "please_enter_the_username".tr();
  static String get pleaseEnterThePostingKey =>
      "please_enter_the_posting_key".tr();
  static String get username => "username".tr();
  static String get postingKey => "posting_key".tr();
  static String get noThreadsFound => "no_threads_found".tr();

  //polls related texts
  static String ageLimit(int days) => "age_limit".tr(args: [days.toString()]);
  static String get interpretationToken => "interpretation_token".tr();
  static String maxChoices(int choices) =>
      "max_choices".tr(args: [choices.toString()]);
  static String get pollVote => "poll_vote".tr();
  static String get pollVoted => "poll_voted".tr();
  static String get pollRevote => "poll_revote".tr();
  static String get theAccountDoesntExist => "the_account_doesnt_exist".tr();

  static String get tags => "tags".tr();
  static String get users => "users".tr();
  static String get hashtags => "hashtags".tr();
  static String get error => "error".tr();
  static String get noDataFound => "no_data_found".tr();
  static String get signUp => "sign_up".tr();
  static String get dontHaveAnAccount => "dont_have_an_account".tr();
  static String get privateKeyLogin => "privatekey_login".tr();
  static String get postingPrivateKey => "posting_private_key".tr();
  static String get post => "post".tr();
  static String replyToUser(String user) => "reply_to_user".tr(args: [user]);
  static String get whatsHappening => "whats_happening".tr();
  static String get replyEngageExchangeIdeas =>
      "reply_engage_exchange_ideas".tr();
  static String get threadTypeEcency => "thread_type_ecency".tr();
  static String get threadTypePeakd => "thread_type_peakd".tr();
  static String get threadTypeLiketu => "thread_type_liketu".tr();
  static String get threadTypeLeo => "thread_type_leo".tr();
  static String get threadTypeAll => "thread_type_all".tr();
  static String get search => "search".tr();
  static String get searchUsersOrHashtags =>
      "search_users_or_hashtags".tr();
  static String get typeToSearchForUsers =>
      "type_to_search_for_users".tr();
  static String get unableToLoadUsers =>
      "unable_to_load_users".tr();
  static String get noUsersFound => "no_users_found".tr();
  static String get typeToSearchForHashtags =>
      "type_to_search_for_hashtags".tr();
  static String get unableToLoadHashtags =>
      "unable_to_load_hashtags".tr();
  static String get noHashtagsFound => "no_hashtags_found".tr();
  static String get loadNewContent => "load_new_content".tr();
  static String get noRepliesFound => "no_replies_found".tr();
  static String get noContentFound => "no_content_found".tr();
  static String get noBookmarksFound => "no_bookmarks_found".tr();
  static String get noNotificationsFound => "no_notifications_found".tr();
  static String notificationsFollowedYou(String user) =>
      "notifications_followed_you".tr(args: [user]);
  static String notificationsMentionedYou(String user) =>
      "notifications_mentioned_you".tr(args: [user]);
  static String notificationsRepliedToYou(String user) =>
      "notifications_replied_to_you".tr(args: [user]);
  static String notificationsDelegatedToYou(String user, String amount) =>
      "notifications_delegated_to_you".tr(args: [user, amount]);
  static String notificationsFromUser(String type, String user) =>
      "notifications_from_user".tr(args: [type, user]);
  static String notificationsVotedOn(String user, String content) =>
      "notifications_voted_on".tr(args: [user, content]);
  static String notificationsTransferReceived(String user, String amount) =>
      "notifications_transfer_received".tr(args: [user, amount]);
  static String versionInfo(String version, String buildNumber) =>
      "version_info".tr(args: [version, buildNumber]);
}
