// ignore_for_file: constant_identifier_names

enum ResponseStatus { success, failed, unknown }

enum ViewState { loading, data, empty, error }

enum AccountPostType { blog, posts, comments, replies }

enum ThreadFeedType {all,ecency,peakd,liketu,leo}

enum BookmarkType {thread}

enum SocketType {connected,authWait,authAck,authNack,signWait,signAck,signNack,signErr}

enum SocketInputType {auth_req,sign_req}

enum AuthType {hiveKeyChain, hiveAuth, postingKey, hiveSign}

enum TransactionState {loading,qr,redirection}

enum SignTransactionType {comment,vote,mute, pollvote}

enum BroadCastType {vote,comment,custom_json}

enum FollowType { followers, following }

String enumToString(Object o) => o.toString().split('.').last;

T enumFromString<T>(String key, List<T> values, {T? defaultValue}) {
  try {
    return values.firstWhere(
      (element) =>
          key.toLowerCase() == enumToString(element as Object).toLowerCase(),
    );
  } catch (e) {
    if (defaultValue == null) {
      throw 'Please assign default enum value incase theres a error';
    }
    return defaultValue;
  }
}
