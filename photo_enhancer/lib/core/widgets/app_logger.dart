import 'dart:developer';

import 'package:flutter/foundation.dart';

final class AppLogger {
  static void logInfo(String message) {
    if (kDebugMode) {
      log(message);
    }
  }

  static void logError(String message, {Object? error}) {
    if (kDebugMode) {
      log(message, error: error);
    }
  }
}
