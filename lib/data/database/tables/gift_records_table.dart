import 'package:drift/drift.dart';

import 'ledger_books_table.dart';
import 'persons_table.dart';

/// 设计文档 §11.3 GiftRecord
@DataClassName('GiftRecordRow')
class GiftRecords extends Table {
  TextColumn get id => text()();
  TextColumn get ledgerBookId =>
      text().references(LedgerBooks, #id, onDelete: KeyAction.cascade)();
  TextColumn get personId => text()
      .nullable()
      .references(Persons, #id, onDelete: KeyAction.setNull)();

  TextColumn get name => text()();
  TextColumn get nickname => text().nullable()();
  TextColumn get relation => text()();
  TextColumn get relationLabel => text().nullable()();
  TextColumn get phone => text().nullable()();

  TextColumn get eventType => text()();
  TextColumn get direction => text()();
  TextColumn get eventTone => text()();
  TextColumn get recordMethod => text()();

  IntColumn get amount => integer()();
  IntColumn get estimatedAmount => integer().nullable()();
  TextColumn get giftName => text().nullable()();
  TextColumn get serviceDescription => text().nullable()();

  DateTimeColumn get eventDate => dateTime()();
  TextColumn get lunarDate => text().nullable()();
  TextColumn get note => text().nullable()();

  BoolColumn get needReturn => boolean().withDefault(const Constant(false))();
  TextColumn get returnedRecordId => text().nullable()();

  TextColumn get entryMode =>
      text().withDefault(const Constant('normal'))();
  TextColumn get completionStatus =>
      text().withDefault(const Constant('complete'))();
  TextColumn get quickScene => text().nullable()();
  TextColumn get tempRelationText => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}