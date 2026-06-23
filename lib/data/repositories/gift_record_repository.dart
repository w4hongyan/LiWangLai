import 'package:drift/drift.dart';

import '../../domain/entities/gift_record.dart';
import '../database/app_database.dart';

class GiftRecordRepository {
  GiftRecordRepository(this._db);

  final AppDatabase _db;

  Stream<List<GiftRecord>> watchByBook(String ledgerBookId) {
    final query = _db.select(_db.giftRecords)
      ..where((tbl) =>
          tbl.ledgerBookId.equals(ledgerBookId) &
          tbl.isDeleted.equals(false))
      ..orderBy([
        (tbl) => OrderingTerm(expression: tbl.eventDate, mode: OrderingMode.desc),
        (tbl) => OrderingTerm(expression: tbl.createdAt, mode: OrderingMode.desc),
      ]);
    return query.watch().map(
          (rows) => rows.map(_toEntity).toList(growable: false),
        );
  }

  Future<GiftRecord?> findById(String id) async {
    final row = await (_db.select(_db.giftRecords)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toEntity(row);
  }

  Future<void> upsert(GiftRecord record) async {
    await _db
        .into(_db.giftRecords)
        .insertOnConflictUpdate(_toCompanion(record));
  }

  Future<void> softDelete(String id, {DateTime? now}) async {
    await (_db.update(_db.giftRecords)..where((tbl) => tbl.id.equals(id))).write(
      GiftRecordsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(now ?? DateTime.now()),
      ),
    );
  }

  Future<List<GiftRecord>> listAll({bool includeDeleted = false}) async {
    final query = _db.select(_db.giftRecords);
    if (!includeDeleted) {
      query.where((tbl) => tbl.isDeleted.equals(false));
    }
    final rows = await query.get();
    return rows.map(_toEntity).toList(growable: false);
  }

  Future<void> bulkUpsert(Iterable<GiftRecord> records) async {
    await _db.batch((b) {
      b.insertAll(
        _db.giftRecords,
        records.map(_toCompanion),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<void> replaceAll(Iterable<GiftRecord> records) async {
    await _db.transaction(() async {
      await _db.delete(_db.giftRecords).go();
      await bulkUpsert(records);
    });
  }

  GiftRecord _toEntity(GiftRecordRow row) => GiftRecord(
        id: row.id,
        name: row.name,
        relation: row.relation,
        event: row.eventType,
        direction: GiftDirection.fromWire(row.direction),
        tone: EventTone.fromWire(row.eventTone),
        amount: row.amount,
        date: row.eventDate,
        method: GiftMethod.fromWire(row.recordMethod).label,
        book: row.ledgerBookId,
        note: row.note ?? '',
        itemDescription: row.giftName ?? row.serviceDescription ?? '',
        partial: row.completionStatus == 'partial',
        needReturn: row.needReturn,
        personId: row.personId,
        nickname: row.nickname,
        relationLabel: row.relationLabel,
        phone: row.phone,
        estimatedAmount: row.estimatedAmount,
        giftName: row.giftName,
        serviceDescription: row.serviceDescription,
        lunarDate: row.lunarDate,
        returnedRecordId: row.returnedRecordId,
        entryMode: GiftEntryMode.fromWire(row.entryMode),
        completionStatus: GiftCompletionStatus.fromWire(row.completionStatus),
        quickScene: row.quickScene,
        tempRelationText: row.tempRelationText,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        isDeleted: row.isDeleted,
      );

  GiftRecordsCompanion _toCompanion(GiftRecord record) => GiftRecordsCompanion(
        id: Value(record.id),
        ledgerBookId: Value(record.ledgerBookId),
        personId: Value(record.personId),
        name: Value(record.name),
        nickname: Value(record.nickname),
        relation: Value(record.relation),
        relationLabel: Value(record.relationLabel),
        phone: Value(record.phone),
        eventType: Value(record.eventType),
        direction: Value(record.direction.wire),
        eventTone: Value(record.tone.wire),
        recordMethod: Value(record.recordMethod.wire),
        amount: Value(record.amount),
        estimatedAmount: Value(record.estimatedAmount),
        giftName: Value(record.giftName),
        serviceDescription: Value(record.serviceDescription),
        eventDate: Value(record.eventDate),
        lunarDate: Value(record.lunarDate),
        note: Value(record.note),
        needReturn: Value(record.needReturn),
        returnedRecordId: Value(record.returnedRecordId),
        entryMode: Value(record.entryMode.wire),
        completionStatus: Value(record.completionStatus.wire),
        quickScene: Value(record.quickScene),
        tempRelationText: Value(record.tempRelationText),
        createdAt: Value(record.createdAt),
        updatedAt: Value(record.updatedAt),
        isDeleted: Value(record.isDeleted),
      );
}