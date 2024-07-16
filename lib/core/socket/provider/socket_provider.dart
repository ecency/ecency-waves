import 'dart:async';
import 'dart:convert';
import 'package:waves/core/socket/models/socket_response.dart';
import 'package:waves/core/utilities/constants/server_constants.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/core/utilities/save_convert.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SocketProvider {
  late WebSocketChannel _socket;
  final String _connectedServer = socketServer;
  int timeOutValue = 30;

  final _controller = StreamController<SocketResponse>.broadcast();
  Stream<SocketResponse> get stream => _controller.stream;

  SocketProvider() {
    _socket = WebSocketChannel.connect(
      Uri.parse(_connectedServer),
    );
    _socket.stream.listen((message) {
      var map = json.decode(message) as Map<String, dynamic>;
      var command = map['cmd'] as String?;
      if (command != null && command.isNotEmpty) {
        switch (command) {
          case "connected":
            timeOutValue = map['timeout'] as int? ?? 30;
            _controller.add(SocketResponse(
                type: SocketType.connected,
                value: map['timeout'] as int? ?? 30));
            break;
          case "auth_wait":
            String uid = asString(map, 'uuid');
            _controller
                .add(SocketResponse(type: SocketType.authWait, value: uid));
            break;
          case "auth_ack":
            String encryptedData = map['data'] as String? ?? '';
            _controller.add(
                SocketResponse(type: SocketType.authAck, value: encryptedData));
            break;
          case "auth_nack":
            _controller
                .add(SocketResponse(type: SocketType.authNack, value: null));
            break;
          case "sign_wait":
            String uid = asString(map, 'uuid');
            _controller
                .add(SocketResponse(type: SocketType.signWait, value: uid));
          case "sign_ack":
            _controller
                .add(SocketResponse(type: SocketType.signAck, value: null));
          case "sign_nack":
            _controller
                .add(SocketResponse(type: SocketType.signNack, value: null));
          case "sign_err":
            _controller
                .add(SocketResponse(type: SocketType.signErr, value: null));
        }
      }
    }, onError: (e) => _reconnect(), onDone: _reconnect, cancelOnError: true);
  }

  Future<void> _reconnect() async {
    await Future.delayed(const Duration(seconds: 2));
    _socket = WebSocketChannel.connect(
      Uri.parse(_connectedServer),
    );
  }

  void sendDataToSocket(String jsonString) {
    _socket.sink.add(jsonString);
  }

  void dispose() {
    _controller.close();
  }
}
