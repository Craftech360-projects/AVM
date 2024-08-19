import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:friend_private/backend/database/transcript_segment.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:friend_private/utils/ble/communication.dart';
import 'package:instabug_flutter/instabug_flutter.dart';
import 'package:web_socket_channel/io.dart';

enum WebsocketConnectionStatus {
  notConnected,
  connected,
  failed,
  closed,
  error
}

String mapCodecToName(BleAudioCodec codec) {
  switch (codec) {
    case BleAudioCodec.opus:
      return 'opus';
    case BleAudioCodec.pcm16:
      return 'pcm16';
    case BleAudioCodec.pcm8:
      return 'pcm8';
    default:
      return 'pcm8';
  }
}

//socket connection without keep

// Future<IOWebSocketChannel?> _initWebsocketStream(
//   void Function(List<TranscriptSegment>) onMessageReceived,
//   VoidCallback onWebsocketConnectionSuccess,
//   void Function(dynamic) onWebsocketConnectionFailed,
//   void Function(int?, String?) onWebsocketConnectionClosed,
//   void Function(dynamic) onWebsocketConnectionError,
//   int sampleRate,
//   String codec,
// ) async {
//   debugPrint('Websocket Opening');
//   final recordingsLanguage = SharedPreferencesUtil().recordingsLanguage;
//   final deepgramapikey = await getDeepgramApiKeyForUsage();
//   //final apiKey = "ab763c7874734209d21d838a62804b8119175f0c";
//   debugPrint("Deepgram API Key: ${SharedPreferencesUtil().deepgramApiKey}");

//   debugPrint("apikey , $deepgramapikey");
//   // 'ab763c7874734209d21d838a62804b8119175f0c'; // Replace with your actual API key

//   final uri = Uri.parse(
//     'wss://api.deepgram.com/v1/listen?encoding=linear16&sample_rate=$sampleRate&channels=1',
//     // 'ws://51e8-116-75-121-80.ngrok-free.app',
//   );

//   debugPrint('Connecting to WebSocket URI: $uri');

//   try {
//     IOWebSocketChannel channel = IOWebSocketChannel.connect(
//       uri,
//       headers: {
//         'Authorization': 'Token $deepgramapikey',
//         'Content-Type': 'audio/raw',
//       },
//     );

//     await channel.ready;

//     channel.ready.then((_) {
//       channel.stream.listen(
//         (event) {
//           if (event == 'ping') return;
//           try {
//             final data = jsonDecode(event);
//             if (data['type'] == 'Metadata') {
//               // debugPrint('Metadata received: $data');
//             } else if (data['type'] == 'Results') {
//               final alternatives = data['channel']['alternatives'];
//               if (alternatives is List && alternatives.isNotEmpty) {
//                 final transcript = alternatives[0]['transcript'];
//                 if (transcript is String && transcript.isNotEmpty) {
//                   // Create a single TranscriptSegment from the transcript
//                   final segment = TranscriptSegment(
//                     text: transcript,
//                     speaker:
//                         'SPEAKER_00', // or provide a default speaker if available
//                     isUser:
//                         false, // assuming this is not user speech, adjust as needed
//                     start: data['start'] ?? 0.0,
//                     end: (data['start'] ?? 0.0) + (data['duration'] ?? 0.0),
//                   );
//                   onMessageReceived([segment]);
//                 } else {
//                   debugPrint('Empty or invalid transcript');
//                 }
//               } else {
//                 debugPrint('No alternatives found in the result');
//               }
//             } else {
//               debugPrint('Unknown event type: ${data['type']}');
//             }
//           } catch (e) {
//             debugPrint('Error processing event: $e');
//             debugPrint('Raw event: $event');
//           }
//         },
//         onError: (err, stackTrace) {
//           onWebsocketConnectionError(err);
//           CrashReporting.reportHandledCrash(
//             err,
//             stackTrace,
//             level: NonFatalExceptionLevel.warning,
//           );
//         },
//         onDone: () {
//           onWebsocketConnectionClosed(channel.closeCode, channel.closeReason);
//         },
//         cancelOnError: true,
//       );
//     }).onError((err, stackTrace) {
//       // no closing reason or code
//       debugPrint(err);
//       CrashReporting.reportHandledCrash(
//         err!,
//         stackTrace,
//         level: NonFatalExceptionLevel.warning,
//       );
//       onWebsocketConnectionFailed(err); // initial connection failed
//     });

//     await channel.ready;
//     debugPrint('Websocket Opened');
//     onWebsocketConnectionSuccess();
//     return channel;
//   } catch (err, stackTrace) {
//     onWebsocketConnectionFailed(err);
//     CrashReporting.reportHandledCrash(
//       err!,
//       stackTrace,
//       level: NonFatalExceptionLevel.warning,
//     );
//     return null;
//   }
// }

//with wkeep alive 30 sec time

