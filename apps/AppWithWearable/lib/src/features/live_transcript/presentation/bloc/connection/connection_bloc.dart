import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'dart:typed_data';
import 'dart:convert';

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
    // state.internetStatus == InternetConnectionStatus.connected &&
    if (state.connectionState != WebSocketConnectionState.connected) {
      _connectWebSocket();
      print("Connecting to WebSocket and updating state...");
      emit(state.copyWith(connectionState: WebSocketConnectionState.connected));
    } else {
      print("InternetConnectionStatus.connected, ${state.internetStatus}");
      print("WebSocketConnectionState.connected, ${state.connectionState}");
      print("Skipped connection, already connected or no internet.");
      //_connectWebSocket();
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
      print(">>>>>>>jj>>>>>>>. ${event.message}");

      _channel?.sink.add(event.message); // Send List<int> directly
      // Send List<int> directly
    } else {
      // _messageQueue.add(event.message);
      // print('WebSocket is not connected. Queuing message.');
    }
  }

  void _onInternetStatusChanged(
      _InternetStatusChanged event, Emitter<WebSocketState> emit) {
    print("internet status changed");
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

  // void _connectWebSocket({int retryCount = 3}) async {
  //   const String language = 'en-US';
  //   const int sampleRate = 8000;
  //   const String codec = 'pcm8';
  //   const int channels = 1;
  //   debugPrint('Connecting to WebSocket URI:');
  //   try {
  //     const int sampleRate = 8000;
  //     try {
  //       _channel = IOWebSocketChannel.connect(
  //         Uri.parse(
  //             // 'wss://api.deepgram.com/v1/listen?encoding=linear16&sample_rate=8000&channels=1'
  //             'ws://efef-124-40-247-18.ngrok-free.app?service=service3&language=${language}&sample_rate=${sampleRate}&codec=${codec}&channels=${channels}'),
  //         headers: {
  //           'Authorization': 'Token e19942922008143bf76a75cb75b92853faa0b0da',
  //           'Content-Type': 'audio/raw',
  //         },
  //       );
  //       await _channel!.ready;
  //       print('WebSocket connected successfully');
  //     } catch (e) {
  //       print('WebSocket connection failed: $e');
  //     }
  //     print('success');
  //     // Start KeepAlive timer
  //     _startKeepAlive();
  //     // initiateBytesStreamingProcessing();
  //     // Listen for messages from the WebSocket
  //     _messageSubscription = _channel?.stream.listen(
  //       (event) {
  //         print(
  //           ">>>>>>> ,${event.toString()}",
  //         );
  //         try {
  //           final data = jsonDecode(event);
  //           if (data['type'] == 'Results') {
  //             print(data);
  //             final alternatives = data['channel']['alternatives'];
  //             if (alternatives is List && alternatives.isNotEmpty) {
  //               final transcript = alternatives[0]['transcript'];
  //               if (transcript is String && transcript.isNotEmpty) {
  //                 final segment = TranscriptSegment(
  //                   text: transcript,
  //                   speaker: '1',
  //                   isUser: false,
  //                   start: (data['start'] as double?) ?? 0.0,
  //                   end: ((data['start'] as double?) ?? 0.0) +
  //                       ((data['duration'] as double?) ?? 0.0),
  //                 );
  //                 print(segment);
  //                 // onMessageReceived([segment]);
  //                 // lastAudioTime = DateTime.now();
  //               }
  //             }
  //           } else {
  //             debugPrint('Unknown event type: ${data['type']}');
  //           }
  //         } catch (e) {
  //           debugPrint('Error processing event: $e');
  //           debugPrint('Raw event: $event');
  //         }
  //       },
  //       onError: (error) {
  //         debugPrint('WebSocket error: $error');
  //         //onWebsocketConnectionError(error);
  //       },
  //       onDone: () {
  //         debugPrint('WebSocket connection closed');
  //         //  onWebsocketConnectionClosed(channel.closeCode, channel.closeReason);
  //         //stopKeepAlive();
  //       },
  //     );

  //     _sendQueuedMessages();
  //   } catch (e) {
  //     print('WebSocket connection failed: $e');
  //   }
  // }

  void _connectWebSocket({int retryCount = 3}) async {
    const String language = 'en-US';
    const int sampleRate = 8000;
    const String codec = 'pcm8';
    const int channels = 1;

    int attempts = 0;
    bool isConnected = false;

    while (attempts < retryCount && !isConnected) {
      attempts++;
      debugPrint('Attempt $attempts: Connecting to WebSocket URI...');
      if (_channel != null) {
        debugPrint('WebSocket is already connected or connecting.');
        return;
      }
      try {
        print("here");
        _channel = IOWebSocketChannel.connect(
          Uri.parse(
              'wss://api.deepgram.com/v1/listen?encoding=linear16&sample_rate=8000&channels=1}'),
          // Uri.parse('ws://3ebd-124-40-247-18.ngrok-free.app?service=service3&language=${language}&sample_rate=${sampleRate}&codec=${codec}&channels=${channels}'),
          headers: {
            'Authorization': 'Token e19942922008143bf76a75cb75b92853faa0b0da',
            'Content-Type': 'audio/raw',
          },
        );
        await _channel!.ready;
        print('WebSocket connected successfully');
        isConnected = true;

        // Start KeepAlive timer
        _startKeepAlive();

        // Listen for messages from the WebSocket
        _messageSubscription = _channel?.stream.listen(
          (event) {
            print(">>>>>>> ,${event.toString()}");
            try {
              final data = jsonDecode(event);
              if (data['type'] == 'Results') {
                print(data);
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
                    // Handle the received segment
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
          },
          onDone: () {
            debugPrint('WebSocket connection closed');
          },
        );

        //  _sendQueuedMessages(); // Send any queued messages if connection is successful
      } catch (e) {
        print('WebSocket connection failed on attempt $attempts: $e');
        if (attempts < retryCount) {
          await Future.delayed(const Duration(seconds: 5));
          debugPrint('Retrying WebSocket connection...');
        } else {
          debugPrint('Max retry attempts reached. Giving up.');
        }
      }
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
        //     print('Sent KeepAlive message');
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

