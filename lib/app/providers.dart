import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/errors/logger.dart';
import '../core/types.dart';
import '../data/database/app_database.dart';
import '../data/repositories/gift_record_repository.dart';
import '../data/repositories/gift_template_repository.dart';
import '../data/repositories/ledger_book_repository.dart';
import '../data/repositories/person_repository.dart';
import '../data/repositories/reminder_repository.dart';
import '../domain/services/export_service.dart';
import '../domain/services/privacy_service.dart';
import '../domain/services/reminder_scheduler.dart';

/// ============ 数据库 / 仓库 ============

/// 数据库 provider。Override 时可注入 in-memory 或 custom executor。
final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('databaseProvider 必须在 main() 中被 override');
});

final ledgerBookRepositoryProvider = Provider<LedgerBookRepository>(
  (ref) => LedgerBookRepository(ref.watch(databaseProvider)),
);

final personRepositoryProvider = Provider<PersonRepository>(
  (ref) => PersonRepository(ref.watch(databaseProvider)),
);

final giftRecordRepositoryProvider = Provider<GiftRecordRepository>(
  (ref) => GiftRecordRepository(ref.watch(databaseProvider)),
);

final reminderRepositoryProvider = Provider<ReminderRepository>(
  (ref) => ReminderRepository(ref.watch(databaseProvider)),
);

final giftTemplateRepositoryProvider = Provider<GiftTemplateRepository>(
  (ref) => GiftTemplateRepository(ref.watch(databaseProvider)),
);

/// ============ 当前账本 ============

final currentLedgerBookIdProvider = StateProvider<String>((ref) => 'default');

final currentLedgerBookProvider = FutureProvider<LedgerBook?>((ref) async {
  final repo = ref.watch(ledgerBookRepositoryProvider);
  // 默认账本不存在时（首次启动，onCreate 已 seed），fallback 等待 seed 完成
  return repo.findDefault();
});

/// ============ 数据流（按当前账本）============

final recordsStreamProvider = StreamProvider<List<GiftRecord>>((ref) {
  final bookId = ref.watch(currentLedgerBookIdProvider);
  final repo = ref.watch(giftRecordRepositoryProvider);
  return repo.watchByBook(bookId);
});

final remindersStreamProvider = StreamProvider<List<Reminder>>((ref) {
  final bookId = ref.watch(currentLedgerBookIdProvider);
  final repo = ref.watch(reminderRepositoryProvider);
  return repo.watchPendingByBook(bookId);
});

final personsStreamProvider =
    StreamProvider.family<List<Person>, String>((ref, bookId) {
  final repo = ref.watch(personRepositoryProvider);
  return repo.watchByBook(bookId);
});

final templatesStreamProvider = StreamProvider<List<GiftTemplate>>((ref) {
  final repo = ref.watch(giftTemplateRepositoryProvider);
  return repo.watchAll();
});

/// ============ 服务（单例）============

/// SharedPreferences 需要在 main 注入
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
      'sharedPreferencesProvider 必须在 main() 中被 override');
});

final exportServiceProvider = Provider<ExportService>((ref) => ExportService());

final privacyServiceProvider = Provider<PrivacyService>((ref) {
  final service = PrivacyService(prefs: ref.watch(sharedPreferencesProvider));
  ref.onDispose(service.dispose);
  return service;
});

final reminderSchedulerProvider = Provider<ReminderScheduler>((ref) {
  return ReminderScheduler(prefs: ref.watch(sharedPreferencesProvider));
});

/// ============ UI 状态 ============

/// UI 选中的账本 id（与 currentLedgerBookIdProvider 同步，但允许强制设置）
final selectedBookIdProvider = StateProvider<String>((ref) => 'default');

/// UI 当前 tab 索引（替代 _LiWangLaiHomeState 中的 _tabIndex）
final homeTabIndexProvider = StateProvider<int>((ref) => 0);

/// 礼台模式：红榜 / 白榜 切换
final quickDeskToneProvider = StateProvider<bool>((ref) => true); // true = 红

/// 上次离开 App 的时间（隐私锁判断 gracePeriod）
final lastBackgroundedAtProvider = StateProvider<DateTime?>((ref) => null);

/// Logger（保持单例）
final loggerProvider = Provider<AppLogger>((ref) => AppLogger.instance);