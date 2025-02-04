import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class ConnectivityEvent {}

class ConnectivityStatusChanged extends ConnectivityEvent {
  final ConnectivityResult status;
  ConnectivityStatusChanged(this.status);
}

// States
abstract class ConnectivityState {
  ConnectivityResult get status;
}

class ConnectivityInitial extends ConnectivityState {
  @override
  ConnectivityResult get status => ConnectivityResult.none;
}

class ConnectivityConnected extends ConnectivityState {
  final ConnectivityResult connectionType;
  ConnectivityConnected(this.connectionType);

  @override
  ConnectivityResult get status => connectionType;
}

class ConnectivityDisconnected extends ConnectivityState {
  @override
  ConnectivityResult get status => ConnectivityResult.none;
}

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  late final StreamSubscription<List<ConnectivityResult>>
      _connectivitySubscription;

  ConnectivityBloc() : super(ConnectivityInitial()) {
    on<ConnectivityStatusChanged>(_onConnectivityStatusChanged);

    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> statuses) {
      final status = statuses.first;
      add(ConnectivityStatusChanged(status));
    });
  }

  void _onConnectivityStatusChanged(
    ConnectivityStatusChanged event,
    Emitter<ConnectivityState> emit,
  ) {
    switch (event.status) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.ethernet:
      case ConnectivityResult.vpn:
        emit(ConnectivityConnected(event.status));
        break;
      case ConnectivityResult.bluetooth:
      case ConnectivityResult.none:
      case ConnectivityResult.other:
        emit(ConnectivityDisconnected());
        break;
    }
  }

  @override
  Future<void> close() {
    _connectivitySubscription.cancel();
    return super.close();
  }
}
