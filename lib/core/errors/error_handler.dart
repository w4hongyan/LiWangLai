import 'package:flutter/foundation.dart';

import '../errors/app_exception.dart';
import 'logger.dart';

/// A-9：统一错误兜底。封装 FlutterError.onError、PlatformDispatcher.instance.onError
/// 以及 runZonedGuarded 的入口。所有 throw 都会被记录到本地日志。
class AppErrorHandler {
  AppErrorHandler._();

  static bool _installed = false;

  static void install() {
    if (_installed) return;
    _installed = true;

    final previousFlutterOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      AppLogger.instance.e(
        'FlutterError',
        error: details.exception,
        stack: details.stack,
      );
      previousFlutterOnError?.call(details);
    };

    final previousPlatformOnError = PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = (error, stack) {
      AppLogger.instance.e('PlatformError', error: error, stack: stack);
      return previousPlatformOnError?.call(error, stack) ?? true;
    };
  }

  /// 把任意 throwable 转成 AppException 统一向上抛。
  static AppException normalize(Object error, [StackTrace? stack]) {
    if (error is AppException) return error;
    return AppException(
      error.toString(),
      cause: error,
      stackTrace: stack,
    );
  }
}