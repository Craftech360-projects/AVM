// part of 'connection_bloc.dart';

// enum WebSocketConnectionState {
//   notConnected,
//   connecting,
//   connected,
//   failed,
//   closed,
//   error
// }

// enum InternetConnectionStatus { connected, disconnected }

// enum WebSocketReconnectionStatus { none, reconnecting, attemptsExceeded }

// class WebSocketState {
//   final WebSocketConnectionState connectionState;
//   final InternetConnectionStatus internetStatus;
//   final WebSocketReconnectionStatus reconnectionStatus;
//   final int reconnectionAttempts;
//   final String lastMessage;

//   WebSocketState({
//     required this.connectionState,
//     required this.internetStatus,
//     required this.reconnectionStatus,
//     this.reconnectionAttempts = 0,
//     this.lastMessage = '',
//   });
//   factory WebSocketState.initial() => WebSocketState(
//         connectionState: WebSocketConnectionState.notConnected,
//         internetStatus: InternetConnectionStatus.disconnected,
//         reconnectionStatus: WebSocketReconnectionStatus.none,
//       );
//   WebSocketState copyWith({
//     WebSocketConnectionState? connectionState,
//     InternetConnectionStatus? internetStatus,
//     WebSocketReconnectionStatus? reconnectionStatus,
//     int? reconnectionAttempts,
//     String? lastMessage,
//   }) {
//     print('last message $lastMessage');
//     return WebSocketState(
//       connectionState: connectionState ?? this.connectionState,
//       internetStatus: internetStatus ?? this.internetStatus,
//       reconnectionStatus: reconnectionStatus ?? this.reconnectionStatus,
//       reconnectionAttempts: reconnectionAttempts ?? this.reconnectionAttempts,
//       lastMessage: lastMessage ?? this.lastMessage,
//     );
//   }
// }
