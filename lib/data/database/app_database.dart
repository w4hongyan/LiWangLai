import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/logger.dart';
import 'tables/gift_records_table.dart';
import 'tables/gift_templates_table.dart';
import 'tables/ledger_books_table.dart';
import 'tables/persons_table.dart';
import 'tables/reminders_table.dart';

part 'app_database.g.dart';

/// 设计文档 §12.2：A-1 持久化基座。drift + sqlite3_flutter_libs。
/// 5 张表 + 默认账本/系统模板 seed + 迁移脚手架。
@DriftDatabase(
  tables: [LedgerBooks, Persons, GiftRecords, Reminders, GiftTemplates],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seed();
        },
        onUpgrade: (m, from, to) async {
          // v1 为初始版本，预留 upgrade 钩子以备后续 schema 演进。
          AppLogger.instance.i(
            'AppDatabase upgrade skipped',
            context: {'from': from, 'to': to},
          );
        },
        beforeOpen: (details) async {
          // 强制外键约束（默认在 SQLite 上是关闭的）
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  Future<void> _seed() async {
    final now = DateTime.now();
    final defaultBook = LedgerBooksCompanion.insert(
      id: 'default',
      name: AppConstants.defaultLedgerBookName,
      createdAt: now,
      updatedAt: now,
      type: const Value('personal'),
      themeId: const Value('apricot_red'),
      isDefault: const Value(true),
    );
    await into(ledgerBooks).insert(defaultBook);

    // 系统礼金模板（设计文档 §14 提到的 GiftTemplate）
    final templates = <GiftTemplatesCompanion>[
      GiftTemplatesCompanion.insert(
        id: 'tpl_wedding_close',
        name: '挚友婚礼',
        eventType: '婚礼',
        defaultAmount: 1000,
        isSystem: const Value(true),
        createdAt: now,
        updatedAt: now,
        noteTemplate: const Value('贺仪'),
      ),
      GiftTemplatesCompanion.insert(
        id: 'tpl_baby_close',
        name: '挚友满月',
        eventType: '满月',
        defaultAmount: 800,
        isSystem: const Value(true),
        createdAt: now,
        updatedAt: now,
      ),
      GiftTemplatesCompanion.insert(
        id: 'tpl_moving_close',
        name: '挚友乔迁',
        eventType: '乔迁',
        defaultAmount: 600,
        isSystem: const Value(true),
        createdAt: now,
        updatedAt: now,
      ),
      GiftTemplatesCompanion.insert(
        id: 'tpl_funeral',
        name: '白事奠仪',
        eventType: '吊唁',
        defaultAmount: 500,
        isSystem: const Value(true),
        createdAt: now,
        updatedAt: now,
      ),
    ];
    await batch((b) {
      b.insertAll(giftTemplates, templates);
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'liwanglai.sqlite'));
      return NativeDatabase.createInBackground(file);
    } catch (e, st) {
      AppLogger.instance.e('打开数据库失败', error: e, stack: st);
      throw PersistenceException('打开数据库失败', cause: e, stackTrace: st);
    }
  });
}