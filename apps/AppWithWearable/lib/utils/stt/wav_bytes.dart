// import 'dart:async';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:device_info_plus/device_info_plus.dart';

// const int sampleRate = 8000;
// const int channelCount = 1;
// const int sampleWidth = 2;

// class WavBytesUtil {
//   final List<int> _audioBytes = [];

//   List<int> get audioBytes => _audioBytes;

//   void addAudioBytes(List<int> bytes) {
//     _audioBytes.addAll(bytes);
//   }

//   void insertAudioBytes(List<int> bytes) {
//     _audioBytes.insertAll(0, bytes);
//   }

//   void clearAudioBytes() {
//     _audioBytes.clear();
//     debugPrint('Cleared audio bytes');
//   }

//   void clearAudioBytesSegment({required int remainingSeconds}) {
//     _audioBytes.removeRange(
//         0, (_audioBytes.length) - (remainingSeconds * 8000));
//   }

//   static Future<File> createWavFile(List<int> audioBytes,
//       {String? filename}) async {
//     debugPrint('Creating WAV file...');

//     if (filename == null) {
//       final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
//       filename = 'temp-$timestamp.wav';
//     }

//     if (await _requestPermissions()) {
//       final wavBytes = getUInt8ListBytes(audioBytes);

//       // Create temporary file in application documents directory
//       final tempDirectory = await getApplicationDocumentsDirectory();
//       final tempFile = File('${tempDirectory.path}/$filename');
//       await tempFile.writeAsBytes(wavBytes);
//       debugPrint('Temporary WAV file created: ${tempFile.path}');

//       return tempFile;
//     } else {
//       throw Exception('Storage permission not granted');
//     }
//   }

//   static Future<bool> _requestPermissions() async {
//     if (Platform.isAndroid) {
//       var status = await Permission.storage.status;
//       if (!status.isGranted) {
//         status = await Permission.storage.request();
//         if (!status.isGranted) {
//           return false;
//         }
//       }

//       if (await _isBelowAndroid10()) {
//         return true;
//       }

//       status = await Permission.manageExternalStorage.status;
//       if (!status.isGranted) {
//         status = await Permission.manageExternalStorage.request();
//         if (!status.isGranted) {
//           return false;
//         }
//       }
//       return true;
//     } else if (Platform.isIOS) {
//       var status = await Permission.photos.status;
//       if (!status.isGranted) {
//         status = await Permission.photos.request();
//         return status.isGranted;
//       }
//       return true;
//     }
//     return false;
//   }

//   static Future<bool> _isBelowAndroid10() async {
//     if (Platform.isAndroid) {
//       final androidInfo = await DeviceInfoPlugin().androidInfo;
//       return androidInfo.version.sdkInt < 29;
//     }
//     return false;
//   }

//   static Uint8List getUInt8ListBytes(List<int> audioBytes) {
//     final wavHeader = buildWavHeader(audioBytes.length * 2);
//     return Uint8List.fromList(
//         wavHeader + convertToLittleEndianBytes(audioBytes));
//   }

//   static Uint8List convertToLittleEndianBytes(List<int> audioData) {
//     final byteData = ByteData(2 * audioData.length);
//     for (int i = 0; i < audioData.length; i++) {
//       byteData.setUint16(i * 2, audioData[i], Endian.little);
//     }
//     return byteData.buffer.asUint8List();
//   }

//   static Uint8List buildWavHeader(int dataLength) {
//     final byteData = ByteData(44);
//     final size = dataLength + 36;

//     byteData.setUint8(0, 0x52); // 'R'
//     byteData.setUint8(1, 0x49); // 'I'
//     byteData.setUint8(2, 0x46); // 'F'
//     byteData.setUint8(3, 0x46); // 'F'
//     byteData.setUint32(4, size, Endian.little);
//     byteData.setUint8(8, 0x57); // 'W'
//     byteData.setUint8(9, 0x41); // 'A'
//     byteData.setUint8(10, 0x56); // 'V'
//     byteData.setUint8(11, 0x45); // 'E'

//     byteData.setUint8(12, 0x66); // 'f'
//     byteData.setUint8(13, 0x6D); // 'm'
//     byteData.setUint8(14, 0x74); // 't'
//     byteData.setUint8(15, 0x20); // ' '
//     byteData.setUint32(16, 16, Endian.little);
//     byteData.setUint16(20, 1, Endian.little); // Audio format (1 = PCM)
//     byteData.setUint16(22, channelCount, Endian.little);
//     byteData.setUint32(24, sampleRate, Endian.little);
//     byteData.setUint32(
//         28, sampleRate * channelCount * sampleWidth, Endian.little);
//     byteData.setUint16(32, channelCount * sampleWidth, Endian.little);
//     byteData.setUint16(34, sampleWidth * 8, Endian.little);

//     byteData.setUint8(36, 0x64); // 'd'
//     byteData.setUint8(37, 0x61); // 'a'
//     byteData.setUint8(38, 0x74); // 't'
//     byteData.setUint8(39, 0x61); // 'a'
//     byteData.setUint32(40, dataLength, Endian.little);

//     return byteData.buffer.asUint8List();
//   }
// }

//SAVE AUDIO TO EXTERNAL DOWNLOAD FOLDER
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

const int sampleRate = 8000;
const int channelCount = 1;
const int sampleWidth = 2;

class WavBytesUtil {
  // List to hold audio data in bytes
  final List<int> _audioBytes = [];

  List<int> get audioBytes => _audioBytes;

