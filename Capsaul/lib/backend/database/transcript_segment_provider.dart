// ignore_for_file: unused_field

import 'package:capsaul/backend/database/box.dart';
import 'package:capsaul/backend/database/transcript_segment.dart';
import 'package:capsaul/objectbox.g.dart';

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
