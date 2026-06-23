import 'package:drift/drift.dart';

import 'ledger_books_table.dart';

/// 设计文档 §11.2 Person
@DataClassName('PersonRow')
class Persons extends Table {
  TextColumn get id => text()();
  TextColumn get ledgerBookId =>
      text().references(LedgerBooks, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  TextColumn get nickname => text().nullable()();
  TextColumn get relationType => text().nullable()();
  TextColumn get relationLabel => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get avatar => text().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get birthdaySolar => dateTime().nullable()();
  TextColumn get birthdayLunar => text().nullable()();
  BoolColumn get isImportant => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}