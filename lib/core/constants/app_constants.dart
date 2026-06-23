/// 跨页面常量（命名空间避免散落 magic number）
class AppConstants {
  AppConstants._();

  /// 默认账本名（设计文档 §11.1 单账本期）
  static const String defaultLedgerBookName = '我家';

  /// 礼台「记入并继续」成功后焦点回到姓名框的延迟
  static const Duration quickDeskFocusDelay = Duration(milliseconds: 80);

  /// 后台→前台超过该时长，再次触发隐私锁
  static const Duration privacyLockGracePeriod = Duration(seconds: 30);

  /// 通知 channel id（Android 必需）
  static const String notificationChannelRedId = 'liwanglai_red_default';
  static const String notificationChannelWhiteId = 'liwanglai_white_default';

  /// 备份文件名模板
  static const String backupFileNamePrefix = 'liwanglai_backup';
  static const String backupFileExt = '.lwlbak';
}