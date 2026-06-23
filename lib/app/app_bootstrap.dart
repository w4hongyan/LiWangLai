import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/errors/error_handler.dart';
import '../core/errors/logger.dart';
import '../data/database/app_database.dart';
import '../domain/services/privacy_service.dart';
import '../domain/services/reminder_scheduler.dart';
import 'providers.dart' show databaseProvider, privacyServiceProvider, sharedPreferencesProvider;

/// A-9 / A-10 启动期初始化。返回值用于 runApp。
class AppBootstrapResult {
  AppBootstrapResult({
    required this.prefs,
    required this.database,
    required this.privacy,
  });

  final SharedPreferences prefs;
  final AppDatabase database;
  final PrivacyService privacy;
}

/// 启动顺序：
/// 1. 安装全局错误处理
/// 2. 获取 SharedPreferences
/// 3. 打开 Drift 数据库（异步，避免 UI 阻塞）
/// 4. 初始化通知插件（不请求权限，等用户首次进入「我的-通知设置」再请求）
/// 5. 触发隐私锁：若用户已开启，启动即锁
Future<AppBootstrapResult> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppErrorHandler.install();
  AppLogger.instance.i('AppBootstrap start');

  final prefs = await SharedPreferences.getInstance();
  final database = AppDatabase();
  // 触发 migration / seed
  await database.customSelect('PRAGMA user_version').get();

  // 通知插件（不申请权限，等 SettingsPage 内手动触发）
  try {
    await ReminderScheduler(prefs: prefs).initialize();
  } catch (e, st) {
    AppLogger.instance.e('通知初始化失败（继续启动）', error: e, stack: st);
  }

  // 隐私锁默认开启（按 SharedPreferences 持久值）
  final privacy = PrivacyService(prefs: prefs);
  final enabled = prefs.getBool('privacy.lock.enabled') ?? true;
  if (enabled) {
    privacy.lock();
  }

  AppLogger.instance.i('AppBootstrap done');
  return AppBootstrapResult(prefs: prefs, database: database, privacy: privacy);
}

/// 用 bootstrap 结果构建 ProviderContainer。
ProviderContainer buildContainer(AppBootstrapResult result) {
  return ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(result.prefs),
      databaseProvider.overrideWithValue(result.database),
      privacyServiceProvider.overrideWithValue(result.privacy),
    ],
  );
}