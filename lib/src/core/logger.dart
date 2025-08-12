import 'package:flutter/foundation.dart';

class AppLogger {
  static void log(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      print('[APP_LOG | ${DateTime.now()}]: $message');
      if (error != null) {
        print('[ERROR]: $error');
      }
      if (stackTrace != null) {
        print('[STACKTRACE]: $stackTrace');
      }
    }
  }
}