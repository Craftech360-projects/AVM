import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:friend_private/backend/database/transcript_segment.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'connection_event.dart';
part 'connection_state.dart';

class WebSocketBloc extends Bloc<WebSocketEvent, WebSocketState> {
  final Queue<List<int>> _messageQueue = Queue<List<int>>();
  WebSocketChannel? _channel;
  Timer? _keepAliveTimer;
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
      print("Connecting to WebSocket and updating state...");
      emit(state.copyWith(connectionState: WebSocketConnectionState.connected));
    } else {
      print("Skipped connection, already connected or no internet.");
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
    List<int> sampleAudioData = [
      0,
      34,
      12,
      88,
      44,
      76,
      122,
      34,
      0,
      128,
      255,
      200,
      111,
      55,
      22,
      144,
      176,
      255,
      32,
      12,
      78,
      99,
      200,
      101,
      120,
      220,
      15,
      78,
      134,
      167,
      90,
      34,
      56,
      89,
      0,
      125,
      130,
      156,
      45,
      77,
      98,
      201,
      222,
      178,
      167,
      33,
      0,
      75,
      255,
      199,
      101,
      111,
      124,
      90,
      55,
      233,
      145,
      200,
      88,
      77,
      122,
      95,
      10,
      66
    ];

    if (state.connectionState == WebSocketConnectionState.connected) {
      // _channel?.sink.add(event.message); // Send List<int> directly
      _channel?.sink.add(sampleAudioData); // Send List<int> directly
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
      _channel = IOWebSocketChannel.connect(
        'wss://api.deepgram.com/v1/listen?encoding=linear16&sample_rate=8000&channels=1',
        headers: {
          'Authorization': 'Token e19942922008143bf76a75cb75b92853faa0b0da',
          'Content-Type': 'audio/raw',
        },
      );
      await _channel!.ready;

      // Start KeepAlive timer
      _startKeepAlive();

      // Listen for messages from the WebSocket
      _messageSubscription = _channel?.stream.listen(
        (event) {
          try {
            final data = jsonDecode(event);
            if (data['type'] == 'Results') {
              print('data received in bloc-$data');
              final alternatives = data['channel']['alternatives'];
              if (alternatives is List && alternatives.isNotEmpty) {
                final transcript = alternatives[0]['transcript'];
                if (transcript is String && transcript.isNotEmpty) {
                  final segment = TranscriptSegment(
                    text: transcript,
                    speaker: '1',
                    isUser: false,
                    start: (data['start'] as double?) ?? 0.0,
                    end: ((data['start'] as double?) ?? 0.0) +
                        ((data['duration'] as double?) ?? 0.0),
                  );
                  print(segment);
                  // onMessageReceived([segment]);
                  // lastAudioTime = DateTime.now();
                }
              }
            } else {
              debugPrint('Unknown event type: ${data['type']}');
            }
          } catch (e) {
            debugPrint('Error processing event: $e');
            debugPrint('Raw event: $event');
          }
        },
        onError: (error) {
          debugPrint('WebSocket error: $error');
          //onWebsocketConnectionError(error);
        },
        onDone: () {
          debugPrint('WebSocket connection closed');
          //  onWebsocketConnectionClosed(channel.closeCode, channel.closeReason);
          //stopKeepAlive();
        },
      );

      _sendQueuedMessages();
    } catch (e) {
      print('WebSocket connection failed: $e');
    }
  }

  void _disconnectWebSocket() {
    // Stop the keep-alive timer
    _stopKeepAlive();

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

  // KeepAlive timer functions
  void _startKeepAlive() {
    _keepAliveTimer?.cancel(); // Cancel any existing timer

    // Send a KeepAlive message every 7 seconds
    _keepAliveTimer = Timer.periodic(const Duration(seconds: 7), (timer) {
      if (_channel != null) {
        final keepAliveMsg =
            Uint8List.fromList(utf8.encode(jsonEncode({'type': 'KeepAlive'})));
        _channel!.sink.add(keepAliveMsg);
        print('Sent KeepAlive message');
      } else {
        timer.cancel(); // Stop the timer if the WebSocket is disconnected
      }
    });
  }

  void _stopKeepAlive() {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = null;
  }

  @override
  Future<void> close() {
    _internetStatusSubscription.cancel();
    _messageSubscription?.cancel();
    _disconnectWebSocket();
    return super.close();
  }
}
