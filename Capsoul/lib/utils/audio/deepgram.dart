// import 'dart:async';
// import 'dart:io';

// import 'package:web_socket_channel/io.dart';

// Future<void> transcribeWithDeepgram(String filePath) async {
//   print("Starting WebSocket transcription with Deepgram...");

//   final apiKey =
//       '5a04d9c8dfa5cf9bbe3ab6913194a42332308413'; // Replace with your API key
//   final wsUri = Uri.parse(
//       'wss://api.deepgram.com/v1/listen?encoding=opus&sample_rate=16000&language=en&model=nova-2-general&no_delay=false&endpointing=100&interim_results=true&smart_format=true&diarize=true');

//   // Validate the file path
//   final file = File(filePath);
//   if (!file.existsSync()) {
//     print('Error: File does not exist at $filePath');
//     return;
//   }

//   // Print file size
//   print('File size: ${file.lengthSync()} bytes');

//   // Read the `.bin` file
//   final rawOpusData = await file.readAsBytes();
//   print('Read ${rawOpusData.length} bytes from the file.');

//   // Establish WebSocket connection
//   final channel = IOWebSocketChannel.connect(
//     wsUri,
//     headers: {
//       'Authorization': 'Token 5a04d9c8dfa5cf9bbe3ab6913194a42332308413',
//       'Content-Type': 'audio/raw',
//     },
//   );

//   await channel.ready;

//   // Stream audio packets to Deepgram
//   const chunkSize = 1024; // Number of bytes per packet
//   int offset = 0;

//   try {
//     // Listen for transcription results
//     channel.stream.listen(
//       (message) {
//         print('Transcription result: $message');
//       },
//       onError: (error) {
//         print('WebSocket error: $error');
//       },
//       onDone: () {
//         print('WebSocket connection closed.');
//       },
//     );

//     // Send audio data in chunks
//     while (offset < rawOpusData.length) {
//       final end = (offset + chunkSize < rawOpusData.length)
//           ? offset + chunkSize
//           : rawOpusData.length;
//       final chunk = rawOpusData.sublist(offset, end);
//       channel.sink.add(chunk);
//       offset = end;

//       // Simulate real-time streaming
//       await Future.delayed(Duration(milliseconds: 50));
//     }

//     // Close the WebSocket connection after sending all data
//     print('All audio data sent. Closing connection...');
//     channel.sink.close();
//   } catch (e) {
//     print('Exception during WebSocket streaming: $e');
//     channel.sink.close();
//   }
// }

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

Future<void> transcribeWithDeepgram(String filePath) async {
  print("Starting transcription with Deepgram...");

  final apiKey =
      '5a04d9c8dfa5cf9bbe3ab6913194a42332308413'; // Replace with your API key
  final url = Uri.parse(
      'https://api.deepgram.com/v1/listen?encoding=opus&sample_rate=16000&language=en&model=nova-2-general&no_delay=false&endpointing=100&interim_results=false&smart_format=true&diarize=true');

  final file = File(filePath);

  // Validate the file path
  if (!file.existsSync()) {
    print('Error: File does not exist at $filePath');
    return;
  }

  // Print file size
  print('File size: ${file.lengthSync()} bytes');

  // Read the .bin file
  final rawOpusData = await file.readAsBytes();
  print('Read ${rawOpusData.length} bytes from the file.');

  try {
    // Send POST request to Deepgram
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Token $apiKey',
        'Content-Type': 'audio/raw', // Specify Opus content type
      },
      body: rawOpusData,
    );

    // Handle the response
    if (response.statusCode == 200) {
      final transcription = jsonDecode(response.body);
      print(transcription);
      print(
          'Transcription: ${transcription['results']['channels'][0]['alternatives'][0]['transcript']}');
    } else {
      print('Error: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print('Exception occurred: $e');
  }
}
