import 'dart:async';

import 'package:altio/backend/schema/bt_device.dart';
import 'package:altio/utils/audio/wav_bytes.dart';
import 'package:tuple/tuple.dart';

mixin OpenGlassMixin {
  List<Tuple2<String, String>> photos = [];
  ImageBytesUtil imageBytesUtil = ImageBytesUtil();
  StreamSubscription? _bleBytesStream;

  Future<void> openGlassProcessing(
    BTDeviceStruct device,
    Function(List<Tuple2<String, String>>) onPhotosUpdated,
    Function(bool) setHasTranscripts,
  ) async {}

  void disposeOpenGlass() {
    _bleBytesStream?.cancel();
    photos.clear();
  }
}
