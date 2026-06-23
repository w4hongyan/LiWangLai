import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// A-10 监控：本地轻量日志基座。开发期 debug/release 都打印，正式上线时
/// 可一行替换为 Sentry / Crashlytics 适配，避免业务层散落 print / log。
class AppLogger {
  AppLogger._internal();

  static final AppLogger instance = AppLogger._internal();

  /// 仅 debug 模式输出
  static const bool _verbose = kDebugMode;

  void d(String message, {Map<String, Object?>? context}) {
    if (_verbose) {
      developer.log(message, name: 'LiWangLai', level: 500);
      debugPrint('[D] $message ${context ?? ''}');
    }
  }

  void i(String message, {Map<String, Object?>? context}) {
    developer.log(message, name: 'LiWangLai', level: 800);
    debugPrint('[I] $message ${context ?? ''}');
  }

  void w(String message, {Object? error, StackTrace? stack}) {
    developer.log(
      message,
      name: 'LiWangLai',
      level: 900,
      error: error,
      stackTrace: stack,
    );
    debugPrint('[W] $message ${error ?? ''}');
  }

  void e(String message, {Object? error, StackTrace? stack}) {
    developer.log(
      message,
      name: 'LiWangLai',
      level: 1000,
      error: error,
      stackTrace: stack,
    );
    debugPrint('[E] $message ${error ?? ''}');
    if (stack != null) debugPrint(stack.toString());
  }
}