  // Method to add audio bytes (now accepts List<int> instead of Uint8List)
  void addAudioBytes(List<int> bytes) {
    _audioBytes.addAll(bytes);
  }

  void insertAudioBytes(List<int> bytes) {
    _audioBytes.insertAll(0, bytes);
  }

  // Method to clear audio bytes
  void clearAudioBytes() {
    _audioBytes.clear();
    debugPrint('Cleared audio bytes');
  }

  void clearAudioBytesSegment({required int remainingSeconds}) {
    _audioBytes.removeRange(
        0, (_audioBytes.length) - (remainingSeconds * 8000));
  }

  // Method to create a WAV file from the stored audio bytes

  static Future<File> createWavFile(List<int> audioBytes,
      {String? tempFilename, required String filename}) async {
    debugPrint('Creating WAV file...');

    // Generate permanent filename
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final permFilename = 'recording-$timestamp.wav';

    // Set temporary filename if not provided
    if (tempFilename == null) {
      tempFilename = 'temp.wav';
    }

    if (await _requestPermissions()) {
      final wavBytes = getUInt8ListBytes(audioBytes);

      // Create temporary file in application documents directory
      final tempDirectory = await getApplicationDocumentsDirectory();
      final tempFile = File('${tempDirectory.path}/$tempFilename');
      await tempFile.writeAsBytes(wavBytes);
      debugPrint('Temporary WAV file created: ${tempFile.path}');

      // Create a copy in the download folder with the desired permanent filename
      final downloadDirectory = await getDownloadDirectory();
      final permanentFile = File('${downloadDirectory.path}/$permFilename');
      await permanentFile.writeAsBytes(wavBytes);
      debugPrint('Permanent WAV file created: ${permanentFile.path}');

      return tempFile;
    } else {
      throw Exception('Storage permission not granted');
    }
  }

  // Method to request storage permissions
  static Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
        if (!status.isGranted) {
          return false;
        }
      }

      if (await _isBelowAndroid10()) {
        return true;
      }

      status = await Permission.manageExternalStorage.status;
      if (!status.isGranted) {
        status = await Permission.manageExternalStorage.request();
        if (!status.isGranted) {
          return false;
        }
      }
      return true;
    } else if (Platform.isIOS) {
      var status = await Permission.photos.status;
      if (!status.isGranted) {
        status = await Permission.photos.request();
        return status.isGranted;
      }
      return true;
    }
    return false;
  }

  // Method to check if the Android version is below 10
  static Future<bool> _isBelowAndroid10() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt < 29;
    }
    return false;
  }

  // Method to get the download directory
  static Future<Directory> getDownloadDirectory() async {
    if (Platform.isAndroid) {
      if (await _isBelowAndroid10()) {
        Directory directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
        return directory;
      } else {
        if (await Permission.manageExternalStorage.isGranted) {
          Directory directory = Directory('/storage/emulated/0/Download');
          if (!await directory.exists()) {
            await directory.create(recursive: true);
          }
          return directory;
        } else {
          throw Exception('Manage external storage permission not granted');
        }
      }
    } else {
      return await getApplicationDocumentsDirectory();
    }
  }

  static Uint8List getUInt8ListBytes(List<int> audioBytes) {
    final wavHeader = buildWavHeader(audioBytes.length * 2);
    return Uint8List.fromList(
        wavHeader + convertToLittleEndianBytes(audioBytes));
  }

  // Utility to convert audio data to little-endian format
  static Uint8List convertToLittleEndianBytes(List<int> audioData) {
    final byteData = ByteData(2 * audioData.length);
    for (int i = 0; i < audioData.length; i++) {
      byteData.setUint16(i * 2, audioData[i], Endian.little);
    }
    return byteData.buffer.asUint8List();
  }

  static Uint8List buildWavHeader(int dataLength) {
    final byteData = ByteData(44);
    final size = dataLength + 36;

    // RIFF chunk
    byteData.setUint8(0, 0x52); // 'R'
    byteData.setUint8(1, 0x49); // 'I'
    byteData.setUint8(2, 0x46); // 'F'
    byteData.setUint8(3, 0x46); // 'F'
    byteData.setUint32(4, size, Endian.little);
    byteData.setUint8(8, 0x57); // 'W'
    byteData.setUint8(9, 0x41); // 'A'
    byteData.setUint8(10, 0x56); // 'V'
    byteData.setUint8(11, 0x45); // 'E'

    // fmt chunk
    byteData.setUint8(12, 0x66); // 'f'
    byteData.setUint8(13, 0x6D); // 'm'
    byteData.setUint8(14, 0x74); // 't'
    byteData.setUint8(15, 0x20); // ' '
    byteData.setUint32(16, 16, Endian.little);
    byteData.setUint16(20, 1, Endian.little); // Audio format (1 = PCM)
    byteData.setUint16(22, channelCount, Endian.little);
    byteData.setUint32(24, sampleRate, Endian.little);
    byteData.setUint32(
        28, sampleRate * channelCount * sampleWidth, Endian.little);
    byteData.setUint16(32, channelCount * sampleWidth, Endian.little);
    byteData.setUint16(34, sampleWidth * 8, Endian.little);

    // data chunk
    byteData.setUint8(36, 0x64); // 'd'
    byteData.setUint8(37, 0x61); // 'a'
    byteData.setUint8(38, 0x74); // 't'
    byteData.setUint8(39, 0x61); // 'a'
    byteData.setUint32(40, dataLength, Endian.little);

    return byteData.buffer.asUint8List();
  }
}
