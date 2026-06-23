import 'package:drift/drift.dart';

import '../../domain/entities/gift_template.dart';
import '../database/app_database.dart';

class GiftTemplateRepository {
  GiftTemplateRepository(this._db);

  final AppDatabase _db;

  Stream<List<GiftTemplate>> watchAll() {
    final query = _db.select(_db.giftTemplates)
      ..orderBy([
        (tbl) => OrderingTerm(expression: tbl.isSystem, mode: OrderingMode.desc),
        (tbl) => OrderingTerm(expression: tbl.name),
      ]);
    return query.watch().map(
          (rows) => rows.map(_toEntity).toList(growable: false),
        );
  }

  Future<List<GiftTemplate>> listByEvent(String eventType) async {
    final rows = await (_db.select(_db.giftTemplates)
          ..where((tbl) => tbl.eventType.equals(eventType)))
        .get();
    return rows.map(_toEntity).toList(growable: false);
  }

  Future<void> upsert(GiftTemplate t) async {
    await _db
        .into(_db.giftTemplates)
        .insertOnConflictUpdate(_toCompanion(t));
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.giftTemplates)..where((tbl) => tbl.id.equals(id))).go();
  }

  GiftTemplate _toEntity(GiftTemplateRow row) => GiftTemplate(
        id: row.id,
        name: row.name,
        eventType: row.eventType,
        relationType: row.relationType,
        defaultAmount: row.defaultAmount,
        noteTemplate: row.noteTemplate,
        isSystem: row.isSystem,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );

  GiftTemplatesCompanion _toCompanion(GiftTemplate t) => GiftTemplatesCompanion(
        id: Value(t.id),
        name: Value(t.name),
        eventType: Value(t.eventType),
        relationType: Value(t.relationType),
        defaultAmount: Value(t.defaultAmount),
        noteTemplate: Value(t.noteTemplate),
        isSystem: Value(t.isSystem),
        createdAt: Value(t.createdAt),
        updatedAt: Value(t.updatedAt),
      );
}