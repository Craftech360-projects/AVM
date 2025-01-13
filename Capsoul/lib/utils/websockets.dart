// ignore_for_file: unused_local_variable

import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:capsoul/backend/database/transcript_segment.dart';
import 'package:capsoul/backend/preferences.dart';
import 'package:capsoul/utils/ble/communication.dart';
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
    log('Error receiving data: $e');
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
  final recordingsLanguage = SharedPreferencesUtil().recordingsLanguage;

  const deepgramapikey = "5a04d9c8dfa5cf9bbe3ab6913194a42332308413";
  // const deepgramapikey = "e19942922008143bf76a75cb75b92853faa0b0da";
  String? codecType = SharedPreferencesUtil().getCodecType('NewCodec');

  String encoding = codecType == "opus" ? 'opus' : 'linear16';
  const String language = 'en-US';
  final int sampleRate = codecType == "opus" ? 16000 : 8000;
  final String codec = codecType;
  const int channels = 1;
  final String apiType = SharedPreferencesUtil().getApiType('NewApiKey') ?? '';
  // Uri uri = Uri.parse(
  //   'wss://api.deepgram.com/v1/listen?encoding=$encoding&sample_rate=$sampleRate&channels=1',
  // );
  Uri uri = Uri.parse(
    'wss://api.deepgram.com/v1/listen?encoding=$encoding&sample_rate=$sampleRate&language=$recordingsLanguage&model=nova-2-general&no_delay=true&endpointing=100&interim_results=false&smart_format=true&diarize=true',
  );

  switch (apiType) {
    case 'Deepgram':
      uri = Uri.parse(
        'wss://api.deepgram.com/v1/listen?encoding=$encoding&sample_rate=$sampleRate&language=$recordingsLanguage&model=nova-2-general&no_delay=true&endpointing=100&interim_results=false&smart_format=true&diarize=true',
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
        'wss://api.deepgram.com/v1/listen?encoding=$encoding&sample_rate=$sampleRate&language=$recordingsLanguage&model=nova-2-general&no_delay=true&endpointing=100&interim_results=false&smart_format=true&diarize=true',
      );
  }
  log('Connecting to WebSocket URI:$apiType $uri');

  try {
    IOWebSocketChannel channel = IOWebSocketChannel.connect(
      uri,
      headers: {
        'Authorization': 'Token e19942922008143bf76a75cb75b92853faa0b0da',
        'Content-Type': 'audio/raw',
      },
    );

    await channel.ready;

    // KeepAlive mechanism
    Timer? keepAliveTimer;
    const keepAliveInterval = Duration(seconds: 7);
    const silenceTimeout = Duration(seconds: 300); // Silence timeout
    DateTime? lastAudioTime;
    void startKeepAlive() {
      keepAliveTimer = Timer.periodic(keepAliveInterval, (timer) async {
        try {
          await channel.ready;
          final keepAliveMsg = jsonEncode({'type': 'KeepAlive'});
          channel.sink.add(keepAliveMsg);
        } catch (e) {
          log('Error sending KeepAlive message: $e');
        }
      });
    }

    void stopKeepAlive() {
      keepAliveTimer?.cancel();
    }

    void checkSilence() {
      if (lastAudioTime != null) {
        Duration silenceDuration = DateTime.now().difference(lastAudioTime!);
        if (silenceDuration > silenceTimeout) {
          stopKeepAlive();
        }
      } else {
        log('No audio time recorded yet');
      }
    }

    // Start the keepalive mechanism
    startKeepAlive();
    channel.stream.listen(
      (event) {
        if (event == 'ping') return;

        try {
          final data = jsonDecode(event);
          if (data['type'] == 'Metadata') {
            // Handle metadata event
          } else if (data['type'] == 'Results') {
            // Handle results event
            final alternatives = data['channel']['alternatives'];
            if (alternatives is List && alternatives.isNotEmpty) {
              final transcript = alternatives[0]['transcript'];
              final words = alternatives[0]['words'];
              if (transcript is String &&
                  transcript.isNotEmpty &&
                  words is List) {
                List<TranscriptSegment> segments = [];
                for (var wordInfo in words) {
                  final word = wordInfo['punctuated_word'] ?? wordInfo['word'];
                  final speaker =
                      wordInfo['speaker']?.toString() ?? 'SPEAKER_UNKNOWN';
                  final start = wordInfo['start'] as double? ?? 0.0;
                  final end = wordInfo['end'] as double? ?? 0.0;
                  if (word is String && word.isNotEmpty) {
                    segments.add(TranscriptSegment(
                      text: word,
                      speaker: speaker,
                      isUser: false,
                      start: start,
                      end: end,
                    ));
                  }
                }
                onMessageReceived(segments);
                lastAudioTime = DateTime.now();
                checkSilence();
              } else {}
            } else {}
          } else if (data['type'] == 'transcript') {
            // Handle transcript event
            final segmentData = data['segment'];

            // Ensure speaker is a string
            final speaker =
                segmentData['speaker']?.toString() ?? 'SPEAKER_UNKNOWN';

            // Ensure text is a string
            final text = segmentData['text']?.toString() ?? '';

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
              onMessageReceived([segment]);
            }
            lastAudioTime = DateTime.now();
            // Check for silence after updating lastAudioTime
            checkSilence();
          } else {
            log('Unknown event type: ${data['type']}');
          }
        } catch (e) {
          log('Error processing event: $e');
        }
      },
      onDone: () {
        stopKeepAlive();
        onWebsocketConnectionClosed(null, null);
      },
      onError: (error) {
        stopKeepAlive();
        onWebsocketConnectionError(error);
      },
    );

    await channel.ready;
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
