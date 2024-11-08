import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:friend_private/src/features/live_transcript/presentation/bloc/connection/connection_bloc.dart';

class WebSocketTestPage extends StatelessWidget {
  static const String name = 'wsPage';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WebSocketBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('WebSocket Test Page'),
        ),
        body: WebSocketContent(),
      ),
    );
  }
}

class WebSocketContent extends StatelessWidget {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final webSocketBloc = context.read<WebSocketBloc>();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BlocBuilder<WebSocketBloc, WebSocketState>(
            builder: (context, state) {
              print('--${state.toString()}');
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Connection State: ${state.connectionState}',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Internet Status: ${state.internetStatus}',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
         
                  Text(
                    'Latest Message: ${state.lastMessage}',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _messageController,
            decoration: InputDecoration(labelText: 'Enter message'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              final message = _messageController.text;
              if (message.isNotEmpty) {
                webSocketBloc.add(SendMessageWebSocket(message));
                _messageController.clear();
              }
            },
            child: Text('Send Message'),
          ),
        ],
      ),
    );
  }
}
