import 'package:drift/drift.dart';

import '../../domain/entities/reminder.dart';
import '../database/app_database.dart';

class ReminderRepository {
  ReminderRepository(this._db);

  final AppDatabase _db;

  Stream<List<Reminder>> watchPendingByBook(String ledgerBookId) {
    final query = _db.select(_db.reminders)
      ..where((tbl) =>
          tbl.ledgerBookId.equals(ledgerBookId) &
          tbl.status.equals('pending'))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.date)]);
    return query.watch().map(
          (rows) => rows.map(_toEntity).toList(growable: false),
        );
  }

  Future<void> upsert(Reminder reminder) async {
    await _db.into(_db.reminders).insertOnConflictUpdate(_toCompanion(reminder));
  }

  Future<void> markDone(String id) async {
    await (_db.update(_db.reminders)..where((tbl) => tbl.id.equals(id))).write(
      const RemindersCompanion(status: Value('done')),
    );
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.reminders)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<List<Reminder>> listAll() async {
    final rows = await _db.select(_db.reminders).get();
    return rows.map(_toEntity).toList(growable: false);
  }

  Reminder _toEntity(ReminderRow row) => Reminder(
        id: row.id,
        ledgerBookId: row.ledgerBookId,
        personId: row.personId,
        relatedRecordId: row.relatedRecordId,
        type: ReminderType.fromWire(row.type),
        title: row.title,
        date: row.date,
        remindAt: row.remindAt,
        status: ReminderStatus.fromWire(row.status),
        note: row.note,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );

  RemindersCompanion _toCompanion(Reminder r) => RemindersCompanion(
        id: Value(r.id),
        ledgerBookId: Value(r.ledgerBookId),
        personId: Value(r.personId),
        relatedRecordId: Value(r.relatedRecordId),
        type: Value(r.type.wire),
        title: Value(r.title),
        date: Value(r.date),
        remindAt: Value(r.remindAt),
        status: Value(r.status.wire),
        note: Value(r.note),
        createdAt: Value(r.createdAt),
        updatedAt: Value(r.updatedAt),
      );
}