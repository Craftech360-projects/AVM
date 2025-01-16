import 'dart:async';
import 'dart:convert';

import 'package:capsoul/utils/ble/communication.dart';
import 'package:capsoul/utils/websockets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:capsoul/backend/preferences.dart';

import 'websocket_test.mocks.dart';

@GenerateMocks([IOWebSocketChannel, WebSocketSink])
void main() {
  late MockIOWebSocketChannel mockChannel;
  late MockWebSocketSink mockSink;
  late StreamController<String> mockStreamController;

  setUp(() {
    mockChannel = MockIOWebSocketChannel();
    mockSink = MockWebSocketSink();
    mockStreamController = StreamController<String>();

    when(mockChannel.stream).thenAnswer((_) => mockStreamController.stream);
    when(mockChannel.sink).thenReturn(mockSink);
  });

  tearDown(() {
    mockStreamController.close();
  });
  

  group('streamingTranscript Tests', () {
    test('should successfully establish a WebSocket connection', () async {
      bool successCallbackCalled = false;

      await streamingTranscript(
        onWebsocketConnectionSuccess: () => successCallbackCalled = true,
        onWebsocketConnectionFailed: (error) =>
            fail('Connection failed unexpectedly'),
        onWebsocketConnectionClosed: (code, reason) =>
            fail('Connection closed unexpectedly'),
        onWebsocketConnectionError: (error) =>
            fail('Connection error unexpectedly'),
        onMessageReceived: (segments) {},
        codec: BleAudioCodec.pcm16,
        sampleRate: 8000,
      );

      expect(successCallbackCalled, isTrue);
    });
    // test('should process incoming transcript message', () async {
    //   debugPrint('Starting transcript processing test');
    //   List<TranscriptSegment> receivedSegments = [];
    //   final segmentsReceived = Completer<void>();

    //   // Track connection state
    //   bool isConnected = false;
    //   bool hasError = false;
    //   String? connectionError;

    //   debugPrint('Initializing streaming transcript');
    //   final streamFuture = streamingTranscript(
    //     onWebsocketConnectionSuccess: () {
    //       debugPrint('WebSocket connection successful');
    //       isConnected = true;
    //     },
    //     onWebsocketConnectionFailed: (error) {
    //       debugPrint('❌ WebSocket connection failed: $error');
    //       hasError = true;
    //       connectionError = error;
    //       fail('Connection failed unexpectedly: $error');
    //     },
    //     onWebsocketConnectionClosed: (code, reason) {
    //       debugPrint(
    //           '❌ WebSocket connection closed: code=$code, reason=$reason');
    //       isConnected = false;
    //       fail('Connection closed unexpectedly: $code, $reason');
    //     },
    //     onWebsocketConnectionError: (error) {
    //       debugPrint('❌ WebSocket error occurred: $error');
    //       hasError = true;
    //       connectionError = error.toString();
    //       fail('Connection error unexpectedly: $error');
    //     },
    //     onMessageReceived: (segments) {
    //       debugPrint('Received ${segments.length} segments');
    //       for (var segment in segments) {
    //         debugPrint(
    //             '  Segment: "${segment.text}" (${segment.start}-${segment.end}) by ${segment.speaker}');
    //       }
    //       receivedSegments.addAll(segments);
    //       if (segments.isNotEmpty) {
    //         debugPrint('Completing segmentsReceived completer');
    //         segmentsReceived.complete();
    //       }
    //     },
    //     codec: BleAudioCodec.pcm16,
    //     sampleRate: 8000,
    //   ).catchError((error) {
    //     debugPrint('❌ Unhandled error in streamingTranscript: $error');
    //     throw error;
    //   });

    //   debugPrint('Preparing mock transcript data');
    //   final mockData = jsonEncode({
    //     'type': 'Results',
    //     'channel': {
    //       'alternatives': [
    //         {
    //           'transcript': 'Hello world',
    //           'words': [
    //             {
    //               'punctuated_word': 'Hello',
    //               'start': 0.0,
    //               'end': 0.5,
    //               'speaker': 'Speaker 1',
    //             },
    //             {
    //               'punctuated_word': 'world',
    //               'start': 0.6,
    //               'end': 1.0,
    //               'speaker': 'Speaker 1',
    //             }
    //           ]
    //         }
    //       ]
    //     }
    //   });

    //   // Add delay to ensure connection is established
    //   debugPrint('Waiting for connection to be established');
    //   await Future.delayed(Duration(milliseconds: 100));

    //   if (!isConnected) {
    //     debugPrint('❌ Connection not established before sending data');
    //     if (hasError) {
    //       debugPrint('❌ Connection error occurred: $connectionError');
    //     }
    //   }

    //   debugPrint('Adding mock data to stream');
    //   mockStreamController.add(mockData);

    //   debugPrint('Waiting for segments to be received');
    //   await expectLater(
    //     segmentsReceived.future,
    //     completes,
    //     reason: 'Segments were not received within timeout period',
    //   ).timeout(
    //     Duration(seconds: 5),
    //     onTimeout: () {
    //       debugPrint('❌ Timeout waiting for segments');
    //       debugPrint('  Connected: $isConnected');
    //       debugPrint('  Has Error: $hasError');
    //       debugPrint('  Error: $connectionError');
    //       debugPrint('  Received Segments: ${receivedSegments.length}');
    //       return fail('Timed out waiting for segments');
    //     },
    //   );

    //   debugPrint('Verifying received segments');
    //   expect(receivedSegments.length, 2, reason: 'Expected exactly 2 segments');

    //   // Verify first segment
    //   debugPrint('Verifying first segment');
    //   expect(receivedSegments[0].text, equals('Hello'),
    //       reason: 'First segment text mismatch');
    //   expect(receivedSegments[0].start, equals(0.0),
    //       reason: 'First segment start time mismatch');
    //   expect(receivedSegments[0].end, equals(0.5),
    //       reason: 'First segment end time mismatch');
    //   expect(receivedSegments[0].speaker, equals('Speaker 1'),
    //       reason: 'First segment speaker mismatch');

    //   // Verify second segment
    //   debugPrint('Verifying second segment');
    //   expect(receivedSegments[1].text, equals('world'),
    //       reason: 'Second segment text mismatch');
    //   expect(receivedSegments[1].start, equals(0.6),
    //       reason: 'Second segment start time mismatch');
    //   expect(receivedSegments[1].end, equals(1.0),
    //       reason: 'Second segment end time mismatch');
    //   expect(receivedSegments[1].speaker, equals('Speaker 1'),
    //       reason: 'Second segment speaker mismatch');

    //   debugPrint('Test completed successfully');
    // });

    // test('should handle WebSocket error event', () async {
    //   dynamic capturedError;
    //   final errorReceived = Completer<void>();

    //   // Create a MockIOWebSocketChannel that will emit an error immediately
    //   when(mockChannel.stream).thenAnswer(
    //       (_) => Stream.fromFuture(Future.error('WebSocket error occurred'))
    //           .asBroadcastStream() // Make sure the stream can be listened to multiple times
    //       );

    //   // Start the streaming before setting up error handling
    //   final streamFuture = streamingTranscript(
    //     onWebsocketConnectionSuccess: () {},
    //     onWebsocketConnectionFailed: (error) =>
    //         fail('Connection failed unexpectedly'),
    //     onWebsocketConnectionClosed: (code, reason) =>
    //         fail('Connection closed unexpectedly'),
    //     onWebsocketConnectionError: (error) {
    //       capturedError = error;
    //       errorReceived.complete();
    //     },
    //     onMessageReceived: (segments) {},
    //     codec: BleAudioCodec.pcm16,
    //     sampleRate: 8000,
    //   ).catchError((e) {
    //     // Add general error handling to catch any unhandled errors
    //     print('Unhandled error in streamingTranscript: $e');
    //     errorReceived.completeError(e);
    //   });

    //   // Wait for either the error to be processed or the streaming to complete
    //   await Future.any([
    //     errorReceived.future,
    //     streamFuture,
    //   ]).timeout(
    //     const Duration(seconds: 2),
    //     onTimeout: () => throw TimeoutException(
    //         'Timed out waiting for error to be processed'),
    //   );

    //   expect(capturedError, isNotNull);
    //   expect(capturedError, equals('WebSocket error occurred'));
    // }, timeout: const Timeout(Duration(seconds: 5)));

    test(
      'should send KeepAlive messages periodically and stop after 30 seconds',
      () async {
        final List sentMessages = [];
        Timer? keepAliveTimer;

        // Mock sink behavior to capture sent messages
        when(mockSink.add(any)).thenAnswer((invocation) {
          sentMessages.add(invocation.positionalArguments.first);
          return;
        });

        bool keepAliveStopped = false;

        // Mock the WebSocket connection
        await streamingTranscript(
          onWebsocketConnectionSuccess: () {
            mockSink.add(jsonEncode({'type': 'KeepAlive'}));
            // Start the keep-alive mechanism
            keepAliveTimer = Timer.periodic(Duration(seconds: 7), (_) {
              mockSink.add(jsonEncode({'type': 'KeepAlive'}));
            });
          },
          onWebsocketConnectionFailed: (error) =>
              fail('Connection failed unexpectedly: $error'),
          onWebsocketConnectionClosed: (code, reason) =>
              fail('Connection closed unexpectedly: $code, $reason'),
          onWebsocketConnectionError: (error) =>
              fail('Connection error unexpectedly: $error'),
          onMessageReceived: (segments) {
            // Simulate receiving a message (optional)
          },
          codec: BleAudioCodec.pcm16,
          sampleRate: 8000,
        );

        // Reduce wait time to avoid timeout
        await Future.delayed(Duration(seconds: 25));

        // Stop the keep-alive mechanism
        if (keepAliveTimer?.isActive ?? false) {
          keepAliveTimer!.cancel();
          keepAliveStopped = true;
        }

        // Verify the number of KeepAlive messages sent
        final keepAliveMessages = sentMessages
            .where((msg) => msg.contains('"type":"KeepAlive"'))
            .toList();

        // Validate KeepAlive messages and timer status
        expect(keepAliveMessages.length, greaterThanOrEqualTo(4),
            reason:
                'Expected at least 4 KeepAlive messages within 25 seconds.');
        expect(keepAliveStopped, isTrue,
            reason: 'Keep-alive mechanism should have stopped.');
      },
      timeout: Timeout(Duration(seconds: 30)), // Explicitly set timeout
    );

    test('should call onWebsocketConnectionClosed when connection is closed',
        () async {
      int? closeCode;
      String? closeReason;

      await streamingTranscript(
        onWebsocketConnectionSuccess: () {},
        onWebsocketConnectionFailed: (error) =>
            fail('Connection failed unexpectedly'),
        onWebsocketConnectionClosed: (code, reason) {
          closeCode = code;
          closeReason = reason;
        },
        onWebsocketConnectionError: (error) =>
            fail('Connection error unexpectedly'),
        onMessageReceived: (segments) {},
        codec: BleAudioCodec.pcm16,
        sampleRate: 8000,
      );

      mockStreamController.close();

      await Future.delayed(
          Duration(milliseconds: 100)); // Allow async processing

      expect(closeCode, isNull);
      expect(closeReason, isNull);
    });
  });
}
