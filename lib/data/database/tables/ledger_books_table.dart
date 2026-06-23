import 'package:drift/drift.dart';

/// 设计文档 §11.1 LedgerBook
@DataClassName('LedgerBookRow')
class LedgerBooks extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text().withDefault(const Constant('personal'))();
  TextColumn get themeId => text().withDefault(const Constant('apricot_red'))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}