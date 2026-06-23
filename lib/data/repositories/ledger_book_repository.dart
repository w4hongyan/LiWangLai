import 'package:drift/drift.dart';

import '../../domain/entities/ledger_book.dart';
import '../database/app_database.dart';

/// 账本仓库（A 阶段固定为「我家」单账本，B 阶段会扩展）。
class LedgerBookRepository {
  LedgerBookRepository(this._db);

  final AppDatabase _db;

  Stream<List<LedgerBook>> watchAll() {
    final query = _db.select(_db.ledgerBooks)
      ..where((tbl) => tbl.isArchived.equals(false))
      ..orderBy([
        (tbl) => OrderingTerm(expression: tbl.isDefault, mode: OrderingMode.desc),
        (tbl) => OrderingTerm(expression: tbl.createdAt),
      ]);
    return query.watch().map(
          (rows) => rows.map(_toEntity).toList(growable: false),
        );
  }

  Future<LedgerBook?> findDefault() async {
    final row = await (_db.select(_db.ledgerBooks)
          ..where((tbl) => tbl.isDefault.equals(true))
          ..limit(1))
        .getSingleOrNull();
    return row == null ? null : _toEntity(row);
  }

  Future<LedgerBook> upsert(LedgerBook book) async {
    await _db.into(_db.ledgerBooks).insertOnConflictUpdate(_toCompanion(book));
    return book;
  }

  Future<void> archive(String id) async {
    await (_db.update(_db.ledgerBooks)..where((tbl) => tbl.id.equals(id))).write(
      const LedgerBooksCompanion(isArchived: Value(true)),
    );
  }

  LedgerBook _toEntity(LedgerBookRow row) => LedgerBook(
        id: row.id,
        name: row.name,
        type: LedgerBookType.fromWire(row.type),
        themeId: row.themeId,
        isDefault: row.isDefault,
        isArchived: row.isArchived,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );

  LedgerBooksCompanion _toCompanion(LedgerBook book) => LedgerBooksCompanion(
        id: Value(book.id),
        name: Value(book.name),
        type: Value(book.type.wire),
        themeId: Value(book.themeId),
        isDefault: Value(book.isDefault),
        isArchived: Value(book.isArchived),
        createdAt: Value(book.createdAt),
        updatedAt: Value(book.updatedAt),
      );
}