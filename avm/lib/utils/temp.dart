// enum WebsocketConnectionStatus {
//   notConnected,
//   connected,
//   failed,
//   closed,
//   error
// }

// String mapCodecToName(BleAudioCodec codec) {
//   switch (codec) {
//     case BleAudioCodec.opus:
//       return 'opus';
//     case BleAudioCodec.pcm16:
//       return 'pcm16';
//     case BleAudioCodec.pcm8:
//       return 'pcm8';
//     default:
//       return 'pcm8';
//   }
// }



// Future<IOWebSocketChannel?> _initWebsocketStream(
//   void Function(List<TranscriptSegment>) onMessageReceived,
//   VoidCallback onWebsocketConnectionSuccess,
//   void Function(dynamic) onWebsocketConnectionFailed,
//   void Function(int?, String?) onWebsocketConnectionClosed,
//   void Function(dynamic) onWebsocketConnectionError,
//   int sampleRate,
//   String codec,
// ) async {
//   final String apiType = 'Sarvam';
//   debugPrint('Websocket Opening');
//   final recordingsLanguage = SharedPreferencesUtil().recordingsLanguage;
//   final deepgramapikey = getDeepgramApiKeyForUsage();
//   debugPrint("Deepgram API Key: ${SharedPreferencesUtil().deepgramApiKey}");

//   debugPrint("apikey , $deepgramapikey");

//   // Example codec value
//   String encoding = "opus";

//   // if (codec == 'pcm8' || codec == 'pcm16') {
//   //   // encoding = 'linear16';
//   //   encoding = 'opus';
//   // } else {
//   //   encoding = 'opus';
//   // }
//   print("encoding>>>>>----------------->>>>>>>>>>> , $encoding");

//   // final uri = Uri.parse(
//   //   'wss://api.deepgram.com/v1/listen?encoding=$encoding&sample_rate=$sampleRate&channels=1',
//   // );
//   // final uri = Uri.parse(
//   //   'ws://clownfish-app-uveug.ondigitalocean.app',
//   // );
//   // //living-alien-polite.ngrok-free.app
//   const String language = 'en-US';
//   const int sampleRate = 48000;
//   const String codec = 'opus';
//   const int channels = 1;

//   switch (apiType) {
//     case 'Deepgram':
//      return  onSarvamselected();
  
//     case 'Sarvam':
//       return onSarvamselected();
//     case 'Wisper':
//       break;
//     default:
//       'Sarvam';
//       return onSarvamselected();
//   }
//   Uri uri = Uri.parse(
//     'wss://solid-wasp-balanced.ngrok-free.app?language=$language&sample_rate=$sampleRate&codec=$codec&channels=$channels',
//     // 'ws://51e8-116-75-121-80.ngrok-free.app',
//   );
//   debugPrint('Connecting to WebSocket URI: $uri');

//   void onSarvamselected() {
//     uri = Uri.parse(
//       'wss://solid-wasp-balanced.ngrok-free.app?language=$language&sample_rate=$sampleRate&codec=$codec&channels=$channels',
//     );
//   }

//   void onDeepgramselected() {
//     uri = Uri.parse(
//       'wss://api.deepgram.com/v1/listen?encoding=$encoding&sample_rate=$sampleRate&channels=1',
//     );
//   }

//   try {
//     IOWebSocketChannel channel = IOWebSocketChannel.connect(
//       uri,
//       headers: {
//         'Authorization': 'Token $deepgramapikey',
//         'Content-Type': 'audio/raw',
//       },
//     );

//     await channel.ready;

//     // KeepAlive mechanism
//     Timer? keepAliveTimer;
//     const keepAliveInterval =
//         Duration(seconds: 7); // Send KeepAlive every 7 seconds
//     const silenceTimeout = Duration(seconds: 30); // Silence timeout
//     DateTime? lastAudioTime;

//     void startKeepAlive() {
//       keepAliveTimer = Timer.periodic(keepAliveInterval, (timer) async {
//         try {
//           await channel.ready; // Ensure the channel is ready
//           final keepAliveMsg = jsonEncode({'type': 'KeepAlive'});
//           channel.sink.add(keepAliveMsg);
//           // debugPrint('Sent KeepAlive message');
//         } catch (e) {
//           debugPrint('Error sending KeepAlive message: $e');
//         }
//       });
//     }

