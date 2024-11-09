import 'dart:async';
import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'connection_event.dart';
part 'connection_state.dart';

class WebSocketBloc extends Bloc<WebSocketEvent, WebSocketState> {
  final StreamController<String> _messageController;
  final Queue<String> _messageQueue = Queue<String>(); 
  WebSocketChannel? _channel;
  late final StreamSubscription _internetStatusSubscription;
  StreamSubscription? _messageSubscription;

  WebSocketBloc()
      : _messageController = StreamController<String>(),
        super(WebSocketState.initial()) {
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
    _messageSubscription = _messageController.stream.listen((message) {
      print('Received WebSocket message: $message');
      add(WebSocketMessageReceived(message));
    });
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
      _channel?.sink
          .add(event.message); 
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

  void _connectWebSocket() {
    if (_channel != null) return;

    _channel = WebSocketChannel.connect(
      Uri.parse('wss://echo.websocket.events'),
    );

    
    _channel!.stream.listen(
      (message) => _messageController.add(message),
      onDone: () {
        print('WebSocket connection closed');
        _channel = null;
      },
      onError: (error) {
        print('WebSocket error: $error');
        _channel = null;
      },

    );
    _sendQueuedMessages();
  }

  void _disconnectWebSocket() {
    _channel?.sink.close();
    _channel = null;
  }


  void _sendQueuedMessages() {
    while (_messageQueue.isNotEmpty) {
      final message = _messageQueue.removeFirst();
      _channel?.sink.add(message);
      print("Sent queued message: $message");
    }
  }

  @override
  Future<void> close() {
    _messageController.close();
    _internetStatusSubscription.cancel();
    _messageSubscription?.cancel();
    _disconnectWebSocket();
    return super.close();
  }
}
