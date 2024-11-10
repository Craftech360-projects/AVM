import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'connection_event.dart';
part 'connection_state.dart';

class WebSocketBloc extends Bloc<WebSocketEvent, WebSocketState> {
  final Queue<List<int>> _messageQueue = Queue<List<int>>();
  WebSocketChannel? _channel;
  late final StreamSubscription _internetStatusSubscription;
  StreamSubscription? _messageSubscription;

  WebSocketBloc() : super(WebSocketState.initial()) {
    on<ConnectWebSocket>(_onConnectWebSocket);
    on<DisconnectWebSocket>(_onDisconnectWebSocket);
    on<SendMessageWebSocket>(_onSendMessageWebSocket);
    on<_InternetStatusChanged>(_onInternetStatusChanged);
    on<WebSocketMessageReceived>(_onWebsocketMessageReceived);

    // Listen to internet status changes
    _internetStatusSubscription =
        InternetConnection().onStatusChange.listen((InternetStatus status) {
      add(_InternetStatusChanged(status));
    });

    // Listening incoming WebSocket messages
    // _messageSubscription = _messageController.stream.listen((message) {
    //   print('Received WebSocket message: $message');
    //   // add(WebSocketMessageReceived(message));
    // });
  }

  void _onWebsocketMessageReceived(
      WebSocketMessageReceived event, Emitter<WebSocketState> emit) {
    emit(state.copyWith(lastMessage: event.message));
  }

  void _onConnectWebSocket(
      ConnectWebSocket event, Emitter<WebSocketState> emit) {
    if (state.internetStatus == InternetConnectionStatus.connected &&
        state.connectionState != WebSocketConnectionState.connected) {
      _connectWebSocket();
      emit(state.copyWith(connectionState: WebSocketConnectionState.connected));
    }
  }

  void _onDisconnectWebSocket(
      DisconnectWebSocket event, Emitter<WebSocketState> emit) {
    _disconnectWebSocket();
    emit(
        state.copyWith(connectionState: WebSocketConnectionState.notConnected));
  }

  void _onSendMessageWebSocket(
      SendMessageWebSocket event, Emitter<WebSocketState> emit) {
    if (state.connectionState == WebSocketConnectionState.connected) {
      _channel?.sink.add(event.message); // Send List<int> directly
    } else {
      _messageQueue.add(event.message);
      print('WebSocket is not connected. Queuing message.');
    }
  }

  void _onInternetStatusChanged(
      _InternetStatusChanged event, Emitter<WebSocketState> emit) {
    if (event.status == InternetStatus.disconnected) {
      _disconnectWebSocket();
      emit(state.copyWith(
        connectionState: WebSocketConnectionState.notConnected,
        internetStatus: InternetConnectionStatus.disconnected,
      ));
    } else {
      _connectWebSocket();
      emit(state.copyWith(
        connectionState: WebSocketConnectionState.connected,
        internetStatus: InternetConnectionStatus.connected,
      ));
    }
  }

  void _connectWebSocket() async {
    try {
      print('print1--');
      _channel = IOWebSocketChannel.connect(
        'wss://api.deepgram.com/v1/listen?encoding=pcm8&sample_rate=8000&channels=1',
        headers: {
          'Authorization': 'Token e19942922008143bf76a75cb75b92853faa0b0da',
          'Content-Type': 'audio/raw',
        },
      );
      print('print2--');
      await _channel!.ready;
      _channel?.stream.listen(
        (message) => print('Received message: $message'),
        onError: (error) => print('Error: $error'),
        onDone: () => print('Connection closed'),
      );
      _sendQueuedMessages();
    } catch (e) {
      print('WebSocket connection failed: $e');
    }
  }

  void _disconnectWebSocket() {
    _channel?.sink.close();
    _channel = null;
  }

  void _sendQueuedMessages() {
    while (_messageQueue.isNotEmpty) {
      final message = _messageQueue.removeFirst();
      _channel?.sink.add(message); // Send List<int> directly
      print("Sent queued message: $message");
    }
  }

  @override
  Future<void> close() {
    // _messageController.close();
    _internetStatusSubscription.cancel();
    _messageSubscription?.cancel();
    _disconnectWebSocket();
    return super.close();
  }
}
// class WebSocketBloc extends Bloc<WebSocketEvent, WebSocketState> {
//   final StreamController<String> _messageController;
//   final Queue<String> _messageQueue = Queue<String>();
//   WebSocketChannel? _channel;
//   late final StreamSubscription _internetStatusSubscription;
//   StreamSubscription? _messageSubscription;

//   WebSocketBloc()
//       : _messageController = StreamController<String>(),
//         super(WebSocketState.initial()) {
//     on<ConnectWebSocket>(_onConnectWebSocket);
//     on<DisconnectWebSocket>(_onDisconnectWebSocket);
//     on<SendMessageWebSocket>(_onSendMessageWebSocket);
//     on<_InternetStatusChanged>(_onInternetStatusChanged);
//     on<WebSocketMessageReceived>(_onWebsocketMessageReceived);