Future<IOWebSocketChannel?> _initWebsocketStream(
  void Function(List<TranscriptSegment>) onMessageReceived,
  VoidCallback onWebsocketConnectionSuccess,
  void Function(dynamic) onWebsocketConnectionFailed,
  void Function(int?, String?) onWebsocketConnectionClosed,
  void Function(dynamic) onWebsocketConnectionError,
  int sampleRate,
  String codec,
) async {
  debugPrint('Websocket Opening');
  final recordingsLanguage = SharedPreferencesUtil().recordingsLanguage;
  final deepgramapikey = getDeepgramApiKeyForUsage();
  debugPrint("Deepgram API Key: ${SharedPreferencesUtil().deepgramApiKey}");

  debugPrint("apikey , $deepgramapikey");

  // Example codec value
  String encoding = "opus";

  // if (codec == 'pcm8' || codec == 'pcm16') {
  //   // encoding = 'linear16';
  //   encoding = 'opus';
  // } else {
  //   encoding = 'opus';
  // }
  print("encoding>>>>>----------------->>>>>>>>>>> , $encoding");

  // final uri = Uri.parse(
  //   'wss://api.deepgram.com/v1/listen?encoding=$encoding&sample_rate=$sampleRate&channels=1',
  // );
  final uri = Uri.parse(
    'ws://living-alien-polite.ngrok-free.app',
  );

  debugPrint('Connecting to WebSocket URI: $uri');

  try {
    IOWebSocketChannel channel = IOWebSocketChannel.connect(
      uri,
      headers: {
        'Authorization': 'Token $deepgramapikey',
        'Content-Type': 'audio/raw',
      },
    );

    await channel.ready;

    // KeepAlive mechanism
    Timer? keepAliveTimer;
    const keepAliveInterval =
        Duration(seconds: 7); // Send KeepAlive every 7 seconds
    const silenceTimeout = Duration(seconds: 30); // Silence timeout
    DateTime? lastAudioTime;

    void startKeepAlive() {
      keepAliveTimer = Timer.periodic(keepAliveInterval, (timer) async {
        try {
          await channel.ready; // Ensure the channel is ready
          final keepAliveMsg = jsonEncode({'type': 'KeepAlive'});
          channel.sink.add(keepAliveMsg);
          // debugPrint('Sent KeepAlive message');
        } catch (e) {
          debugPrint('Error sending KeepAlive message: $e');
        }
      });
    }

    void stopKeepAlive() {
      keepAliveTimer?.cancel();
    }

    void checkSilence() {
      if (lastAudioTime != null &&
          DateTime.now().difference(lastAudioTime!) > silenceTimeout) {
        // debugPrint(
        //     'Silence detected for more than 30 seconds. Stopping KeepAlive.');
        stopKeepAlive();
      }
    }

    channel.ready.then((_) {
      startKeepAlive();

      channel.stream.listen(
        (event) {
          if (event == 'ping') return;
          try {
            final data = jsonDecode(event);
            if (data['type'] == 'Metadata') {
              // debugPrint('Metadata received: $data');
            } else if (data['type'] == 'Results') {
              final alternatives = data['channel']['alternatives'];
              if (alternatives is List && alternatives.isNotEmpty) {
                final transcript = alternatives[0]['transcript'];
                if (transcript is String && transcript.isNotEmpty) {
                  // Create a single TranscriptSegment from the transcript
                  final segment = TranscriptSegment(
                    text: transcript,
                    speaker:
                        'SPEAKER_00', // or provide a default speaker if available
                    isUser:
                        false, // assuming this is not user speech, adjust as needed
                    start: (data['start'] ?? 0.0)
                        .toDouble(), // Ensure start is a double
                    end: ((data['start'] ?? 0.0) + (data['duration'] ?? 0.0))
                        .toDouble(), // Ensure end is a double
                  );
                  onMessageReceived([segment]);

                  // Update the last audio time
                  lastAudioTime = DateTime.now();
                  debugPrint('updated lastAudioTime: $lastAudioTime');
                } else {
                  debugPrint('Empty or invalid transcript');
                }
              } else {
                debugPrint('No alternatives found in the result');
              }
            } else {
              debugPrint('Unknown event type: ${data['type']}');
            }
          } catch (e) {
            debugPrint('Error processing event: $e');
            debugPrint('Raw event: $event');
          }
        },
        onError: (err, stackTrace) {
          stopKeepAlive();
          onWebsocketConnectionError(err);
          CrashReporting.reportHandledCrash(
            err,
            stackTrace,
            level: NonFatalExceptionLevel.warning,
          );
        },
        onDone: () {
          stopKeepAlive();
          onWebsocketConnectionClosed(channel.closeCode, channel.closeReason);
        },
        cancelOnError: true,
      );

      // Periodically check for silence
      Timer.periodic(const Duration(seconds: 1), (timer) {
        checkSilence();
      });
    }).onError((err, stackTrace) {
      stopKeepAlive();
      debugPrint(err.toString());
      CrashReporting.reportHandledCrash(
        err!,
        stackTrace,
        level: NonFatalExceptionLevel.warning,
      );
      onWebsocketConnectionFailed(err); // initial connection failed
    });

    await channel.ready;
    debugPrint('Websocket Opened');
    onWebsocketConnectionSuccess();
    return channel;
  } catch (err, stackTrace) {
    onWebsocketConnectionFailed(err);
    CrashReporting.reportHandledCrash(
      err,
      stackTrace,
      level: NonFatalExceptionLevel.warning,
    );
    return null;
  }
}

Future<IOWebSocketChannel?> streamingTranscript({
  required VoidCallback onWebsocketConnectionSuccess,
  required void Function(dynamic) onWebsocketConnectionFailed,
  required void Function(int?, String?) onWebsocketConnectionClosed,
  required void Function(dynamic) onWebsocketConnectionError,
  required void Function(List<TranscriptSegment>) onMessageReceived,
  required BleAudioCodec codec,
  required int sampleRate,
}) async {
  try {
    IOWebSocketChannel? channel = await _initWebsocketStream(
      onMessageReceived,
      onWebsocketConnectionSuccess,
      onWebsocketConnectionFailed,
      onWebsocketConnectionClosed,
      onWebsocketConnectionError,
      sampleRate,
      mapCodecToName(codec),
    );

    return channel;
  } catch (e) {
    debugPrint('Error receiving data: $e');
  } finally {}

  return null;
}
