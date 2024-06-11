import 'package:waves/core/socket/models/socket_response.dart';
import 'package:waves/core/providers/transaction_listeners_providers.dart';

class SocketConnectionAction {
  static void call(SocketResponse data, TransactionListenersProvider provider) {
    provider.timeOutValueListener.value = data.value as int;
  }
}
