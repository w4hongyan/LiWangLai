import 'package:drift/drift.dart';

import 'ledger_books_table.dart';

/// 设计文档 §11.4 Reminder
@DataClassName('ReminderRow')
class Reminders extends Table {
  TextColumn get id => text()();
  TextColumn get ledgerBookId =>
      text().references(LedgerBooks, #id, onDelete: KeyAction.cascade)();
  TextColumn get personId => text().nullable()();
  TextColumn get relatedRecordId => text().nullable()();
  TextColumn get type => text()();
  TextColumn get title => text()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get remindAt => dateTime()();
  TextColumn get status =>
      text().withDefault(const Constant('pending'))();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}