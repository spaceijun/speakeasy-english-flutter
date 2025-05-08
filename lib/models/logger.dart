import 'package:flutter/foundation.dart';

/// A utility class for structured logging in Flutter applications
class Logger {
  /// Log levels for different types of messages
  static const int VERBOSE = 0;
  static const int DEBUG = 1;
  static const int INFO = 2;
  static const int WARNING = 3;
  static const int ERROR = 4;

  /// Current log level - messages below this level won't be printed
  static int _logLevel = DEBUG;

  /// Tag prefixes for different log levels
  static const Map<int, String> _tagPrefixes = {
    VERBOSE: '🔍 VERBOSE',
    DEBUG: '🐛 DEBUG',
    INFO: 'ℹ️ INFO',
    WARNING: '⚠️ WARNING',
    ERROR: '❌ ERROR',
  };

  /// Colors for different log levels (ANSI escape codes)
  static const Map<int, String> _tagColors = {
    VERBOSE: '\x1B[37m', // White
    DEBUG: '\x1B[36m', // Cyan
    INFO: '\x1B[32m', // Green
    WARNING: '\x1B[33m', // Yellow
    ERROR: '\x1B[31m', // Red
  };

  static const String _resetColor = '\x1B[0m';

  /// Set the minimum log level
  static void setLogLevel(int level) {
    _logLevel = level;
  }

  /// Log a message with the specified level and optional tag
  static void log(int level, String message, {String? tag, Object? data}) {
    // Don't log if below current log level
    if (level < _logLevel) return;

    // Don't log in production unless it's an error
    if (!kDebugMode && level < ERROR) return;

    final timestamp = DateTime.now().toString().substring(0, 19);
    final levelTag = _tagPrefixes[level] ?? 'LOG';
    final tagStr = tag != null ? '[$tag]' : '';

    // Apply colors in debug mode
    String output;
    if (kDebugMode) {
      final colorCode = _tagColors[level] ?? '';
      output = '$colorCode[$timestamp] $levelTag$tagStr: $message$_resetColor';
    } else {
      output = '[$timestamp] $levelTag$tagStr: $message';
    }

    print(output);

    // Print additional data if provided
    if (data != null) {
      print('${' ' * 10}↳ Data: $data');
    }
  }

  /// Log a verbose message
  static void v(String message, {String? tag, Object? data}) {
    log(VERBOSE, message, tag: tag, data: data);
  }

  /// Log a debug message
  static void d(String message, {String? tag, Object? data}) {
    log(DEBUG, message, tag: tag, data: data);
  }

  /// Log an info message
  static void i(String message, {String? tag, Object? data}) {
    log(INFO, message, tag: tag, data: data);
  }

  /// Log a warning message
  static void w(String message, {String? tag, Object? data}) {
    log(WARNING, message, tag: tag, data: data);
  }

  /// Log an error message
  static void e(String message, {String? tag, Object? data}) {
    log(ERROR, message, tag: tag, data: data);
  }

  /// Log network requests and responses
  static void http(
    String url,
    String method, {
    int? statusCode,
    dynamic requestData,
    dynamic responseData,
  }) {
    final tag = 'HTTP';
    final emoji = statusCode != null && statusCode >= 400 ? '🔴' : '🟢';
    final status = statusCode != null ? ' ($statusCode)' : '';

    log(INFO, '$emoji $method $url$status', tag: tag);

    if (requestData != null) {
      log(DEBUG, 'Request Data:', tag: tag, data: requestData);
    }

    if (responseData != null) {
      log(DEBUG, 'Response Data:', tag: tag, data: responseData);
    }
  }

  /// Log API service calls
  static void api(
    String service,
    String method, {
    dynamic params,
    dynamic result,
    Object? error,
  }) {
    final tag = 'API';
    final success = error == null;
    final emoji = success ? '✅' : '❌';

    log(INFO, '$emoji $service.$method()', tag: tag);

    if (params != null) {
      log(DEBUG, 'Parameters:', tag: tag, data: params);
    }

    if (result != null) {
      log(DEBUG, 'Result:', tag: tag, data: result);
    }

    if (error != null) {
      log(ERROR, 'Error:', tag: tag, data: error);
    }
  }

  /// Log performance metrics
  static void performance(String operation, int durationMs, {String? detail}) {
    final detailStr = detail != null ? ' ($detail)' : '';
    final emoji = durationMs > 1000 ? '⏱️' : '⚡';
    log(
      INFO,
      '$emoji $operation completed in $durationMs ms$detailStr',
      tag: 'PERF',
    );
  }

  /// Measure execution time of a function
  static Future<T> measure<T>(
    String operation,
    Future<T> Function() function,
  ) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await function();
      performance(operation, stopwatch.elapsedMilliseconds);
      return result;
    } catch (e) {
      performance(operation, stopwatch.elapsedMilliseconds, detail: 'failed');
      rethrow;
    } finally {
      stopwatch.stop();
    }
  }
}

/// Extension to add logging capabilities to any class
extension LoggerExtension on Object {
  void logV(String message, {Object? data}) {
    Logger.v(message, tag: runtimeType.toString(), data: data);
  }

  void logD(String message, {Object? data}) {
    Logger.d(message, tag: runtimeType.toString(), data: data);
  }

  void logI(String message, {Object? data}) {
    Logger.i(message, tag: runtimeType.toString(), data: data);
  }

  void logW(String message, {Object? data}) {
    Logger.w(message, tag: runtimeType.toString(), data: data);
  }

  void logE(String message, {Object? data}) {
    Logger.e(message, tag: runtimeType.toString(), data: data);
  }
}
