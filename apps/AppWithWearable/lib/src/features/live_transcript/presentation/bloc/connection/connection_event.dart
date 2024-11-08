part of 'connection_bloc.dart';

abstract class WebSocketEvent extends Equatable {

  @override
  List<Object?> get props => [];
}

class ConnectWebSocket extends WebSocketEvent {}

class SendMessageWebSocket extends WebSocketEvent {
  final String message;
  SendMessageWebSocket(this.message);
    @override
  List<Object> get props => [message];
}

class WebSocketConnectionSuccess extends WebSocketEvent {}

class WebSocketConnectionFailure extends WebSocketEvent {
  final dynamic error;
  WebSocketConnectionFailure(this.error);
    @override
  List<Object> get props => [error];

}

class WebSocketConnectionClosed extends WebSocketEvent {
  final int? code;
  final String? reason;
  WebSocketConnectionClosed(this.code, this.reason);
   @override
  List<Object?> get props => [reason,code];
}

class WebSocketConnectionError extends WebSocketEvent {
  final dynamic error;
  WebSocketConnectionError(this.error);
     @override
  List<Object?> get props => [error];
}

class WebSocketMessageReceived extends WebSocketEvent {
  final String message;
  WebSocketMessageReceived(this.message);
       @override
  List<Object?> get props => [message];
}

class _InternetStatusChanged extends WebSocketEvent {
  final InternetStatus status;
  _InternetStatusChanged(this.status);
    @override
  List<Object?> get props => [status];
}

class ReconnectionAttempt extends WebSocketEvent {}
class DisconnectWebSocket extends WebSocketEvent{}