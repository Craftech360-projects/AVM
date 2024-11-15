import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:friend_private/src/features/live_transcript/presentation/bloc/connection/connection_bloc.dart';

class WebSocketTestPage extends StatelessWidget {
  static const String name = 'wsPage';

  const WebSocketTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WebSocketBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('WebSocket Test Page'),
        ),
        body: WebSocketContent(),
      ),
    );
  }
}

class WebSocketContent extends StatelessWidget {
  final TextEditingController _messageController = TextEditingController();

  WebSocketContent({super.key});

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
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Internet Status: ${state.internetStatus}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Latest Message: ${state.lastMessage}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _messageController,
            decoration: const InputDecoration(labelText: 'Enter message'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              final message = _messageController.text;
              if (message.isNotEmpty) {
                webSocketBloc.add(SendMessageWebSocket(const [
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
                ]));
                _messageController.clear();
              }
            },
            child: const Text('Send Message'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              webSocketBloc.add(ConnectWebSocket());
            },
            child: const Text('Retry WebSocket Connection'),
          ),
        ],
      ),
    );
  }
}
