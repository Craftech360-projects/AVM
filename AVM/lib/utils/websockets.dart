// ignore_for_file: unused_local_variable

import 'dart:async';
import 'dart:convert';

import 'package:avm/backend/database/transcript_segment.dart';
import 'package:avm/backend/preferences.dart';
import 'package:avm/utils/ble/communication.dart';
import 'package:flutter/material.dart';
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
  debugPrint(recordingsLanguage);

  const deepgramapikey = "e19942922008143bf76a75cb75b92853faa0b0da";
  String? codecType = SharedPreferencesUtil().getCodecType('NewCodec');

  String encoding = codecType == "opus" ? 'opus' : 'linear16';
  const String language = 'en-US';
  final int sampleRate = codecType == "opus" ? 16000 : 8000;
  final String codec = codecType;
  const int channels = 1;
  final String apiType = SharedPreferencesUtil().getApiType('NewApiKey') ?? '';
  Uri uri = Uri.parse(
    'wss://api.deepgram.com/v1/listen?encoding=$encoding&sample_rate=$sampleRate&channels=1',
  );

  debugPrint('apiType at dee$apiType');
  switch (apiType) {
    case 'Deepgram':
      uri = Uri.parse(
        'wss://api.deepgram.com/v1/listen?encoding=$encoding&sample_rate=$sampleRate&channels=1',
      );
      break;

    case 'Sarvam':
      uri = Uri.parse(
        'ws://king-prawn-app-u3xwv.ondigitalocean.app?service=service2&sample_rate=$sampleRate&codec=pcm8&channels=1',
      );
      break;
    case 'Whisper':
      uri = Uri.parse(
        'ws://king-prawn-app-u3xwv.ondigitalocean.app?service=service3&sample_rate=$sampleRate&codec=pcm8&channels=1',
      );
      break;
    default:
      'Deepgram';
      uri = Uri.parse(
        'wss://api.deepgram.com/v1/listen?encoding=$encoding&sample_rate=$sampleRate&channels=1',
      );
  }

  debugPrint('Connecting to WebSocket URI:$apiType $uri');

  try {
    IOWebSocketChannel channel = IOWebSocketChannel.connect(
      uri,
      headers: {
        'Authorization': 'Token e19942922008143bf76a75cb75b92853faa0b0da',
        'Content-Type': 'audio/raw',
      },
    );

    await channel.ready;
    await channel.ready;

    // KeepAlive mechanism
    Timer? keepAliveTimer;
    const silenceTimeout = Duration(seconds: 30); // Silence timeout
    DateTime? lastAudioTime;

    channel.stream.listen(
      (event) {
        if (event == 'ping') return;

        try {
          final data = jsonDecode(event);
          //  print('websocket data satyam $event');
          if (data['type'] == 'Metadata') {
            // Handle metadata event
          } else if (data['type'] == 'Results') {
            //  print('deepgram sever selected');
            // Handle results event
            final alternatives = data['channel']['alternatives'];
            if (alternatives is List && alternatives.isNotEmpty) {
              final transcript = alternatives[0]['transcript'];
              if (transcript is String && transcript.isNotEmpty) {
                final segment = TranscriptSegment(
                  text: transcript,
                  // speaker: 'SPEAKER_00',
                  speaker: '1',

                  isUser: false,
                  start: (data['start'] as double?) ?? 0.0,
                  end: ((data['start'] as double?) ?? 0.0) +
                      ((data['duration'] as double?) ?? 0.0),
                );
                onMessageReceived([segment]);
                lastAudioTime = DateTime.now();
                debugPrint('updated lastAudioTime: $lastAudioTime');
              } else {
                // debugPrint('Empty or invalid transcript');
              }
            } else {
              debugPrint('No alternatives found in the result');
            }
          } else if (data['type'] == 'transcript') {
            // Handle transcript event
            final segmentData = data['segment'];
            debugPrint('websocket json data $segmentData');

            // Ensure speaker is a string
            final speaker =
                segmentData['speaker']?.toString() ?? 'SPEAKER_UNKNOWN';
            debugPrint('websocket json data $speaker');

            // Ensure text is a string
            final text = segmentData['text']?.toString() ?? '';
            debugPrint('websocket json data $text');

            // Check if text is not empty
            if (text.isNotEmpty) {
              final segment = TranscriptSegment(
                text: text,
                speaker: speaker,
                isUser: false, // Adjust as needed
                start:
                    0.0, // You might want to add a start/end time if available
                end: 0.0,
              );
              debugPrint('websocket- json data ${segment.toString()}');
              onMessageReceived([segment]);
            }
            lastAudioTime = DateTime.now();
            debugPrint('Transcript received from $speaker: $text');
          } else {
            debugPrint('Unknown event type: ${data['type']}');
          }
        } catch (e) {
          debugPrint('Error processing event: $e');
          debugPrint('Raw event: $event');
        }
      },
    );

    await channel.ready;
    debugPrint('Websocket Opened');
    onWebsocketConnectionSuccess();
    return channel;
  } catch (err, stackTrace) {
    onWebsocketConnectionFailed(err);
    CrashReporting.reportHandledCrash(
      err,
      stackTrace,
      // level: NonFatalExceptionLevel.warning,
    );
    return null;
  }
}