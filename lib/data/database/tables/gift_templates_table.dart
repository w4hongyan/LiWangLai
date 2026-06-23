import 'package:drift/drift.dart';

/// 设计文档 §11.5 GiftTemplate
@DataClassName('GiftTemplateRow')
class GiftTemplates extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get eventType => text()();
  TextColumn get relationType => text().nullable()();
  IntColumn get defaultAmount => integer()();
  TextColumn get noteTemplate => text().nullable()();
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}