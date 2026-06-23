/// 应用级异常基类，便于在错误边界做集中处理（A-9）。
class AppException implements Exception {
  AppException(this.message, {this.cause, this.stackTrace});

  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() {
    final base = 'AppException: $message';
    if (cause != null) {
      return '$base (cause: $cause)';
    }
    return base;
  }
}

class PersistenceException extends AppException {
  PersistenceException(super.message, {super.cause, super.stackTrace});
}

class ExportException extends AppException {
  ExportException(super.message, {super.cause, super.stackTrace});
}

class ImportException extends AppException {
  ImportException(super.message, {super.cause, super.stackTrace});
}

class NotificationException extends AppException {
  NotificationException(super.message, {super.cause, super.stackTrace});
}

class AuthException extends AppException {
  AuthException(super.message, {super.cause, super.stackTrace});
}