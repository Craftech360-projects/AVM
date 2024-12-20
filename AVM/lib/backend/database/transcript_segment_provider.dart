// ignore_for_file: unused_field

import 'package:avm/backend/database/box.dart';
import 'package:avm/backend/database/transcript_segment.dart';
import 'package:avm/objectbox.g.dart';

class TranscriptSegmentProvider {
  static final TranscriptSegmentProvider _instance =
      TranscriptSegmentProvider._internal();
  static final Box<TranscriptSegment> _box =
      ObjectBoxUtil().box!.store.box<TranscriptSegment>();

  factory TranscriptSegmentProvider() {
    return _instance;
  }

  TranscriptSegmentProvider._internal();
}
