import 'package:flutter/foundation.dart';

class LoggerService {
  static void log(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      print('DEBUG: $message');
      if (error != null) print('ERROR: $error');
      if (stackTrace != null) print('STACK TRACE: $stackTrace');
    } else {
      // In production, you would send this to Sentry, Crashlytics, etc.
      // For now, we print to console as a placeholder.
      print('PRODUCTION_LOG: $message');
      if (error != null) print('PRODUCTION_ERROR: $error');
    }
  }

  static void info(String message) => log('INFO: $message');
  static void warning(String message) => log('WARNING: $message');
  static void error(String message, [Object? error, StackTrace? st]) =>
      log('ERROR: $message', error: error, stackTrace: st);
}
