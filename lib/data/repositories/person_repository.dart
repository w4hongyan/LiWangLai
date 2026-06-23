import 'package:drift/drift.dart';

import '../../domain/entities/person.dart';
import '../database/app_database.dart';

class PersonRepository {
  PersonRepository(this._db);

  final AppDatabase _db;

  Stream<List<Person>> watchByBook(String ledgerBookId) {
    final query = _db.select(_db.persons)
      ..where((tbl) => tbl.ledgerBookId.equals(ledgerBookId))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAt)]);
    return query.watch().map(
          (rows) => rows.map(_toEntity).toList(growable: false),
        );
  }

  Future<Person?> findById(String id) async {
    final row = await (_db.select(_db.persons)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toEntity(row);
  }

  Future<void> upsert(Person person) async {
    await _db.into(_db.persons).insertOnConflictUpdate(_toCompanion(person));
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.persons)..where((tbl) => tbl.id.equals(id))).go();
  }

  Person _toEntity(PersonRow row) => Person(
        id: row.id,
        ledgerBookId: row.ledgerBookId,
        name: row.name,
        nickname: row.nickname,
        relationType: row.relationType,
        relationLabel: row.relationLabel,
        phone: row.phone,
        avatar: row.avatar,
        note: row.note,
        birthdaySolar: row.birthdaySolar,
        birthdayLunar: row.birthdayLunar,
        isImportant: row.isImportant,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );

  PersonsCompanion _toCompanion(Person person) => PersonsCompanion(
        id: Value(person.id),
        ledgerBookId: Value(person.ledgerBookId),
        name: Value(person.name),
        nickname: Value(person.nickname),
        relationType: Value(person.relationType),
        relationLabel: Value(person.relationLabel),
        phone: Value(person.phone),
        avatar: Value(person.avatar),
        note: Value(person.note),
        birthdaySolar: Value(person.birthdaySolar),
        birthdayLunar: Value(person.birthdayLunar),
        isImportant: Value(person.isImportant),
        createdAt: Value(person.createdAt),
        updatedAt: Value(person.updatedAt),
      );
}