//     // Listen to internet status changes
//     _internetStatusSubscription =
//         InternetConnection().onStatusChange.listen((InternetStatus status) {
//       add(_InternetStatusChanged(status));
//     });

//     // Listening incoming WebSocket messages
//     _messageSubscription = _messageController.stream.listen((message) {
//       print('Received WebSocket message: $message');
//       add(WebSocketMessageReceived(message));
//     });
//   }

//   void _onWebsocketMessageReceived(
//       WebSocketMessageReceived event, Emitter<WebSocketState> emit) {
//     emit(state.copyWith(lastMessage: event.message));
//   }

//   void _onConnectWebSocket(
//       ConnectWebSocket event, Emitter<WebSocketState> emit) {
//     if (state.internetStatus == InternetConnectionStatus.connected &&
//         state.connectionState != WebSocketConnectionState.connected) {
//       _connectWebSocket();
//       emit(state.copyWith(connectionState: WebSocketConnectionState.connected));
//     }
//   }

//   void _onDisconnectWebSocket(
//       DisconnectWebSocket event, Emitter<WebSocketState> emit) {
//     _disconnectWebSocket();
//     emit(
//         state.copyWith(connectionState: WebSocketConnectionState.notConnected));
//   }

//   void _onSendMessageWebSocket(
//       SendMessageWebSocket event, Emitter<WebSocketState> emit) {
//     if (state.connectionState == WebSocketConnectionState.connected) {
//       _channel?.sink
//           .add(event.message);
//     } else {
//       _messageQueue.add(event.message);
//       print('WebSocket is not connected. Queuing message.');
//     }
//   }

//   void _onInternetStatusChanged(
//       _InternetStatusChanged event, Emitter<WebSocketState> emit) {
//     if (event.status == InternetStatus.disconnected) {
//       _disconnectWebSocket();
//       emit(state.copyWith(
//         connectionState: WebSocketConnectionState.notConnected,
//         internetStatus: InternetConnectionStatus.disconnected,
//       ));
//     } else {
//       _connectWebSocket();
//       emit(state.copyWith(
//         connectionState: WebSocketConnectionState.connected,
//         internetStatus: InternetConnectionStatus.connected,
//       ));
//     }
//   }

//   void _connectWebSocket() {
//     if (_channel != null) return;

//     _channel = WebSocketChannel.connect(
//       Uri.parse('wss://api.deepgram.com/v1/listen?encoding=pcm8&sample_rate=8000&channels=1'),
//       // Uri.parse('wss://echo.websocket.events'),
//     );

//     _channel!.stream.listen(
//       (message) => _messageController.add(message),
//       onDone: () {
//         print('WebSocket connection closed');
//         _channel = null;
//       },
//       onError: (error) {
//         print('WebSocket error: $error');
//         _channel = null;
//       },

//     );
//     _sendQueuedMessages();
//   }

//   void _disconnectWebSocket() {
//     _channel?.sink.close();
//     _channel = null;
//   }

//   void _sendQueuedMessages() {
//     while (_messageQueue.isNotEmpty) {
//       final message = _messageQueue.removeFirst();
//       _channel?.sink.add(message);
//       print("Sent queued message: $message");
//     }
//   }

//   @override
//   Future<void> close() {
//     _messageController.close();
//     _internetStatusSubscription.cancel();
//     _messageSubscription?.cancel();
//     _disconnectWebSocket();
//     return super.close();
//   }
// }
List<int> rawAudioData = [
  89,
  106,
  0,
  55,
  0,
  255,
  255,
  56,
  0,
  58,
  0,
  69,
  0,
  56,
  0,
  61,
  0,
  50,
  0,
  23,
  0,
  75,
  0,
  56,
  0,
  78,
  0,
  45,
  0,
  70,
  0,
  55,
  0,
  78,
  0,
  78,
  0,
  75,
  0,
  98,
  0,
  63,
  0,
  63,
  0,
  82,
  0,
  85,
  0,
  88,
  0,
  88,
  0,
  90,
  0,
  103,
  0,
  80,
  0,
  79,
  0,
  89,
  0,
  94,
  0,
  107,
  0,
  107,
  0,
  101,
  0,
  83,
  0,
  127,
  0,
  85,
  0,
  62,
  0,
  93,
  0,
  89,
  0,
  99,
  0,
  119,
  0,
  119,
  0,
  109,
  0,
  109,
  0,
  121,
  0,
  102,
  0,
  144,
  0,
  124,
  0,
  145,
  0,
  157,
  0,
  135,
  0,
  189,
  0,
  146,
  0,
  133,
  0,
  140,
  0,
  177,
  0,
  152,
  0,
  168,
  0,
  189,
  0,
  190,
  0,
  183,
  0,
  191,
  0,
  177,
  0,
  203,
  0,
  225,
  0,
  212,
  0,
  210,
  0,
  201,
  0,
  247,
  0,
  197,
  0,
  212,
  0,
  204,
  0,
  220,
  0,
  218,
  0,
  231,
  0,
  253,
  0,
  227,
  0,
  244,
  0,
  224,
  0
];