//     void stopKeepAlive() {
//       keepAliveTimer?.cancel();
//     }

//     void checkSilence() {
//       if (lastAudioTime != null &&
//           DateTime.now().difference(lastAudioTime!) > silenceTimeout) {
//         // debugPrint(
//         //     'Silence detected for more than 30 seconds. Stopping KeepAlive.');
//         stopKeepAlive();
//       }
//     }


//     channel.stream.listen(
//       (event) {
//         if (event == 'ping') return;

//         try {
//           final data = jsonDecode(event);
//           print('websocket data satyam $event');
//           if (data['type'] == 'Metadata') {
//             // Handle metadata event
//           } else if (data['type'] == 'Results') {
//             print('deepgram sever selected');
//             // Handle results event
//             final alternatives = data['channel']['alternatives'];
//             if (alternatives is List && alternatives.isNotEmpty) {
//               final transcript = alternatives[0]['transcript'];
//               if (transcript is String && transcript.isNotEmpty) {
//                 final segment = TranscriptSegment(
//                   text: transcript,
//                   speaker: 'SPEAKER_00',
//                   isUser: false,
//                   start: (data['start'] as double?) ?? 0.0,
//                   end: ((data['start'] as double?) ?? 0.0) +
//                       ((data['duration'] as double?) ?? 0.0),
//                 );
//                 onMessageReceived([segment]);
//                 lastAudioTime = DateTime.now();
//                 debugPrint('updated lastAudioTime: $lastAudioTime');
//               } else {
//                 debugPrint('Empty or invalid transcript');
//               }
//             } else {
//               debugPrint('No alternatives found in the result');
//             }
//           } else if (data['type'] == 'transcript') {
//             // Handle transcript event
//             final segmentData = data['segment'];
//             debugPrint('websocket json data $segmentData');

//             // Ensure speaker is a string
//             final speaker =
//                 segmentData['speaker']?.toString() ?? 'SPEAKER_UNKNOWN';
//             debugPrint('websocket json data $speaker');

//             // Ensure text is a string
//             final text = segmentData['text']?.toString() ?? '';
//             debugPrint('websocket json data $text');

//             // Check if text is not empty
//             if (text.isNotEmpty) {
//               final segment = TranscriptSegment(
//                 text: text,
//                 speaker: speaker,
//                 isUser: false, // Adjust as needed
//                 start:
//                     0.0, // You might want to add a start/end time if available
//                 end: 0.0,
//               );
//               debugPrint('websocket- json data ${segment.toString()}');
//               onMessageReceived([segment]);
//             }
//             lastAudioTime = DateTime.now();
//             debugPrint('Transcript received from $speaker: $text');
//           } else {
//             debugPrint('Unknown event type: ${data['type']}');
//           }
//         } catch (e) {
//           debugPrint('Error processing event: $e');
//           debugPrint('Raw event: $event');
//         }
//       },
//     );



//     await channel.ready;
//     debugPrint('Websocket Opened');
//     onWebsocketConnectionSuccess();
//     return channel;
//   } catch (err, stackTrace) {
//     onWebsocketConnectionFailed(err);
//     CrashReporting.reportHandledCrash(
//       err,
//       stackTrace,
//       level: NonFatalExceptionLevel.warning,
//     );
//     return null;
//   }
// }


// void setDiffApi({required String apiType}) {
//   apiType = apiType;

// }

// Future<IOWebSocketChannel?> streamingTranscript({
//   required VoidCallback onWebsocketConnectionSuccess,
//   required void Function(dynamic) onWebsocketConnectionFailed,
//   required void Function(int?, String?) onWebsocketConnectionClosed,
//   required void Function(dynamic) onWebsocketConnectionError,
//   required void Function(List<TranscriptSegment>) onMessageReceived,
//   required BleAudioCodec codec,
//   required int sampleRate,
// }) async {
//   try {
//     IOWebSocketChannel? channel = await _initWebsocketStream(
//       onMessageReceived,
//       onWebsocketConnectionSuccess,
//       onWebsocketConnectionFailed,
//       onWebsocketConnectionClosed,
//       onWebsocketConnectionError,
//       sampleRate,
//       mapCodecToName(codec),
//     );

//     return channel;
//   } catch (e) {
//     debugPrint('Error receiving data: $e');
//   } finally {}

//   return null;
// }