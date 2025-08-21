import 'package:flutter/foundation.dart';
import 'package:telnyx_common/src/utils/background_detector.dart';

/// Helper class for debugging state issues
class DebugHelper {
  static void logStateFlags() {
    if (kDebugMode) {
      debugPrint('=== STATE DEBUG INFO ===');
      debugPrint('BackgroundDetector.ignore: ${BackgroundDetector.ignore}');
      debugPrint('========================');
    }
  }

  static void resetAllFlags() {
    if (kDebugMode) {
      debugPrint('[DebugHelper] Manually resetting all ignore flags');
    }
    BackgroundDetector.ignore = false;
  }
}