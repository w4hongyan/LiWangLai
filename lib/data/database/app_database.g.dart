// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LedgerBooksTable extends LedgerBooks
    with TableInfo<$LedgerBooksTable, LedgerBookRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LedgerBooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('personal'),
  );
  static const VerificationMeta _themeIdMeta = const VerificationMeta(
    'themeId',
  );
  @override
  late final GeneratedColumn<String> themeId = GeneratedColumn<String>(
    'theme_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('apricot_red'),
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    themeId,
    isDefault,
    isArchived,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ledger_books';
  @override
  VerificationContext validateIntegrity(
    Insertable<LedgerBookRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('theme_id')) {
      context.handle(
        _themeIdMeta,
        themeId.isAcceptableOrUnknown(data['theme_id']!, _themeIdMeta),
      );
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LedgerBookRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LedgerBookRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      themeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_id'],
      )!,
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LedgerBooksTable createAlias(String alias) {
    return $LedgerBooksTable(attachedDatabase, alias);
  }
}

class LedgerBookRow extends DataClass implements Insertable<LedgerBookRow> {
  final String id;
  final String name;
  final String type;
  final String themeId;
  final bool isDefault;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LedgerBookRow({
    required this.id,
    required this.name,
    required this.type,
    required this.themeId,
    required this.isDefault,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['theme_id'] = Variable<String>(themeId);
    map['is_default'] = Variable<bool>(isDefault);
    map['is_archived'] = Variable<bool>(isArchived);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LedgerBooksCompanion toCompanion(bool nullToAbsent) {
    return LedgerBooksCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      themeId: Value(themeId),
      isDefault: Value(isDefault),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LedgerBookRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LedgerBookRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      themeId: serializer.fromJson<String>(json['themeId']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'themeId': serializer.toJson<String>(themeId),
      'isDefault': serializer.toJson<bool>(isDefault),
      'isArchived': serializer.toJson<bool>(isArchived),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LedgerBookRow copyWith({
    String? id,
    String? name,
    String? type,
    String? themeId,
    bool? isDefault,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => LedgerBookRow(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    themeId: themeId ?? this.themeId,
    isDefault: isDefault ?? this.isDefault,
    isArchived: isArchived ?? this.isArchived,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LedgerBookRow copyWithCompanion(LedgerBooksCompanion data) {
    return LedgerBookRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      themeId: data.themeId.present ? data.themeId.value : this.themeId,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LedgerBookRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('themeId: $themeId, ')
          ..write('isDefault: $isDefault, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    type,
    themeId,
    isDefault,
    isArchived,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LedgerBookRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.themeId == this.themeId &&
          other.isDefault == this.isDefault &&
          other.isArchived == this.isArchived &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LedgerBooksCompanion extends UpdateCompanion<LedgerBookRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> type;
  final Value<String> themeId;
  final Value<bool> isDefault;
  final Value<bool> isArchived;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LedgerBooksCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.themeId = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LedgerBooksCompanion.insert({
    required String id,
    required String name,
    this.type = const Value.absent(),
    this.themeId = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.isArchived = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LedgerBookRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? themeId,
    Expression<bool>? isDefault,
    Expression<bool>? isArchived,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (themeId != null) 'theme_id': themeId,
      if (isDefault != null) 'is_default': isDefault,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LedgerBooksCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? type,
    Value<String>? themeId,
    Value<bool>? isDefault,
    Value<bool>? isArchived,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LedgerBooksCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      themeId: themeId ?? this.themeId,
      isDefault: isDefault ?? this.isDefault,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (themeId.present) {
      map['theme_id'] = Variable<String>(themeId.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LedgerBooksCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('themeId: $themeId, ')
          ..write('isDefault: $isDefault, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PersonsTable extends Persons with TableInfo<$PersonsTable, PersonRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ledgerBookIdMeta = const VerificationMeta(
    'ledgerBookId',
  );
  @override
  late final GeneratedColumn<String> ledgerBookId = GeneratedColumn<String>(
    'ledger_book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES ledger_books (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nicknameMeta = const VerificationMeta(
    'nickname',
  );
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
    'nickname',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _relationTypeMeta = const VerificationMeta(
    'relationType',
  );
  @override
  late final GeneratedColumn<String> relationType = GeneratedColumn<String>(
    'relation_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _relationLabelMeta = const VerificationMeta(
    'relationLabel',
  );
  @override
  late final GeneratedColumn<String> relationLabel = GeneratedColumn<String>(
    'relation_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avatarMeta = const VerificationMeta('avatar');
  @override
  late final GeneratedColumn<String> avatar = GeneratedColumn<String>(
    'avatar',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _birthdaySolarMeta = const VerificationMeta(
    'birthdaySolar',
  );
  @override
  late final GeneratedColumn<DateTime> birthdaySolar =
      GeneratedColumn<DateTime>(
        'birthday_solar',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _birthdayLunarMeta = const VerificationMeta(
    'birthdayLunar',
  );
  @override
  late final GeneratedColumn<String> birthdayLunar = GeneratedColumn<String>(
    'birthday_lunar',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isImportantMeta = const VerificationMeta(
    'isImportant',
  );
  @override
  late final GeneratedColumn<bool> isImportant = GeneratedColumn<bool>(
    'is_important',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_important" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ledgerBookId,
    name,
    nickname,
    relationType,
    relationLabel,
    phone,
    avatar,
    note,
    birthdaySolar,
    birthdayLunar,
    isImportant,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'persons';
  @override
  VerificationContext validateIntegrity(
    Insertable<PersonRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('ledger_book_id')) {
      context.handle(
        _ledgerBookIdMeta,
        ledgerBookId.isAcceptableOrUnknown(
          data['ledger_book_id']!,
          _ledgerBookIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ledgerBookIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('nickname')) {
      context.handle(
        _nicknameMeta,
        nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta),
      );
    }
    if (data.containsKey('relation_type')) {
      context.handle(
        _relationTypeMeta,
        relationType.isAcceptableOrUnknown(
          data['relation_type']!,
          _relationTypeMeta,
        ),
      );
    }
    if (data.containsKey('relation_label')) {
      context.handle(
        _relationLabelMeta,
        relationLabel.isAcceptableOrUnknown(
          data['relation_label']!,
          _relationLabelMeta,
        ),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('avatar')) {
      context.handle(
        _avatarMeta,
        avatar.isAcceptableOrUnknown(data['avatar']!, _avatarMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('birthday_solar')) {
      context.handle(
        _birthdaySolarMeta,
        birthdaySolar.isAcceptableOrUnknown(
          data['birthday_solar']!,
          _birthdaySolarMeta,
        ),
      );
    }
    if (data.containsKey('birthday_lunar')) {
      context.handle(
        _birthdayLunarMeta,
        birthdayLunar.isAcceptableOrUnknown(
          data['birthday_lunar']!,
          _birthdayLunarMeta,
        ),
      );
    }
    if (data.containsKey('is_important')) {
      context.handle(
        _isImportantMeta,
        isImportant.isAcceptableOrUnknown(
          data['is_important']!,
          _isImportantMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PersonRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ledgerBookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ledger_book_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      nickname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nickname'],
      ),
      relationType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relation_type'],
      ),
      relationLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relation_label'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      avatar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      birthdaySolar: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}birthday_solar'],
      ),
      birthdayLunar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}birthday_lunar'],
      ),
      isImportant: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_important'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PersonsTable createAlias(String alias) {
    return $PersonsTable(attachedDatabase, alias);
  }
}

class PersonRow extends DataClass implements Insertable<PersonRow> {
  final String id;
  final String ledgerBookId;
  final String name;
  final String? nickname;
  final String? relationType;
  final String? relationLabel;
  final String? phone;
  final String? avatar;
  final String? note;
  final DateTime? birthdaySolar;
  final String? birthdayLunar;
  final bool isImportant;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PersonRow({
    required this.id,
    required this.ledgerBookId,
    required this.name,
    this.nickname,
    this.relationType,
    this.relationLabel,
    this.phone,
    this.avatar,
    this.note,
    this.birthdaySolar,
    this.birthdayLunar,
    required this.isImportant,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['ledger_book_id'] = Variable<String>(ledgerBookId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || nickname != null) {
      map['nickname'] = Variable<String>(nickname);
    }
    if (!nullToAbsent || relationType != null) {
      map['relation_type'] = Variable<String>(relationType);
    }
    if (!nullToAbsent || relationLabel != null) {
      map['relation_label'] = Variable<String>(relationLabel);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || avatar != null) {
      map['avatar'] = Variable<String>(avatar);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || birthdaySolar != null) {
      map['birthday_solar'] = Variable<DateTime>(birthdaySolar);
    }
    if (!nullToAbsent || birthdayLunar != null) {
      map['birthday_lunar'] = Variable<String>(birthdayLunar);
    }
    map['is_important'] = Variable<bool>(isImportant);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PersonsCompanion toCompanion(bool nullToAbsent) {
    return PersonsCompanion(
      id: Value(id),
      ledgerBookId: Value(ledgerBookId),
      name: Value(name),
      nickname: nickname == null && nullToAbsent
          ? const Value.absent()
          : Value(nickname),
      relationType: relationType == null && nullToAbsent
          ? const Value.absent()
          : Value(relationType),
      relationLabel: relationLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(relationLabel),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      avatar: avatar == null && nullToAbsent
          ? const Value.absent()
          : Value(avatar),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      birthdaySolar: birthdaySolar == null && nullToAbsent
          ? const Value.absent()
          : Value(birthdaySolar),
      birthdayLunar: birthdayLunar == null && nullToAbsent
          ? const Value.absent()
          : Value(birthdayLunar),
      isImportant: Value(isImportant),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PersonRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonRow(
      id: serializer.fromJson<String>(json['id']),
      ledgerBookId: serializer.fromJson<String>(json['ledgerBookId']),
      name: serializer.fromJson<String>(json['name']),
      nickname: serializer.fromJson<String?>(json['nickname']),
      relationType: serializer.fromJson<String?>(json['relationType']),
      relationLabel: serializer.fromJson<String?>(json['relationLabel']),
      phone: serializer.fromJson<String?>(json['phone']),
      avatar: serializer.fromJson<String?>(json['avatar']),
      note: serializer.fromJson<String?>(json['note']),
      birthdaySolar: serializer.fromJson<DateTime?>(json['birthdaySolar']),
      birthdayLunar: serializer.fromJson<String?>(json['birthdayLunar']),
      isImportant: serializer.fromJson<bool>(json['isImportant']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ledgerBookId': serializer.toJson<String>(ledgerBookId),
      'name': serializer.toJson<String>(name),
      'nickname': serializer.toJson<String?>(nickname),
      'relationType': serializer.toJson<String?>(relationType),
      'relationLabel': serializer.toJson<String?>(relationLabel),
      'phone': serializer.toJson<String?>(phone),
      'avatar': serializer.toJson<String?>(avatar),
      'note': serializer.toJson<String?>(note),
      'birthdaySolar': serializer.toJson<DateTime?>(birthdaySolar),
      'birthdayLunar': serializer.toJson<String?>(birthdayLunar),
      'isImportant': serializer.toJson<bool>(isImportant),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PersonRow copyWith({
    String? id,
    String? ledgerBookId,
    String? name,
    Value<String?> nickname = const Value.absent(),
    Value<String?> relationType = const Value.absent(),
    Value<String?> relationLabel = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> avatar = const Value.absent(),
    Value<String?> note = const Value.absent(),
    Value<DateTime?> birthdaySolar = const Value.absent(),
    Value<String?> birthdayLunar = const Value.absent(),
    bool? isImportant,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => PersonRow(
    id: id ?? this.id,
    ledgerBookId: ledgerBookId ?? this.ledgerBookId,
    name: name ?? this.name,
    nickname: nickname.present ? nickname.value : this.nickname,
    relationType: relationType.present ? relationType.value : this.relationType,
    relationLabel: relationLabel.present
        ? relationLabel.value
        : this.relationLabel,
    phone: phone.present ? phone.value : this.phone,
    avatar: avatar.present ? avatar.value : this.avatar,
    note: note.present ? note.value : this.note,
    birthdaySolar: birthdaySolar.present
        ? birthdaySolar.value
        : this.birthdaySolar,
    birthdayLunar: birthdayLunar.present
        ? birthdayLunar.value
        : this.birthdayLunar,
    isImportant: isImportant ?? this.isImportant,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PersonRow copyWithCompanion(PersonsCompanion data) {
    return PersonRow(
      id: data.id.present ? data.id.value : this.id,
      ledgerBookId: data.ledgerBookId.present
          ? data.ledgerBookId.value
          : this.ledgerBookId,
      name: data.name.present ? data.name.value : this.name,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      relationType: data.relationType.present
          ? data.relationType.value
          : this.relationType,
      relationLabel: data.relationLabel.present
          ? data.relationLabel.value
          : this.relationLabel,
      phone: data.phone.present ? data.phone.value : this.phone,
      avatar: data.avatar.present ? data.avatar.value : this.avatar,
      note: data.note.present ? data.note.value : this.note,
      birthdaySolar: data.birthdaySolar.present
          ? data.birthdaySolar.value
          : this.birthdaySolar,
      birthdayLunar: data.birthdayLunar.present
          ? data.birthdayLunar.value
          : this.birthdayLunar,
      isImportant: data.isImportant.present
          ? data.isImportant.value
          : this.isImportant,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonRow(')
          ..write('id: $id, ')
          ..write('ledgerBookId: $ledgerBookId, ')
          ..write('name: $name, ')
          ..write('nickname: $nickname, ')
          ..write('relationType: $relationType, ')
          ..write('relationLabel: $relationLabel, ')
          ..write('phone: $phone, ')
          ..write('avatar: $avatar, ')
          ..write('note: $note, ')
          ..write('birthdaySolar: $birthdaySolar, ')
          ..write('birthdayLunar: $birthdayLunar, ')
          ..write('isImportant: $isImportant, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ledgerBookId,
    name,
    nickname,
    relationType,
    relationLabel,
    phone,
    avatar,
    note,
    birthdaySolar,
    birthdayLunar,
    isImportant,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonRow &&
          other.id == this.id &&
          other.ledgerBookId == this.ledgerBookId &&
          other.name == this.name &&
          other.nickname == this.nickname &&
          other.relationType == this.relationType &&
          other.relationLabel == this.relationLabel &&
          other.phone == this.phone &&
          other.avatar == this.avatar &&
          other.note == this.note &&
          other.birthdaySolar == this.birthdaySolar &&
          other.birthdayLunar == this.birthdayLunar &&
          other.isImportant == this.isImportant &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PersonsCompanion extends UpdateCompanion<PersonRow> {
  final Value<String> id;
  final Value<String> ledgerBookId;
  final Value<String> name;
  final Value<String?> nickname;
  final Value<String?> relationType;
  final Value<String?> relationLabel;
  final Value<String?> phone;
  final Value<String?> avatar;
  final Value<String?> note;
  final Value<DateTime?> birthdaySolar;
  final Value<String?> birthdayLunar;
  final Value<bool> isImportant;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PersonsCompanion({
    this.id = const Value.absent(),
    this.ledgerBookId = const Value.absent(),
    this.name = const Value.absent(),
    this.nickname = const Value.absent(),
    this.relationType = const Value.absent(),
    this.relationLabel = const Value.absent(),
    this.phone = const Value.absent(),
    this.avatar = const Value.absent(),
    this.note = const Value.absent(),
    this.birthdaySolar = const Value.absent(),
    this.birthdayLunar = const Value.absent(),
    this.isImportant = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PersonsCompanion.insert({
    required String id,
    required String ledgerBookId,
    required String name,
    this.nickname = const Value.absent(),
    this.relationType = const Value.absent(),
    this.relationLabel = const Value.absent(),
    this.phone = const Value.absent(),
    this.avatar = const Value.absent(),
    this.note = const Value.absent(),
    this.birthdaySolar = const Value.absent(),
    this.birthdayLunar = const Value.absent(),
    this.isImportant = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ledgerBookId = Value(ledgerBookId),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PersonRow> custom({
    Expression<String>? id,
    Expression<String>? ledgerBookId,
    Expression<String>? name,
    Expression<String>? nickname,
    Expression<String>? relationType,
    Expression<String>? relationLabel,
    Expression<String>? phone,
    Expression<String>? avatar,
    Expression<String>? note,
    Expression<DateTime>? birthdaySolar,
    Expression<String>? birthdayLunar,
    Expression<bool>? isImportant,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ledgerBookId != null) 'ledger_book_id': ledgerBookId,
      if (name != null) 'name': name,
      if (nickname != null) 'nickname': nickname,
      if (relationType != null) 'relation_type': relationType,
      if (relationLabel != null) 'relation_label': relationLabel,
      if (phone != null) 'phone': phone,
      if (avatar != null) 'avatar': avatar,
      if (note != null) 'note': note,
      if (birthdaySolar != null) 'birthday_solar': birthdaySolar,
      if (birthdayLunar != null) 'birthday_lunar': birthdayLunar,
      if (isImportant != null) 'is_important': isImportant,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PersonsCompanion copyWith({
    Value<String>? id,
    Value<String>? ledgerBookId,
    Value<String>? name,
    Value<String?>? nickname,
    Value<String?>? relationType,
    Value<String?>? relationLabel,
    Value<String?>? phone,
    Value<String?>? avatar,
    Value<String?>? note,
    Value<DateTime?>? birthdaySolar,
    Value<String?>? birthdayLunar,
    Value<bool>? isImportant,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PersonsCompanion(
      id: id ?? this.id,
      ledgerBookId: ledgerBookId ?? this.ledgerBookId,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      relationType: relationType ?? this.relationType,
      relationLabel: relationLabel ?? this.relationLabel,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      note: note ?? this.note,
      birthdaySolar: birthdaySolar ?? this.birthdaySolar,
      birthdayLunar: birthdayLunar ?? this.birthdayLunar,
      isImportant: isImportant ?? this.isImportant,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ledgerBookId.present) {
      map['ledger_book_id'] = Variable<String>(ledgerBookId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (relationType.present) {
      map['relation_type'] = Variable<String>(relationType.value);
    }
    if (relationLabel.present) {
      map['relation_label'] = Variable<String>(relationLabel.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (avatar.present) {
      map['avatar'] = Variable<String>(avatar.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (birthdaySolar.present) {
      map['birthday_solar'] = Variable<DateTime>(birthdaySolar.value);
    }
    if (birthdayLunar.present) {
      map['birthday_lunar'] = Variable<String>(birthdayLunar.value);
    }
    if (isImportant.present) {
      map['is_important'] = Variable<bool>(isImportant.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonsCompanion(')
          ..write('id: $id, ')
          ..write('ledgerBookId: $ledgerBookId, ')
          ..write('name: $name, ')
          ..write('nickname: $nickname, ')
          ..write('relationType: $relationType, ')
          ..write('relationLabel: $relationLabel, ')
          ..write('phone: $phone, ')
          ..write('avatar: $avatar, ')
          ..write('note: $note, ')
          ..write('birthdaySolar: $birthdaySolar, ')
          ..write('birthdayLunar: $birthdayLunar, ')
          ..write('isImportant: $isImportant, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GiftRecordsTable extends GiftRecords
    with TableInfo<$GiftRecordsTable, GiftRecordRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GiftRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ledgerBookIdMeta = const VerificationMeta(
    'ledgerBookId',
  );
  @override
  late final GeneratedColumn<String> ledgerBookId = GeneratedColumn<String>(
    'ledger_book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES ledger_books (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _personIdMeta = const VerificationMeta(
    'personId',
  );
  @override
  late final GeneratedColumn<String> personId = GeneratedColumn<String>(
    'person_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES persons (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nicknameMeta = const VerificationMeta(
    'nickname',
  );
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
    'nickname',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _relationMeta = const VerificationMeta(
    'relation',
  );
  @override
  late final GeneratedColumn<String> relation = GeneratedColumn<String>(
    'relation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relationLabelMeta = const VerificationMeta(
    'relationLabel',
  );
  @override
  late final GeneratedColumn<String> relationLabel = GeneratedColumn<String>(
    'relation_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventToneMeta = const VerificationMeta(
    'eventTone',
  );
  @override
  late final GeneratedColumn<String> eventTone = GeneratedColumn<String>(
    'event_tone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordMethodMeta = const VerificationMeta(
    'recordMethod',
  );
  @override
  late final GeneratedColumn<String> recordMethod = GeneratedColumn<String>(
    'record_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estimatedAmountMeta = const VerificationMeta(
    'estimatedAmount',
  );
  @override
  late final GeneratedColumn<int> estimatedAmount = GeneratedColumn<int>(
    'estimated_amount',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _giftNameMeta = const VerificationMeta(
    'giftName',
  );
  @override
  late final GeneratedColumn<String> giftName = GeneratedColumn<String>(
    'gift_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serviceDescriptionMeta =
      const VerificationMeta('serviceDescription');
  @override
  late final GeneratedColumn<String> serviceDescription =
      GeneratedColumn<String>(
        'service_description',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _eventDateMeta = const VerificationMeta(
    'eventDate',
  );
  @override
  late final GeneratedColumn<DateTime> eventDate = GeneratedColumn<DateTime>(
    'event_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lunarDateMeta = const VerificationMeta(
    'lunarDate',
  );
  @override
  late final GeneratedColumn<String> lunarDate = GeneratedColumn<String>(
    'lunar_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _needReturnMeta = const VerificationMeta(
    'needReturn',
  );
  @override
  late final GeneratedColumn<bool> needReturn = GeneratedColumn<bool>(
    'need_return',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("need_return" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _returnedRecordIdMeta = const VerificationMeta(
    'returnedRecordId',
  );
  @override
  late final GeneratedColumn<String> returnedRecordId = GeneratedColumn<String>(
    'returned_record_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _entryModeMeta = const VerificationMeta(
    'entryMode',
  );
  @override
  late final GeneratedColumn<String> entryMode = GeneratedColumn<String>(
    'entry_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('normal'),
  );
  static const VerificationMeta _completionStatusMeta = const VerificationMeta(
    'completionStatus',
  );
  @override
  late final GeneratedColumn<String> completionStatus = GeneratedColumn<String>(
    'completion_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('complete'),
  );
  static const VerificationMeta _quickSceneMeta = const VerificationMeta(
    'quickScene',
  );
  @override
  late final GeneratedColumn<String> quickScene = GeneratedColumn<String>(
    'quick_scene',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tempRelationTextMeta = const VerificationMeta(
    'tempRelationText',
  );
  @override
  late final GeneratedColumn<String> tempRelationText = GeneratedColumn<String>(
    'temp_relation_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ledgerBookId,
    personId,
    name,
    nickname,
    relation,
    relationLabel,
    phone,
    eventType,
    direction,
    eventTone,
    recordMethod,
    amount,
    estimatedAmount,
    giftName,
    serviceDescription,
    eventDate,
    lunarDate,
    note,
    needReturn,
    returnedRecordId,
    entryMode,
    completionStatus,
    quickScene,
    tempRelationText,
    createdAt,
    updatedAt,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gift_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<GiftRecordRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('ledger_book_id')) {
      context.handle(
        _ledgerBookIdMeta,
        ledgerBookId.isAcceptableOrUnknown(
          data['ledger_book_id']!,
          _ledgerBookIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ledgerBookIdMeta);
    }
    if (data.containsKey('person_id')) {
      context.handle(
        _personIdMeta,
        personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('nickname')) {
      context.handle(
        _nicknameMeta,
        nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta),
      );
    }
    if (data.containsKey('relation')) {
      context.handle(
        _relationMeta,
        relation.isAcceptableOrUnknown(data['relation']!, _relationMeta),
      );
    } else if (isInserting) {
      context.missing(_relationMeta);
    }
    if (data.containsKey('relation_label')) {
      context.handle(
        _relationLabelMeta,
        relationLabel.isAcceptableOrUnknown(
          data['relation_label']!,
          _relationLabelMeta,
        ),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('event_tone')) {
      context.handle(
        _eventToneMeta,
        eventTone.isAcceptableOrUnknown(data['event_tone']!, _eventToneMeta),
      );
    } else if (isInserting) {
      context.missing(_eventToneMeta);
    }
    if (data.containsKey('record_method')) {
      context.handle(
        _recordMethodMeta,
        recordMethod.isAcceptableOrUnknown(
          data['record_method']!,
          _recordMethodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recordMethodMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('estimated_amount')) {
      context.handle(
        _estimatedAmountMeta,
        estimatedAmount.isAcceptableOrUnknown(
          data['estimated_amount']!,
          _estimatedAmountMeta,
        ),
      );
    }
    if (data.containsKey('gift_name')) {
      context.handle(
        _giftNameMeta,
        giftName.isAcceptableOrUnknown(data['gift_name']!, _giftNameMeta),
      );
    }
    if (data.containsKey('service_description')) {
      context.handle(
        _serviceDescriptionMeta,
        serviceDescription.isAcceptableOrUnknown(
          data['service_description']!,
          _serviceDescriptionMeta,
        ),
      );
    }
    if (data.containsKey('event_date')) {
      context.handle(
        _eventDateMeta,
        eventDate.isAcceptableOrUnknown(data['event_date']!, _eventDateMeta),
      );
    } else if (isInserting) {
      context.missing(_eventDateMeta);
    }
    if (data.containsKey('lunar_date')) {
      context.handle(
        _lunarDateMeta,
        lunarDate.isAcceptableOrUnknown(data['lunar_date']!, _lunarDateMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('need_return')) {
      context.handle(
        _needReturnMeta,
        needReturn.isAcceptableOrUnknown(data['need_return']!, _needReturnMeta),
      );
    }
    if (data.containsKey('returned_record_id')) {
      context.handle(
        _returnedRecordIdMeta,
        returnedRecordId.isAcceptableOrUnknown(
          data['returned_record_id']!,
          _returnedRecordIdMeta,
        ),
      );
    }
    if (data.containsKey('entry_mode')) {
      context.handle(
        _entryModeMeta,
        entryMode.isAcceptableOrUnknown(data['entry_mode']!, _entryModeMeta),
      );
    }
    if (data.containsKey('completion_status')) {
      context.handle(
        _completionStatusMeta,
        completionStatus.isAcceptableOrUnknown(
          data['completion_status']!,
          _completionStatusMeta,
        ),
      );
    }
    if (data.containsKey('quick_scene')) {
      context.handle(
        _quickSceneMeta,
        quickScene.isAcceptableOrUnknown(data['quick_scene']!, _quickSceneMeta),
      );
    }
    if (data.containsKey('temp_relation_text')) {
      context.handle(
        _tempRelationTextMeta,
        tempRelationText.isAcceptableOrUnknown(
          data['temp_relation_text']!,
          _tempRelationTextMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GiftRecordRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GiftRecordRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ledgerBookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ledger_book_id'],
      )!,
      personId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      nickname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nickname'],
      ),
      relation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relation'],
      )!,
      relationLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relation_label'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction'],
      )!,
      eventTone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_tone'],
      )!,
      recordMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_method'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      estimatedAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated_amount'],
      ),
      giftName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gift_name'],
      ),
      serviceDescription: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service_description'],
      ),
      eventDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}event_date'],
      )!,
      lunarDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lunar_date'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      needReturn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}need_return'],
      )!,
      returnedRecordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}returned_record_id'],
      ),
      entryMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_mode'],
      )!,
      completionStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}completion_status'],
      )!,
      quickScene: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quick_scene'],
      ),
      tempRelationText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}temp_relation_text'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $GiftRecordsTable createAlias(String alias) {
    return $GiftRecordsTable(attachedDatabase, alias);
  }
}

class GiftRecordRow extends DataClass implements Insertable<GiftRecordRow> {
  final String id;
  final String ledgerBookId;
  final String? personId;
  final String name;
  final String? nickname;
  final String relation;
  final String? relationLabel;
  final String? phone;
  final String eventType;
  final String direction;
  final String eventTone;
  final String recordMethod;
  final int amount;
  final int? estimatedAmount;
  final String? giftName;
  final String? serviceDescription;
  final DateTime eventDate;
  final String? lunarDate;
  final String? note;
  final bool needReturn;
  final String? returnedRecordId;
  final String entryMode;
  final String completionStatus;
  final String? quickScene;
  final String? tempRelationText;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  const GiftRecordRow({
    required this.id,
    required this.ledgerBookId,
    this.personId,
    required this.name,
    this.nickname,
    required this.relation,
    this.relationLabel,
    this.phone,
    required this.eventType,
    required this.direction,
    required this.eventTone,
    required this.recordMethod,
    required this.amount,
    this.estimatedAmount,
    this.giftName,
    this.serviceDescription,
    required this.eventDate,
    this.lunarDate,
    this.note,
    required this.needReturn,
    this.returnedRecordId,
    required this.entryMode,
    required this.completionStatus,
    this.quickScene,
    this.tempRelationText,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['ledger_book_id'] = Variable<String>(ledgerBookId);
    if (!nullToAbsent || personId != null) {
      map['person_id'] = Variable<String>(personId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || nickname != null) {
      map['nickname'] = Variable<String>(nickname);
    }
    map['relation'] = Variable<String>(relation);
    if (!nullToAbsent || relationLabel != null) {
      map['relation_label'] = Variable<String>(relationLabel);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['event_type'] = Variable<String>(eventType);
    map['direction'] = Variable<String>(direction);
    map['event_tone'] = Variable<String>(eventTone);
    map['record_method'] = Variable<String>(recordMethod);
    map['amount'] = Variable<int>(amount);
    if (!nullToAbsent || estimatedAmount != null) {
      map['estimated_amount'] = Variable<int>(estimatedAmount);
    }
    if (!nullToAbsent || giftName != null) {
      map['gift_name'] = Variable<String>(giftName);
    }
    if (!nullToAbsent || serviceDescription != null) {
      map['service_description'] = Variable<String>(serviceDescription);
    }
    map['event_date'] = Variable<DateTime>(eventDate);
    if (!nullToAbsent || lunarDate != null) {
      map['lunar_date'] = Variable<String>(lunarDate);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['need_return'] = Variable<bool>(needReturn);
    if (!nullToAbsent || returnedRecordId != null) {
      map['returned_record_id'] = Variable<String>(returnedRecordId);
    }
    map['entry_mode'] = Variable<String>(entryMode);
    map['completion_status'] = Variable<String>(completionStatus);
    if (!nullToAbsent || quickScene != null) {
      map['quick_scene'] = Variable<String>(quickScene);
    }
    if (!nullToAbsent || tempRelationText != null) {
      map['temp_relation_text'] = Variable<String>(tempRelationText);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  GiftRecordsCompanion toCompanion(bool nullToAbsent) {
    return GiftRecordsCompanion(
      id: Value(id),
      ledgerBookId: Value(ledgerBookId),
      personId: personId == null && nullToAbsent
          ? const Value.absent()
          : Value(personId),
      name: Value(name),
      nickname: nickname == null && nullToAbsent
          ? const Value.absent()
          : Value(nickname),
      relation: Value(relation),
      relationLabel: relationLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(relationLabel),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      eventType: Value(eventType),
      direction: Value(direction),
      eventTone: Value(eventTone),
      recordMethod: Value(recordMethod),
      amount: Value(amount),
      estimatedAmount: estimatedAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedAmount),
      giftName: giftName == null && nullToAbsent
          ? const Value.absent()
          : Value(giftName),
      serviceDescription: serviceDescription == null && nullToAbsent
          ? const Value.absent()
          : Value(serviceDescription),
      eventDate: Value(eventDate),
      lunarDate: lunarDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lunarDate),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      needReturn: Value(needReturn),
      returnedRecordId: returnedRecordId == null && nullToAbsent
          ? const Value.absent()
          : Value(returnedRecordId),
      entryMode: Value(entryMode),
      completionStatus: Value(completionStatus),
      quickScene: quickScene == null && nullToAbsent
          ? const Value.absent()
          : Value(quickScene),
      tempRelationText: tempRelationText == null && nullToAbsent
          ? const Value.absent()
          : Value(tempRelationText),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory GiftRecordRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GiftRecordRow(
      id: serializer.fromJson<String>(json['id']),
      ledgerBookId: serializer.fromJson<String>(json['ledgerBookId']),
      personId: serializer.fromJson<String?>(json['personId']),
      name: serializer.fromJson<String>(json['name']),
      nickname: serializer.fromJson<String?>(json['nickname']),
      relation: serializer.fromJson<String>(json['relation']),
      relationLabel: serializer.fromJson<String?>(json['relationLabel']),
      phone: serializer.fromJson<String?>(json['phone']),
      eventType: serializer.fromJson<String>(json['eventType']),
      direction: serializer.fromJson<String>(json['direction']),
      eventTone: serializer.fromJson<String>(json['eventTone']),
      recordMethod: serializer.fromJson<String>(json['recordMethod']),
      amount: serializer.fromJson<int>(json['amount']),
      estimatedAmount: serializer.fromJson<int?>(json['estimatedAmount']),
      giftName: serializer.fromJson<String?>(json['giftName']),
      serviceDescription: serializer.fromJson<String?>(
        json['serviceDescription'],
      ),
      eventDate: serializer.fromJson<DateTime>(json['eventDate']),
      lunarDate: serializer.fromJson<String?>(json['lunarDate']),
      note: serializer.fromJson<String?>(json['note']),
      needReturn: serializer.fromJson<bool>(json['needReturn']),
      returnedRecordId: serializer.fromJson<String?>(json['returnedRecordId']),
      entryMode: serializer.fromJson<String>(json['entryMode']),
      completionStatus: serializer.fromJson<String>(json['completionStatus']),
      quickScene: serializer.fromJson<String?>(json['quickScene']),
      tempRelationText: serializer.fromJson<String?>(json['tempRelationText']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ledgerBookId': serializer.toJson<String>(ledgerBookId),
      'personId': serializer.toJson<String?>(personId),
      'name': serializer.toJson<String>(name),
      'nickname': serializer.toJson<String?>(nickname),
      'relation': serializer.toJson<String>(relation),
      'relationLabel': serializer.toJson<String?>(relationLabel),
      'phone': serializer.toJson<String?>(phone),
      'eventType': serializer.toJson<String>(eventType),
      'direction': serializer.toJson<String>(direction),
      'eventTone': serializer.toJson<String>(eventTone),
      'recordMethod': serializer.toJson<String>(recordMethod),
      'amount': serializer.toJson<int>(amount),
      'estimatedAmount': serializer.toJson<int?>(estimatedAmount),
      'giftName': serializer.toJson<String?>(giftName),
      'serviceDescription': serializer.toJson<String?>(serviceDescription),
      'eventDate': serializer.toJson<DateTime>(eventDate),
      'lunarDate': serializer.toJson<String?>(lunarDate),
      'note': serializer.toJson<String?>(note),
      'needReturn': serializer.toJson<bool>(needReturn),
      'returnedRecordId': serializer.toJson<String?>(returnedRecordId),
      'entryMode': serializer.toJson<String>(entryMode),
      'completionStatus': serializer.toJson<String>(completionStatus),
      'quickScene': serializer.toJson<String?>(quickScene),
      'tempRelationText': serializer.toJson<String?>(tempRelationText),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  GiftRecordRow copyWith({
    String? id,
    String? ledgerBookId,
    Value<String?> personId = const Value.absent(),
    String? name,
    Value<String?> nickname = const Value.absent(),
    String? relation,
    Value<String?> relationLabel = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    String? eventType,
    String? direction,
    String? eventTone,
    String? recordMethod,
    int? amount,
    Value<int?> estimatedAmount = const Value.absent(),
    Value<String?> giftName = const Value.absent(),
    Value<String?> serviceDescription = const Value.absent(),
    DateTime? eventDate,
    Value<String?> lunarDate = const Value.absent(),
    Value<String?> note = const Value.absent(),
    bool? needReturn,
    Value<String?> returnedRecordId = const Value.absent(),
    String? entryMode,
    String? completionStatus,
    Value<String?> quickScene = const Value.absent(),
    Value<String?> tempRelationText = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) => GiftRecordRow(
    id: id ?? this.id,
    ledgerBookId: ledgerBookId ?? this.ledgerBookId,
    personId: personId.present ? personId.value : this.personId,
    name: name ?? this.name,
    nickname: nickname.present ? nickname.value : this.nickname,
    relation: relation ?? this.relation,
    relationLabel: relationLabel.present
        ? relationLabel.value
        : this.relationLabel,
    phone: phone.present ? phone.value : this.phone,
    eventType: eventType ?? this.eventType,
    direction: direction ?? this.direction,
    eventTone: eventTone ?? this.eventTone,
    recordMethod: recordMethod ?? this.recordMethod,
    amount: amount ?? this.amount,
    estimatedAmount: estimatedAmount.present
        ? estimatedAmount.value
        : this.estimatedAmount,
    giftName: giftName.present ? giftName.value : this.giftName,
    serviceDescription: serviceDescription.present
        ? serviceDescription.value
        : this.serviceDescription,
    eventDate: eventDate ?? this.eventDate,
    lunarDate: lunarDate.present ? lunarDate.value : this.lunarDate,
    note: note.present ? note.value : this.note,
    needReturn: needReturn ?? this.needReturn,
    returnedRecordId: returnedRecordId.present
        ? returnedRecordId.value
        : this.returnedRecordId,
    entryMode: entryMode ?? this.entryMode,
    completionStatus: completionStatus ?? this.completionStatus,
    quickScene: quickScene.present ? quickScene.value : this.quickScene,
    tempRelationText: tempRelationText.present
        ? tempRelationText.value
        : this.tempRelationText,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  GiftRecordRow copyWithCompanion(GiftRecordsCompanion data) {
    return GiftRecordRow(
      id: data.id.present ? data.id.value : this.id,
      ledgerBookId: data.ledgerBookId.present
          ? data.ledgerBookId.value
          : this.ledgerBookId,
      personId: data.personId.present ? data.personId.value : this.personId,
      name: data.name.present ? data.name.value : this.name,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      relation: data.relation.present ? data.relation.value : this.relation,
      relationLabel: data.relationLabel.present
          ? data.relationLabel.value
          : this.relationLabel,
      phone: data.phone.present ? data.phone.value : this.phone,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      direction: data.direction.present ? data.direction.value : this.direction,
      eventTone: data.eventTone.present ? data.eventTone.value : this.eventTone,
      recordMethod: data.recordMethod.present
          ? data.recordMethod.value
          : this.recordMethod,
      amount: data.amount.present ? data.amount.value : this.amount,
      estimatedAmount: data.estimatedAmount.present
          ? data.estimatedAmount.value
          : this.estimatedAmount,
      giftName: data.giftName.present ? data.giftName.value : this.giftName,
      serviceDescription: data.serviceDescription.present
          ? data.serviceDescription.value
          : this.serviceDescription,
      eventDate: data.eventDate.present ? data.eventDate.value : this.eventDate,
      lunarDate: data.lunarDate.present ? data.lunarDate.value : this.lunarDate,
      note: data.note.present ? data.note.value : this.note,
      needReturn: data.needReturn.present
          ? data.needReturn.value
          : this.needReturn,
      returnedRecordId: data.returnedRecordId.present
          ? data.returnedRecordId.value
          : this.returnedRecordId,
      entryMode: data.entryMode.present ? data.entryMode.value : this.entryMode,
      completionStatus: data.completionStatus.present
          ? data.completionStatus.value
          : this.completionStatus,
      quickScene: data.quickScene.present
          ? data.quickScene.value
          : this.quickScene,
      tempRelationText: data.tempRelationText.present
          ? data.tempRelationText.value
          : this.tempRelationText,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GiftRecordRow(')
          ..write('id: $id, ')
          ..write('ledgerBookId: $ledgerBookId, ')
          ..write('personId: $personId, ')
          ..write('name: $name, ')
          ..write('nickname: $nickname, ')
          ..write('relation: $relation, ')
          ..write('relationLabel: $relationLabel, ')
          ..write('phone: $phone, ')
          ..write('eventType: $eventType, ')
          ..write('direction: $direction, ')
          ..write('eventTone: $eventTone, ')
          ..write('recordMethod: $recordMethod, ')
          ..write('amount: $amount, ')
          ..write('estimatedAmount: $estimatedAmount, ')
          ..write('giftName: $giftName, ')
          ..write('serviceDescription: $serviceDescription, ')
          ..write('eventDate: $eventDate, ')
          ..write('lunarDate: $lunarDate, ')
          ..write('note: $note, ')
          ..write('needReturn: $needReturn, ')
          ..write('returnedRecordId: $returnedRecordId, ')
          ..write('entryMode: $entryMode, ')
          ..write('completionStatus: $completionStatus, ')
          ..write('quickScene: $quickScene, ')
          ..write('tempRelationText: $tempRelationText, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    ledgerBookId,
    personId,
    name,
    nickname,
    relation,
    relationLabel,
    phone,
    eventType,
    direction,
    eventTone,
    recordMethod,
    amount,
    estimatedAmount,
    giftName,
    serviceDescription,
    eventDate,
    lunarDate,
    note,
    needReturn,
    returnedRecordId,
    entryMode,
    completionStatus,
    quickScene,
    tempRelationText,
    createdAt,
    updatedAt,
    isDeleted,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GiftRecordRow &&
          other.id == this.id &&
          other.ledgerBookId == this.ledgerBookId &&
          other.personId == this.personId &&
          other.name == this.name &&
          other.nickname == this.nickname &&
          other.relation == this.relation &&
          other.relationLabel == this.relationLabel &&
          other.phone == this.phone &&
          other.eventType == this.eventType &&
          other.direction == this.direction &&
          other.eventTone == this.eventTone &&
          other.recordMethod == this.recordMethod &&
          other.amount == this.amount &&
          other.estimatedAmount == this.estimatedAmount &&
          other.giftName == this.giftName &&
          other.serviceDescription == this.serviceDescription &&
          other.eventDate == this.eventDate &&
          other.lunarDate == this.lunarDate &&
          other.note == this.note &&
          other.needReturn == this.needReturn &&
          other.returnedRecordId == this.returnedRecordId &&
          other.entryMode == this.entryMode &&
          other.completionStatus == this.completionStatus &&
          other.quickScene == this.quickScene &&
          other.tempRelationText == this.tempRelationText &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted);
}

class GiftRecordsCompanion extends UpdateCompanion<GiftRecordRow> {
  final Value<String> id;
  final Value<String> ledgerBookId;
  final Value<String?> personId;
  final Value<String> name;
  final Value<String?> nickname;
  final Value<String> relation;
  final Value<String?> relationLabel;
  final Value<String?> phone;
  final Value<String> eventType;
  final Value<String> direction;
  final Value<String> eventTone;
  final Value<String> recordMethod;
  final Value<int> amount;
  final Value<int?> estimatedAmount;
  final Value<String?> giftName;
  final Value<String?> serviceDescription;
  final Value<DateTime> eventDate;
  final Value<String?> lunarDate;
  final Value<String?> note;
  final Value<bool> needReturn;
  final Value<String?> returnedRecordId;
  final Value<String> entryMode;
  final Value<String> completionStatus;
  final Value<String?> quickScene;
  final Value<String?> tempRelationText;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const GiftRecordsCompanion({
    this.id = const Value.absent(),
    this.ledgerBookId = const Value.absent(),
    this.personId = const Value.absent(),
    this.name = const Value.absent(),
    this.nickname = const Value.absent(),
    this.relation = const Value.absent(),
    this.relationLabel = const Value.absent(),
    this.phone = const Value.absent(),
    this.eventType = const Value.absent(),
    this.direction = const Value.absent(),
    this.eventTone = const Value.absent(),
    this.recordMethod = const Value.absent(),
    this.amount = const Value.absent(),
    this.estimatedAmount = const Value.absent(),
    this.giftName = const Value.absent(),
    this.serviceDescription = const Value.absent(),
    this.eventDate = const Value.absent(),
    this.lunarDate = const Value.absent(),
    this.note = const Value.absent(),
    this.needReturn = const Value.absent(),
    this.returnedRecordId = const Value.absent(),
    this.entryMode = const Value.absent(),
    this.completionStatus = const Value.absent(),
    this.quickScene = const Value.absent(),
    this.tempRelationText = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GiftRecordsCompanion.insert({
    required String id,
    required String ledgerBookId,
    this.personId = const Value.absent(),
    required String name,
    this.nickname = const Value.absent(),
    required String relation,
    this.relationLabel = const Value.absent(),
    this.phone = const Value.absent(),
    required String eventType,
    required String direction,
    required String eventTone,
    required String recordMethod,
    required int amount,
    this.estimatedAmount = const Value.absent(),
    this.giftName = const Value.absent(),
    this.serviceDescription = const Value.absent(),
    required DateTime eventDate,
    this.lunarDate = const Value.absent(),
    this.note = const Value.absent(),
    this.needReturn = const Value.absent(),
    this.returnedRecordId = const Value.absent(),
    this.entryMode = const Value.absent(),
    this.completionStatus = const Value.absent(),
    this.quickScene = const Value.absent(),
    this.tempRelationText = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ledgerBookId = Value(ledgerBookId),
       name = Value(name),
       relation = Value(relation),
       eventType = Value(eventType),
       direction = Value(direction),
       eventTone = Value(eventTone),
       recordMethod = Value(recordMethod),
       amount = Value(amount),
       eventDate = Value(eventDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<GiftRecordRow> custom({
    Expression<String>? id,
    Expression<String>? ledgerBookId,
    Expression<String>? personId,
    Expression<String>? name,
    Expression<String>? nickname,
    Expression<String>? relation,
    Expression<String>? relationLabel,
    Expression<String>? phone,
    Expression<String>? eventType,
    Expression<String>? direction,
    Expression<String>? eventTone,
    Expression<String>? recordMethod,
    Expression<int>? amount,
    Expression<int>? estimatedAmount,
    Expression<String>? giftName,
    Expression<String>? serviceDescription,
    Expression<DateTime>? eventDate,
    Expression<String>? lunarDate,
    Expression<String>? note,
    Expression<bool>? needReturn,
    Expression<String>? returnedRecordId,
    Expression<String>? entryMode,
    Expression<String>? completionStatus,
    Expression<String>? quickScene,
    Expression<String>? tempRelationText,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ledgerBookId != null) 'ledger_book_id': ledgerBookId,
      if (personId != null) 'person_id': personId,
      if (name != null) 'name': name,
      if (nickname != null) 'nickname': nickname,
      if (relation != null) 'relation': relation,
      if (relationLabel != null) 'relation_label': relationLabel,
      if (phone != null) 'phone': phone,
      if (eventType != null) 'event_type': eventType,
      if (direction != null) 'direction': direction,
      if (eventTone != null) 'event_tone': eventTone,
      if (recordMethod != null) 'record_method': recordMethod,
      if (amount != null) 'amount': amount,
      if (estimatedAmount != null) 'estimated_amount': estimatedAmount,
      if (giftName != null) 'gift_name': giftName,
      if (serviceDescription != null) 'service_description': serviceDescription,
      if (eventDate != null) 'event_date': eventDate,
      if (lunarDate != null) 'lunar_date': lunarDate,
      if (note != null) 'note': note,
      if (needReturn != null) 'need_return': needReturn,
      if (returnedRecordId != null) 'returned_record_id': returnedRecordId,
      if (entryMode != null) 'entry_mode': entryMode,
      if (completionStatus != null) 'completion_status': completionStatus,
      if (quickScene != null) 'quick_scene': quickScene,
      if (tempRelationText != null) 'temp_relation_text': tempRelationText,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GiftRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? ledgerBookId,
    Value<String?>? personId,
    Value<String>? name,
    Value<String?>? nickname,
    Value<String>? relation,
    Value<String?>? relationLabel,
    Value<String?>? phone,
    Value<String>? eventType,
    Value<String>? direction,
    Value<String>? eventTone,
    Value<String>? recordMethod,
    Value<int>? amount,
    Value<int?>? estimatedAmount,
    Value<String?>? giftName,
    Value<String?>? serviceDescription,
    Value<DateTime>? eventDate,
    Value<String?>? lunarDate,
    Value<String?>? note,
    Value<bool>? needReturn,
    Value<String?>? returnedRecordId,
    Value<String>? entryMode,
    Value<String>? completionStatus,
    Value<String?>? quickScene,
    Value<String?>? tempRelationText,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return GiftRecordsCompanion(
      id: id ?? this.id,
      ledgerBookId: ledgerBookId ?? this.ledgerBookId,
      personId: personId ?? this.personId,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      relation: relation ?? this.relation,
      relationLabel: relationLabel ?? this.relationLabel,
      phone: phone ?? this.phone,
      eventType: eventType ?? this.eventType,
      direction: direction ?? this.direction,
      eventTone: eventTone ?? this.eventTone,
      recordMethod: recordMethod ?? this.recordMethod,
      amount: amount ?? this.amount,
      estimatedAmount: estimatedAmount ?? this.estimatedAmount,
      giftName: giftName ?? this.giftName,
      serviceDescription: serviceDescription ?? this.serviceDescription,
      eventDate: eventDate ?? this.eventDate,
      lunarDate: lunarDate ?? this.lunarDate,
      note: note ?? this.note,
      needReturn: needReturn ?? this.needReturn,
      returnedRecordId: returnedRecordId ?? this.returnedRecordId,
      entryMode: entryMode ?? this.entryMode,
      completionStatus: completionStatus ?? this.completionStatus,
      quickScene: quickScene ?? this.quickScene,
      tempRelationText: tempRelationText ?? this.tempRelationText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ledgerBookId.present) {
      map['ledger_book_id'] = Variable<String>(ledgerBookId.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<String>(personId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (relation.present) {
      map['relation'] = Variable<String>(relation.value);
    }
    if (relationLabel.present) {
      map['relation_label'] = Variable<String>(relationLabel.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (eventTone.present) {
      map['event_tone'] = Variable<String>(eventTone.value);
    }
    if (recordMethod.present) {
      map['record_method'] = Variable<String>(recordMethod.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (estimatedAmount.present) {
      map['estimated_amount'] = Variable<int>(estimatedAmount.value);
    }
    if (giftName.present) {
      map['gift_name'] = Variable<String>(giftName.value);
    }
    if (serviceDescription.present) {
      map['service_description'] = Variable<String>(serviceDescription.value);
    }
    if (eventDate.present) {
      map['event_date'] = Variable<DateTime>(eventDate.value);
    }
    if (lunarDate.present) {
      map['lunar_date'] = Variable<String>(lunarDate.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (needReturn.present) {
      map['need_return'] = Variable<bool>(needReturn.value);
    }
    if (returnedRecordId.present) {
      map['returned_record_id'] = Variable<String>(returnedRecordId.value);
    }
    if (entryMode.present) {
      map['entry_mode'] = Variable<String>(entryMode.value);
    }
    if (completionStatus.present) {
      map['completion_status'] = Variable<String>(completionStatus.value);
    }
    if (quickScene.present) {
      map['quick_scene'] = Variable<String>(quickScene.value);
    }
    if (tempRelationText.present) {
      map['temp_relation_text'] = Variable<String>(tempRelationText.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GiftRecordsCompanion(')
          ..write('id: $id, ')
          ..write('ledgerBookId: $ledgerBookId, ')
          ..write('personId: $personId, ')
          ..write('name: $name, ')
          ..write('nickname: $nickname, ')
          ..write('relation: $relation, ')
          ..write('relationLabel: $relationLabel, ')
          ..write('phone: $phone, ')
          ..write('eventType: $eventType, ')
          ..write('direction: $direction, ')
          ..write('eventTone: $eventTone, ')
          ..write('recordMethod: $recordMethod, ')
          ..write('amount: $amount, ')
          ..write('estimatedAmount: $estimatedAmount, ')
          ..write('giftName: $giftName, ')
          ..write('serviceDescription: $serviceDescription, ')
          ..write('eventDate: $eventDate, ')
          ..write('lunarDate: $lunarDate, ')
          ..write('note: $note, ')
          ..write('needReturn: $needReturn, ')
          ..write('returnedRecordId: $returnedRecordId, ')
          ..write('entryMode: $entryMode, ')
          ..write('completionStatus: $completionStatus, ')
          ..write('quickScene: $quickScene, ')
          ..write('tempRelationText: $tempRelationText, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RemindersTable extends Reminders
    with TableInfo<$RemindersTable, ReminderRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ledgerBookIdMeta = const VerificationMeta(
    'ledgerBookId',
  );
  @override
  late final GeneratedColumn<String> ledgerBookId = GeneratedColumn<String>(
    'ledger_book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES ledger_books (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _personIdMeta = const VerificationMeta(
    'personId',
  );
  @override
  late final GeneratedColumn<String> personId = GeneratedColumn<String>(
    'person_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _relatedRecordIdMeta = const VerificationMeta(
    'relatedRecordId',
  );
  @override
  late final GeneratedColumn<String> relatedRecordId = GeneratedColumn<String>(
    'related_record_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remindAtMeta = const VerificationMeta(
    'remindAt',
  );
  @override
  late final GeneratedColumn<DateTime> remindAt = GeneratedColumn<DateTime>(
    'remind_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ledgerBookId,
    personId,
    relatedRecordId,
    type,
    title,
    date,
    remindAt,
    status,
    note,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReminderRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('ledger_book_id')) {
      context.handle(
        _ledgerBookIdMeta,
        ledgerBookId.isAcceptableOrUnknown(
          data['ledger_book_id']!,
          _ledgerBookIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ledgerBookIdMeta);
    }
    if (data.containsKey('person_id')) {
      context.handle(
        _personIdMeta,
        personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta),
      );
    }
    if (data.containsKey('related_record_id')) {
      context.handle(
        _relatedRecordIdMeta,
        relatedRecordId.isAcceptableOrUnknown(
          data['related_record_id']!,
          _relatedRecordIdMeta,
        ),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('remind_at')) {
      context.handle(
        _remindAtMeta,
        remindAt.isAcceptableOrUnknown(data['remind_at']!, _remindAtMeta),
      );
    } else if (isInserting) {
      context.missing(_remindAtMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReminderRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ledgerBookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ledger_book_id'],
      )!,
      personId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person_id'],
      ),
      relatedRecordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}related_record_id'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      remindAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}remind_at'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }
}

class ReminderRow extends DataClass implements Insertable<ReminderRow> {
  final String id;
  final String ledgerBookId;
  final String? personId;
  final String? relatedRecordId;
  final String type;
  final String title;
  final DateTime date;
  final DateTime remindAt;
  final String status;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ReminderRow({
    required this.id,
    required this.ledgerBookId,
    this.personId,
    this.relatedRecordId,
    required this.type,
    required this.title,
    required this.date,
    required this.remindAt,
    required this.status,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['ledger_book_id'] = Variable<String>(ledgerBookId);
    if (!nullToAbsent || personId != null) {
      map['person_id'] = Variable<String>(personId);
    }
    if (!nullToAbsent || relatedRecordId != null) {
      map['related_record_id'] = Variable<String>(relatedRecordId);
    }
    map['type'] = Variable<String>(type);
    map['title'] = Variable<String>(title);
    map['date'] = Variable<DateTime>(date);
    map['remind_at'] = Variable<DateTime>(remindAt);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      id: Value(id),
      ledgerBookId: Value(ledgerBookId),
      personId: personId == null && nullToAbsent
          ? const Value.absent()
          : Value(personId),
      relatedRecordId: relatedRecordId == null && nullToAbsent
          ? const Value.absent()
          : Value(relatedRecordId),
      type: Value(type),
      title: Value(title),
      date: Value(date),
      remindAt: Value(remindAt),
      status: Value(status),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ReminderRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderRow(
      id: serializer.fromJson<String>(json['id']),
      ledgerBookId: serializer.fromJson<String>(json['ledgerBookId']),
      personId: serializer.fromJson<String?>(json['personId']),
      relatedRecordId: serializer.fromJson<String?>(json['relatedRecordId']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String>(json['title']),
      date: serializer.fromJson<DateTime>(json['date']),
      remindAt: serializer.fromJson<DateTime>(json['remindAt']),
      status: serializer.fromJson<String>(json['status']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ledgerBookId': serializer.toJson<String>(ledgerBookId),
      'personId': serializer.toJson<String?>(personId),
      'relatedRecordId': serializer.toJson<String?>(relatedRecordId),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String>(title),
      'date': serializer.toJson<DateTime>(date),
      'remindAt': serializer.toJson<DateTime>(remindAt),
      'status': serializer.toJson<String>(status),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ReminderRow copyWith({
    String? id,
    String? ledgerBookId,
    Value<String?> personId = const Value.absent(),
    Value<String?> relatedRecordId = const Value.absent(),
    String? type,
    String? title,
    DateTime? date,
    DateTime? remindAt,
    String? status,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ReminderRow(
    id: id ?? this.id,
    ledgerBookId: ledgerBookId ?? this.ledgerBookId,
    personId: personId.present ? personId.value : this.personId,
    relatedRecordId: relatedRecordId.present
        ? relatedRecordId.value
        : this.relatedRecordId,
    type: type ?? this.type,
    title: title ?? this.title,
    date: date ?? this.date,
    remindAt: remindAt ?? this.remindAt,
    status: status ?? this.status,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ReminderRow copyWithCompanion(RemindersCompanion data) {
    return ReminderRow(
      id: data.id.present ? data.id.value : this.id,
      ledgerBookId: data.ledgerBookId.present
          ? data.ledgerBookId.value
          : this.ledgerBookId,
      personId: data.personId.present ? data.personId.value : this.personId,
      relatedRecordId: data.relatedRecordId.present
          ? data.relatedRecordId.value
          : this.relatedRecordId,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      date: data.date.present ? data.date.value : this.date,
      remindAt: data.remindAt.present ? data.remindAt.value : this.remindAt,
      status: data.status.present ? data.status.value : this.status,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderRow(')
          ..write('id: $id, ')
          ..write('ledgerBookId: $ledgerBookId, ')
          ..write('personId: $personId, ')
          ..write('relatedRecordId: $relatedRecordId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('date: $date, ')
          ..write('remindAt: $remindAt, ')
          ..write('status: $status, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ledgerBookId,
    personId,
    relatedRecordId,
    type,
    title,
    date,
    remindAt,
    status,
    note,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderRow &&
          other.id == this.id &&
          other.ledgerBookId == this.ledgerBookId &&
          other.personId == this.personId &&
          other.relatedRecordId == this.relatedRecordId &&
          other.type == this.type &&
          other.title == this.title &&
          other.date == this.date &&
          other.remindAt == this.remindAt &&
          other.status == this.status &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RemindersCompanion extends UpdateCompanion<ReminderRow> {
  final Value<String> id;
  final Value<String> ledgerBookId;
  final Value<String?> personId;
  final Value<String?> relatedRecordId;
  final Value<String> type;
  final Value<String> title;
  final Value<DateTime> date;
  final Value<DateTime> remindAt;
  final Value<String> status;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const RemindersCompanion({
    this.id = const Value.absent(),
    this.ledgerBookId = const Value.absent(),
    this.personId = const Value.absent(),
    this.relatedRecordId = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.date = const Value.absent(),
    this.remindAt = const Value.absent(),
    this.status = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RemindersCompanion.insert({
    required String id,
    required String ledgerBookId,
    this.personId = const Value.absent(),
    this.relatedRecordId = const Value.absent(),
    required String type,
    required String title,
    required DateTime date,
    required DateTime remindAt,
    this.status = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ledgerBookId = Value(ledgerBookId),
       type = Value(type),
       title = Value(title),
       date = Value(date),
       remindAt = Value(remindAt),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ReminderRow> custom({
    Expression<String>? id,
    Expression<String>? ledgerBookId,
    Expression<String>? personId,
    Expression<String>? relatedRecordId,
    Expression<String>? type,
    Expression<String>? title,
    Expression<DateTime>? date,
    Expression<DateTime>? remindAt,
    Expression<String>? status,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ledgerBookId != null) 'ledger_book_id': ledgerBookId,
      if (personId != null) 'person_id': personId,
      if (relatedRecordId != null) 'related_record_id': relatedRecordId,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (date != null) 'date': date,
      if (remindAt != null) 'remind_at': remindAt,
      if (status != null) 'status': status,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RemindersCompanion copyWith({
    Value<String>? id,
    Value<String>? ledgerBookId,
    Value<String?>? personId,
    Value<String?>? relatedRecordId,
    Value<String>? type,
    Value<String>? title,
    Value<DateTime>? date,
    Value<DateTime>? remindAt,
    Value<String>? status,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return RemindersCompanion(
      id: id ?? this.id,
      ledgerBookId: ledgerBookId ?? this.ledgerBookId,
      personId: personId ?? this.personId,
      relatedRecordId: relatedRecordId ?? this.relatedRecordId,
      type: type ?? this.type,
      title: title ?? this.title,
      date: date ?? this.date,
      remindAt: remindAt ?? this.remindAt,
      status: status ?? this.status,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ledgerBookId.present) {
      map['ledger_book_id'] = Variable<String>(ledgerBookId.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<String>(personId.value);
    }
    if (relatedRecordId.present) {
      map['related_record_id'] = Variable<String>(relatedRecordId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (remindAt.present) {
      map['remind_at'] = Variable<DateTime>(remindAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('id: $id, ')
          ..write('ledgerBookId: $ledgerBookId, ')
          ..write('personId: $personId, ')
          ..write('relatedRecordId: $relatedRecordId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('date: $date, ')
          ..write('remindAt: $remindAt, ')
          ..write('status: $status, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GiftTemplatesTable extends GiftTemplates
    with TableInfo<$GiftTemplatesTable, GiftTemplateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GiftTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relationTypeMeta = const VerificationMeta(
    'relationType',
  );
  @override
  late final GeneratedColumn<String> relationType = GeneratedColumn<String>(
    'relation_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defaultAmountMeta = const VerificationMeta(
    'defaultAmount',
  );
  @override
  late final GeneratedColumn<int> defaultAmount = GeneratedColumn<int>(
    'default_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteTemplateMeta = const VerificationMeta(
    'noteTemplate',
  );
  @override
  late final GeneratedColumn<String> noteTemplate = GeneratedColumn<String>(
    'note_template',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSystemMeta = const VerificationMeta(
    'isSystem',
  );
  @override
  late final GeneratedColumn<bool> isSystem = GeneratedColumn<bool>(
    'is_system',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_system" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    eventType,
    relationType,
    defaultAmount,
    noteTemplate,
    isSystem,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gift_templates';
  @override
  VerificationContext validateIntegrity(
    Insertable<GiftTemplateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('relation_type')) {
      context.handle(
        _relationTypeMeta,
        relationType.isAcceptableOrUnknown(
          data['relation_type']!,
          _relationTypeMeta,
        ),
      );
    }
    if (data.containsKey('default_amount')) {
      context.handle(
        _defaultAmountMeta,
        defaultAmount.isAcceptableOrUnknown(
          data['default_amount']!,
          _defaultAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_defaultAmountMeta);
    }
    if (data.containsKey('note_template')) {
      context.handle(
        _noteTemplateMeta,
        noteTemplate.isAcceptableOrUnknown(
          data['note_template']!,
          _noteTemplateMeta,
        ),
      );
    }
    if (data.containsKey('is_system')) {
      context.handle(
        _isSystemMeta,
        isSystem.isAcceptableOrUnknown(data['is_system']!, _isSystemMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GiftTemplateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GiftTemplateRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      relationType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relation_type'],
      ),
      defaultAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_amount'],
      )!,
      noteTemplate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_template'],
      ),
      isSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_system'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $GiftTemplatesTable createAlias(String alias) {
    return $GiftTemplatesTable(attachedDatabase, alias);
  }
}

class GiftTemplateRow extends DataClass implements Insertable<GiftTemplateRow> {
  final String id;
  final String name;
  final String eventType;
  final String? relationType;
  final int defaultAmount;
  final String? noteTemplate;
  final bool isSystem;
  final DateTime createdAt;
  final DateTime updatedAt;
  const GiftTemplateRow({
    required this.id,
    required this.name,
    required this.eventType,
    this.relationType,
    required this.defaultAmount,
    this.noteTemplate,
    required this.isSystem,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['event_type'] = Variable<String>(eventType);
    if (!nullToAbsent || relationType != null) {
      map['relation_type'] = Variable<String>(relationType);
    }
    map['default_amount'] = Variable<int>(defaultAmount);
    if (!nullToAbsent || noteTemplate != null) {
      map['note_template'] = Variable<String>(noteTemplate);
    }
    map['is_system'] = Variable<bool>(isSystem);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  GiftTemplatesCompanion toCompanion(bool nullToAbsent) {
    return GiftTemplatesCompanion(
      id: Value(id),
      name: Value(name),
      eventType: Value(eventType),
      relationType: relationType == null && nullToAbsent
          ? const Value.absent()
          : Value(relationType),
      defaultAmount: Value(defaultAmount),
      noteTemplate: noteTemplate == null && nullToAbsent
          ? const Value.absent()
          : Value(noteTemplate),
      isSystem: Value(isSystem),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory GiftTemplateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GiftTemplateRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      eventType: serializer.fromJson<String>(json['eventType']),
      relationType: serializer.fromJson<String?>(json['relationType']),
      defaultAmount: serializer.fromJson<int>(json['defaultAmount']),
      noteTemplate: serializer.fromJson<String?>(json['noteTemplate']),
      isSystem: serializer.fromJson<bool>(json['isSystem']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'eventType': serializer.toJson<String>(eventType),
      'relationType': serializer.toJson<String?>(relationType),
      'defaultAmount': serializer.toJson<int>(defaultAmount),
      'noteTemplate': serializer.toJson<String?>(noteTemplate),
      'isSystem': serializer.toJson<bool>(isSystem),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  GiftTemplateRow copyWith({
    String? id,
    String? name,
    String? eventType,
    Value<String?> relationType = const Value.absent(),
    int? defaultAmount,
    Value<String?> noteTemplate = const Value.absent(),
    bool? isSystem,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => GiftTemplateRow(
    id: id ?? this.id,
    name: name ?? this.name,
    eventType: eventType ?? this.eventType,
    relationType: relationType.present ? relationType.value : this.relationType,
    defaultAmount: defaultAmount ?? this.defaultAmount,
    noteTemplate: noteTemplate.present ? noteTemplate.value : this.noteTemplate,
    isSystem: isSystem ?? this.isSystem,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  GiftTemplateRow copyWithCompanion(GiftTemplatesCompanion data) {
    return GiftTemplateRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      relationType: data.relationType.present
          ? data.relationType.value
          : this.relationType,
      defaultAmount: data.defaultAmount.present
          ? data.defaultAmount.value
          : this.defaultAmount,
      noteTemplate: data.noteTemplate.present
          ? data.noteTemplate.value
          : this.noteTemplate,
      isSystem: data.isSystem.present ? data.isSystem.value : this.isSystem,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GiftTemplateRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('eventType: $eventType, ')
          ..write('relationType: $relationType, ')
          ..write('defaultAmount: $defaultAmount, ')
          ..write('noteTemplate: $noteTemplate, ')
          ..write('isSystem: $isSystem, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    eventType,
    relationType,
    defaultAmount,
    noteTemplate,
    isSystem,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GiftTemplateRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.eventType == this.eventType &&
          other.relationType == this.relationType &&
          other.defaultAmount == this.defaultAmount &&
          other.noteTemplate == this.noteTemplate &&
          other.isSystem == this.isSystem &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class GiftTemplatesCompanion extends UpdateCompanion<GiftTemplateRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> eventType;
  final Value<String?> relationType;
  final Value<int> defaultAmount;
  final Value<String?> noteTemplate;
  final Value<bool> isSystem;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const GiftTemplatesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.eventType = const Value.absent(),
    this.relationType = const Value.absent(),
    this.defaultAmount = const Value.absent(),
    this.noteTemplate = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GiftTemplatesCompanion.insert({
    required String id,
    required String name,
    required String eventType,
    this.relationType = const Value.absent(),
    required int defaultAmount,
    this.noteTemplate = const Value.absent(),
    this.isSystem = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       eventType = Value(eventType),
       defaultAmount = Value(defaultAmount),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<GiftTemplateRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? eventType,
    Expression<String>? relationType,
    Expression<int>? defaultAmount,
    Expression<String>? noteTemplate,
    Expression<bool>? isSystem,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (eventType != null) 'event_type': eventType,
      if (relationType != null) 'relation_type': relationType,
      if (defaultAmount != null) 'default_amount': defaultAmount,
      if (noteTemplate != null) 'note_template': noteTemplate,
      if (isSystem != null) 'is_system': isSystem,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GiftTemplatesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? eventType,
    Value<String?>? relationType,
    Value<int>? defaultAmount,
    Value<String?>? noteTemplate,
    Value<bool>? isSystem,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return GiftTemplatesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      eventType: eventType ?? this.eventType,
      relationType: relationType ?? this.relationType,
      defaultAmount: defaultAmount ?? this.defaultAmount,
      noteTemplate: noteTemplate ?? this.noteTemplate,
      isSystem: isSystem ?? this.isSystem,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (relationType.present) {
      map['relation_type'] = Variable<String>(relationType.value);
    }
    if (defaultAmount.present) {
      map['default_amount'] = Variable<int>(defaultAmount.value);
    }
    if (noteTemplate.present) {
      map['note_template'] = Variable<String>(noteTemplate.value);
    }
    if (isSystem.present) {
      map['is_system'] = Variable<bool>(isSystem.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GiftTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('eventType: $eventType, ')
          ..write('relationType: $relationType, ')
          ..write('defaultAmount: $defaultAmount, ')
          ..write('noteTemplate: $noteTemplate, ')
          ..write('isSystem: $isSystem, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LedgerBooksTable ledgerBooks = $LedgerBooksTable(this);
  late final $PersonsTable persons = $PersonsTable(this);
  late final $GiftRecordsTable giftRecords = $GiftRecordsTable(this);
  late final $RemindersTable reminders = $RemindersTable(this);
  late final $GiftTemplatesTable giftTemplates = $GiftTemplatesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    ledgerBooks,
    persons,
    giftRecords,
    reminders,
    giftTemplates,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'ledger_books',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('persons', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'ledger_books',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('gift_records', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'persons',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('gift_records', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'ledger_books',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('reminders', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$LedgerBooksTableCreateCompanionBuilder =
    LedgerBooksCompanion Function({
      required String id,
      required String name,
      Value<String> type,
      Value<String> themeId,
      Value<bool> isDefault,
      Value<bool> isArchived,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LedgerBooksTableUpdateCompanionBuilder =
    LedgerBooksCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> type,
      Value<String> themeId,
      Value<bool> isDefault,
      Value<bool> isArchived,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$LedgerBooksTableReferences
    extends BaseReferences<_$AppDatabase, $LedgerBooksTable, LedgerBookRow> {
  $$LedgerBooksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PersonsTable, List<PersonRow>> _personsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.persons,
    aliasName: 'ledger_books__id__persons__ledger_book_id',
  );

  $$PersonsTableProcessedTableManager get personsRefs {
    final manager = $$PersonsTableTableManager(
      $_db,
      $_db.persons,
    ).filter((f) => f.ledgerBookId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_personsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GiftRecordsTable, List<GiftRecordRow>>
  _giftRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.giftRecords,
    aliasName: 'ledger_books__id__gift_records__ledger_book_id',
  );

  $$GiftRecordsTableProcessedTableManager get giftRecordsRefs {
    final manager = $$GiftRecordsTableTableManager(
      $_db,
      $_db.giftRecords,
    ).filter((f) => f.ledgerBookId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_giftRecordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RemindersTable, List<ReminderRow>>
  _remindersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reminders,
    aliasName: 'ledger_books__id__reminders__ledger_book_id',
  );

  $$RemindersTableProcessedTableManager get remindersRefs {
    final manager = $$RemindersTableTableManager(
      $_db,
      $_db.reminders,
    ).filter((f) => f.ledgerBookId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_remindersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LedgerBooksTableFilterComposer
    extends Composer<_$AppDatabase, $LedgerBooksTable> {
  $$LedgerBooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get themeId => $composableBuilder(
    column: $table.themeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> personsRefs(
    Expression<bool> Function($$PersonsTableFilterComposer f) f,
  ) {
    final $$PersonsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.persons,
      getReferencedColumn: (t) => t.ledgerBookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableFilterComposer(
            $db: $db,
            $table: $db.persons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> giftRecordsRefs(
    Expression<bool> Function($$GiftRecordsTableFilterComposer f) f,
  ) {
    final $$GiftRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.giftRecords,
      getReferencedColumn: (t) => t.ledgerBookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GiftRecordsTableFilterComposer(
            $db: $db,
            $table: $db.giftRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> remindersRefs(
    Expression<bool> Function($$RemindersTableFilterComposer f) f,
  ) {
    final $$RemindersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.ledgerBookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableFilterComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LedgerBooksTableOrderingComposer
    extends Composer<_$AppDatabase, $LedgerBooksTable> {
  $$LedgerBooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themeId => $composableBuilder(
    column: $table.themeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LedgerBooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $LedgerBooksTable> {
  $$LedgerBooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get themeId =>
      $composableBuilder(column: $table.themeId, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> personsRefs<T extends Object>(
    Expression<T> Function($$PersonsTableAnnotationComposer a) f,
  ) {
    final $$PersonsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.persons,
      getReferencedColumn: (t) => t.ledgerBookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableAnnotationComposer(
            $db: $db,
            $table: $db.persons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> giftRecordsRefs<T extends Object>(
    Expression<T> Function($$GiftRecordsTableAnnotationComposer a) f,
  ) {
    final $$GiftRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.giftRecords,
      getReferencedColumn: (t) => t.ledgerBookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GiftRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.giftRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> remindersRefs<T extends Object>(
    Expression<T> Function($$RemindersTableAnnotationComposer a) f,
  ) {
    final $$RemindersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.ledgerBookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableAnnotationComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LedgerBooksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LedgerBooksTable,
          LedgerBookRow,
          $$LedgerBooksTableFilterComposer,
          $$LedgerBooksTableOrderingComposer,
          $$LedgerBooksTableAnnotationComposer,
          $$LedgerBooksTableCreateCompanionBuilder,
          $$LedgerBooksTableUpdateCompanionBuilder,
          (LedgerBookRow, $$LedgerBooksTableReferences),
          LedgerBookRow,
          PrefetchHooks Function({
            bool personsRefs,
            bool giftRecordsRefs,
            bool remindersRefs,
          })
        > {
  $$LedgerBooksTableTableManager(_$AppDatabase db, $LedgerBooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LedgerBooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LedgerBooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LedgerBooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> themeId = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LedgerBooksCompanion(
                id: id,
                name: name,
                type: type,
                themeId: themeId,
                isDefault: isDefault,
                isArchived: isArchived,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> type = const Value.absent(),
                Value<String> themeId = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LedgerBooksCompanion.insert(
                id: id,
                name: name,
                type: type,
                themeId: themeId,
                isDefault: isDefault,
                isArchived: isArchived,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LedgerBooksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                personsRefs = false,
                giftRecordsRefs = false,
                remindersRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (personsRefs) db.persons,
                    if (giftRecordsRefs) db.giftRecords,
                    if (remindersRefs) db.reminders,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (personsRefs)
                        await $_getPrefetchedData<
                          LedgerBookRow,
                          $LedgerBooksTable,
                          PersonRow
                        >(
                          currentTable: table,
                          referencedTable: $$LedgerBooksTableReferences
                              ._personsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LedgerBooksTableReferences(
                                db,
                                table,
                                p0,
                              ).personsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ledgerBookId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (giftRecordsRefs)
                        await $_getPrefetchedData<
                          LedgerBookRow,
                          $LedgerBooksTable,
                          GiftRecordRow
                        >(
                          currentTable: table,
                          referencedTable: $$LedgerBooksTableReferences
                              ._giftRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LedgerBooksTableReferences(
                                db,
                                table,
                                p0,
                              ).giftRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ledgerBookId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (remindersRefs)
                        await $_getPrefetchedData<
                          LedgerBookRow,
                          $LedgerBooksTable,
                          ReminderRow
                        >(
                          currentTable: table,
                          referencedTable: $$LedgerBooksTableReferences
                              ._remindersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LedgerBooksTableReferences(
                                db,
                                table,
                                p0,
                              ).remindersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ledgerBookId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$LedgerBooksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LedgerBooksTable,
      LedgerBookRow,
      $$LedgerBooksTableFilterComposer,
      $$LedgerBooksTableOrderingComposer,
      $$LedgerBooksTableAnnotationComposer,
      $$LedgerBooksTableCreateCompanionBuilder,
      $$LedgerBooksTableUpdateCompanionBuilder,
      (LedgerBookRow, $$LedgerBooksTableReferences),
      LedgerBookRow,
      PrefetchHooks Function({
        bool personsRefs,
        bool giftRecordsRefs,
        bool remindersRefs,
      })
    >;
typedef $$PersonsTableCreateCompanionBuilder =
    PersonsCompanion Function({
      required String id,
      required String ledgerBookId,
      required String name,
      Value<String?> nickname,
      Value<String?> relationType,
      Value<String?> relationLabel,
      Value<String?> phone,
      Value<String?> avatar,
      Value<String?> note,
      Value<DateTime?> birthdaySolar,
      Value<String?> birthdayLunar,
      Value<bool> isImportant,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$PersonsTableUpdateCompanionBuilder =
    PersonsCompanion Function({
      Value<String> id,
      Value<String> ledgerBookId,
      Value<String> name,
      Value<String?> nickname,
      Value<String?> relationType,
      Value<String?> relationLabel,
      Value<String?> phone,
      Value<String?> avatar,
      Value<String?> note,
      Value<DateTime?> birthdaySolar,
      Value<String?> birthdayLunar,
      Value<bool> isImportant,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$PersonsTableReferences
    extends BaseReferences<_$AppDatabase, $PersonsTable, PersonRow> {
  $$PersonsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LedgerBooksTable _ledgerBookIdTable(_$AppDatabase db) =>
      db.ledgerBooks.createAlias('persons__ledger_book_id__ledger_books__id');

  $$LedgerBooksTableProcessedTableManager get ledgerBookId {
    final $_column = $_itemColumn<String>('ledger_book_id')!;

    final manager = $$LedgerBooksTableTableManager(
      $_db,
      $_db.ledgerBooks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ledgerBookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$GiftRecordsTable, List<GiftRecordRow>>
  _giftRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.giftRecords,
    aliasName: 'persons__id__gift_records__person_id',
  );

  $$GiftRecordsTableProcessedTableManager get giftRecordsRefs {
    final manager = $$GiftRecordsTableTableManager(
      $_db,
      $_db.giftRecords,
    ).filter((f) => f.personId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_giftRecordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PersonsTableFilterComposer
    extends Composer<_$AppDatabase, $PersonsTable> {
  $$PersonsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relationType => $composableBuilder(
    column: $table.relationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relationLabel => $composableBuilder(
    column: $table.relationLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatar => $composableBuilder(
    column: $table.avatar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get birthdaySolar => $composableBuilder(
    column: $table.birthdaySolar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get birthdayLunar => $composableBuilder(
    column: $table.birthdayLunar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isImportant => $composableBuilder(
    column: $table.isImportant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$LedgerBooksTableFilterComposer get ledgerBookId {
    final $$LedgerBooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ledgerBookId,
      referencedTable: $db.ledgerBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LedgerBooksTableFilterComposer(
            $db: $db,
            $table: $db.ledgerBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> giftRecordsRefs(
    Expression<bool> Function($$GiftRecordsTableFilterComposer f) f,
  ) {
    final $$GiftRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.giftRecords,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GiftRecordsTableFilterComposer(
            $db: $db,
            $table: $db.giftRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PersonsTableOrderingComposer
    extends Composer<_$AppDatabase, $PersonsTable> {
  $$PersonsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relationType => $composableBuilder(
    column: $table.relationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relationLabel => $composableBuilder(
    column: $table.relationLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatar => $composableBuilder(
    column: $table.avatar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get birthdaySolar => $composableBuilder(
    column: $table.birthdaySolar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get birthdayLunar => $composableBuilder(
    column: $table.birthdayLunar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isImportant => $composableBuilder(
    column: $table.isImportant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$LedgerBooksTableOrderingComposer get ledgerBookId {
    final $$LedgerBooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ledgerBookId,
      referencedTable: $db.ledgerBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LedgerBooksTableOrderingComposer(
            $db: $db,
            $table: $db.ledgerBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PersonsTable> {
  $$PersonsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumn<String> get relationType => $composableBuilder(
    column: $table.relationType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get relationLabel => $composableBuilder(
    column: $table.relationLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get avatar =>
      $composableBuilder(column: $table.avatar, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get birthdaySolar => $composableBuilder(
    column: $table.birthdaySolar,
    builder: (column) => column,
  );

  GeneratedColumn<String> get birthdayLunar => $composableBuilder(
    column: $table.birthdayLunar,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isImportant => $composableBuilder(
    column: $table.isImportant,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$LedgerBooksTableAnnotationComposer get ledgerBookId {
    final $$LedgerBooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ledgerBookId,
      referencedTable: $db.ledgerBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LedgerBooksTableAnnotationComposer(
            $db: $db,
            $table: $db.ledgerBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> giftRecordsRefs<T extends Object>(
    Expression<T> Function($$GiftRecordsTableAnnotationComposer a) f,
  ) {
    final $$GiftRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.giftRecords,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GiftRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.giftRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PersonsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PersonsTable,
          PersonRow,
          $$PersonsTableFilterComposer,
          $$PersonsTableOrderingComposer,
          $$PersonsTableAnnotationComposer,
          $$PersonsTableCreateCompanionBuilder,
          $$PersonsTableUpdateCompanionBuilder,
          (PersonRow, $$PersonsTableReferences),
          PersonRow,
          PrefetchHooks Function({bool ledgerBookId, bool giftRecordsRefs})
        > {
  $$PersonsTableTableManager(_$AppDatabase db, $PersonsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PersonsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ledgerBookId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> nickname = const Value.absent(),
                Value<String?> relationType = const Value.absent(),
                Value<String?> relationLabel = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> avatar = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime?> birthdaySolar = const Value.absent(),
                Value<String?> birthdayLunar = const Value.absent(),
                Value<bool> isImportant = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonsCompanion(
                id: id,
                ledgerBookId: ledgerBookId,
                name: name,
                nickname: nickname,
                relationType: relationType,
                relationLabel: relationLabel,
                phone: phone,
                avatar: avatar,
                note: note,
                birthdaySolar: birthdaySolar,
                birthdayLunar: birthdayLunar,
                isImportant: isImportant,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ledgerBookId,
                required String name,
                Value<String?> nickname = const Value.absent(),
                Value<String?> relationType = const Value.absent(),
                Value<String?> relationLabel = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> avatar = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime?> birthdaySolar = const Value.absent(),
                Value<String?> birthdayLunar = const Value.absent(),
                Value<bool> isImportant = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PersonsCompanion.insert(
                id: id,
                ledgerBookId: ledgerBookId,
                name: name,
                nickname: nickname,
                relationType: relationType,
                relationLabel: relationLabel,
                phone: phone,
                avatar: avatar,
                note: note,
                birthdaySolar: birthdaySolar,
                birthdayLunar: birthdayLunar,
                isImportant: isImportant,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PersonsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({ledgerBookId = false, giftRecordsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (giftRecordsRefs) db.giftRecords,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (ledgerBookId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.ledgerBookId,
                                    referencedTable: $$PersonsTableReferences
                                        ._ledgerBookIdTable(db),
                                    referencedColumn: $$PersonsTableReferences
                                        ._ledgerBookIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (giftRecordsRefs)
                        await $_getPrefetchedData<
                          PersonRow,
                          $PersonsTable,
                          GiftRecordRow
                        >(
                          currentTable: table,
                          referencedTable: $$PersonsTableReferences
                              ._giftRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PersonsTableReferences(
                                db,
                                table,
                                p0,
                              ).giftRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.personId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PersonsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PersonsTable,
      PersonRow,
      $$PersonsTableFilterComposer,
      $$PersonsTableOrderingComposer,
      $$PersonsTableAnnotationComposer,
      $$PersonsTableCreateCompanionBuilder,
      $$PersonsTableUpdateCompanionBuilder,
      (PersonRow, $$PersonsTableReferences),
      PersonRow,
      PrefetchHooks Function({bool ledgerBookId, bool giftRecordsRefs})
    >;
typedef $$GiftRecordsTableCreateCompanionBuilder =
    GiftRecordsCompanion Function({
      required String id,
      required String ledgerBookId,
      Value<String?> personId,
      required String name,
      Value<String?> nickname,
      required String relation,
      Value<String?> relationLabel,
      Value<String?> phone,
      required String eventType,
      required String direction,
      required String eventTone,
      required String recordMethod,
      required int amount,
      Value<int?> estimatedAmount,
      Value<String?> giftName,
      Value<String?> serviceDescription,
      required DateTime eventDate,
      Value<String?> lunarDate,
      Value<String?> note,
      Value<bool> needReturn,
      Value<String?> returnedRecordId,
      Value<String> entryMode,
      Value<String> completionStatus,
      Value<String?> quickScene,
      Value<String?> tempRelationText,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$GiftRecordsTableUpdateCompanionBuilder =
    GiftRecordsCompanion Function({
      Value<String> id,
      Value<String> ledgerBookId,
      Value<String?> personId,
      Value<String> name,
      Value<String?> nickname,
      Value<String> relation,
      Value<String?> relationLabel,
      Value<String?> phone,
      Value<String> eventType,
      Value<String> direction,
      Value<String> eventTone,
      Value<String> recordMethod,
      Value<int> amount,
      Value<int?> estimatedAmount,
      Value<String?> giftName,
      Value<String?> serviceDescription,
      Value<DateTime> eventDate,
      Value<String?> lunarDate,
      Value<String?> note,
      Value<bool> needReturn,
      Value<String?> returnedRecordId,
      Value<String> entryMode,
      Value<String> completionStatus,
      Value<String?> quickScene,
      Value<String?> tempRelationText,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

final class $$GiftRecordsTableReferences
    extends BaseReferences<_$AppDatabase, $GiftRecordsTable, GiftRecordRow> {
  $$GiftRecordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LedgerBooksTable _ledgerBookIdTable(_$AppDatabase db) => db
      .ledgerBooks
      .createAlias('gift_records__ledger_book_id__ledger_books__id');

  $$LedgerBooksTableProcessedTableManager get ledgerBookId {
    final $_column = $_itemColumn<String>('ledger_book_id')!;

    final manager = $$LedgerBooksTableTableManager(
      $_db,
      $_db.ledgerBooks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ledgerBookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PersonsTable _personIdTable(_$AppDatabase db) =>
      db.persons.createAlias('gift_records__person_id__persons__id');

  $$PersonsTableProcessedTableManager? get personId {
    final $_column = $_itemColumn<String>('person_id');
    if ($_column == null) return null;
    final manager = $$PersonsTableTableManager(
      $_db,
      $_db.persons,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_personIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GiftRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $GiftRecordsTable> {
  $$GiftRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relation => $composableBuilder(
    column: $table.relation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relationLabel => $composableBuilder(
    column: $table.relationLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventTone => $composableBuilder(
    column: $table.eventTone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordMethod => $composableBuilder(
    column: $table.recordMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimatedAmount => $composableBuilder(
    column: $table.estimatedAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get giftName => $composableBuilder(
    column: $table.giftName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serviceDescription => $composableBuilder(
    column: $table.serviceDescription,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get eventDate => $composableBuilder(
    column: $table.eventDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lunarDate => $composableBuilder(
    column: $table.lunarDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get needReturn => $composableBuilder(
    column: $table.needReturn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get returnedRecordId => $composableBuilder(
    column: $table.returnedRecordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryMode => $composableBuilder(
    column: $table.entryMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get completionStatus => $composableBuilder(
    column: $table.completionStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quickScene => $composableBuilder(
    column: $table.quickScene,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tempRelationText => $composableBuilder(
    column: $table.tempRelationText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  $$LedgerBooksTableFilterComposer get ledgerBookId {
    final $$LedgerBooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ledgerBookId,
      referencedTable: $db.ledgerBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LedgerBooksTableFilterComposer(
            $db: $db,
            $table: $db.ledgerBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PersonsTableFilterComposer get personId {
    final $$PersonsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.persons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableFilterComposer(
            $db: $db,
            $table: $db.persons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GiftRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $GiftRecordsTable> {
  $$GiftRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relation => $composableBuilder(
    column: $table.relation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relationLabel => $composableBuilder(
    column: $table.relationLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventTone => $composableBuilder(
    column: $table.eventTone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordMethod => $composableBuilder(
    column: $table.recordMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimatedAmount => $composableBuilder(
    column: $table.estimatedAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get giftName => $composableBuilder(
    column: $table.giftName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serviceDescription => $composableBuilder(
    column: $table.serviceDescription,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get eventDate => $composableBuilder(
    column: $table.eventDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lunarDate => $composableBuilder(
    column: $table.lunarDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get needReturn => $composableBuilder(
    column: $table.needReturn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get returnedRecordId => $composableBuilder(
    column: $table.returnedRecordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryMode => $composableBuilder(
    column: $table.entryMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get completionStatus => $composableBuilder(
    column: $table.completionStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quickScene => $composableBuilder(
    column: $table.quickScene,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tempRelationText => $composableBuilder(
    column: $table.tempRelationText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  $$LedgerBooksTableOrderingComposer get ledgerBookId {
    final $$LedgerBooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ledgerBookId,
      referencedTable: $db.ledgerBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LedgerBooksTableOrderingComposer(
            $db: $db,
            $table: $db.ledgerBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PersonsTableOrderingComposer get personId {
    final $$PersonsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.persons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableOrderingComposer(
            $db: $db,
            $table: $db.persons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GiftRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GiftRecordsTable> {
  $$GiftRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumn<String> get relation =>
      $composableBuilder(column: $table.relation, builder: (column) => column);

  GeneratedColumn<String> get relationLabel => $composableBuilder(
    column: $table.relationLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<String> get eventTone =>
      $composableBuilder(column: $table.eventTone, builder: (column) => column);

  GeneratedColumn<String> get recordMethod => $composableBuilder(
    column: $table.recordMethod,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<int> get estimatedAmount => $composableBuilder(
    column: $table.estimatedAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get giftName =>
      $composableBuilder(column: $table.giftName, builder: (column) => column);

  GeneratedColumn<String> get serviceDescription => $composableBuilder(
    column: $table.serviceDescription,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get eventDate =>
      $composableBuilder(column: $table.eventDate, builder: (column) => column);

  GeneratedColumn<String> get lunarDate =>
      $composableBuilder(column: $table.lunarDate, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<bool> get needReturn => $composableBuilder(
    column: $table.needReturn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get returnedRecordId => $composableBuilder(
    column: $table.returnedRecordId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entryMode =>
      $composableBuilder(column: $table.entryMode, builder: (column) => column);

  GeneratedColumn<String> get completionStatus => $composableBuilder(
    column: $table.completionStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get quickScene => $composableBuilder(
    column: $table.quickScene,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tempRelationText => $composableBuilder(
    column: $table.tempRelationText,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  $$LedgerBooksTableAnnotationComposer get ledgerBookId {
    final $$LedgerBooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ledgerBookId,
      referencedTable: $db.ledgerBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LedgerBooksTableAnnotationComposer(
            $db: $db,
            $table: $db.ledgerBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PersonsTableAnnotationComposer get personId {
    final $$PersonsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.persons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableAnnotationComposer(
            $db: $db,
            $table: $db.persons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GiftRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GiftRecordsTable,
          GiftRecordRow,
          $$GiftRecordsTableFilterComposer,
          $$GiftRecordsTableOrderingComposer,
          $$GiftRecordsTableAnnotationComposer,
          $$GiftRecordsTableCreateCompanionBuilder,
          $$GiftRecordsTableUpdateCompanionBuilder,
          (GiftRecordRow, $$GiftRecordsTableReferences),
          GiftRecordRow,
          PrefetchHooks Function({bool ledgerBookId, bool personId})
        > {
  $$GiftRecordsTableTableManager(_$AppDatabase db, $GiftRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GiftRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GiftRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GiftRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ledgerBookId = const Value.absent(),
                Value<String?> personId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> nickname = const Value.absent(),
                Value<String> relation = const Value.absent(),
                Value<String?> relationLabel = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<String> direction = const Value.absent(),
                Value<String> eventTone = const Value.absent(),
                Value<String> recordMethod = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<int?> estimatedAmount = const Value.absent(),
                Value<String?> giftName = const Value.absent(),
                Value<String?> serviceDescription = const Value.absent(),
                Value<DateTime> eventDate = const Value.absent(),
                Value<String?> lunarDate = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<bool> needReturn = const Value.absent(),
                Value<String?> returnedRecordId = const Value.absent(),
                Value<String> entryMode = const Value.absent(),
                Value<String> completionStatus = const Value.absent(),
                Value<String?> quickScene = const Value.absent(),
                Value<String?> tempRelationText = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GiftRecordsCompanion(
                id: id,
                ledgerBookId: ledgerBookId,
                personId: personId,
                name: name,
                nickname: nickname,
                relation: relation,
                relationLabel: relationLabel,
                phone: phone,
                eventType: eventType,
                direction: direction,
                eventTone: eventTone,
                recordMethod: recordMethod,
                amount: amount,
                estimatedAmount: estimatedAmount,
                giftName: giftName,
                serviceDescription: serviceDescription,
                eventDate: eventDate,
                lunarDate: lunarDate,
                note: note,
                needReturn: needReturn,
                returnedRecordId: returnedRecordId,
                entryMode: entryMode,
                completionStatus: completionStatus,
                quickScene: quickScene,
                tempRelationText: tempRelationText,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ledgerBookId,
                Value<String?> personId = const Value.absent(),
                required String name,
                Value<String?> nickname = const Value.absent(),
                required String relation,
                Value<String?> relationLabel = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                required String eventType,
                required String direction,
                required String eventTone,
                required String recordMethod,
                required int amount,
                Value<int?> estimatedAmount = const Value.absent(),
                Value<String?> giftName = const Value.absent(),
                Value<String?> serviceDescription = const Value.absent(),
                required DateTime eventDate,
                Value<String?> lunarDate = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<bool> needReturn = const Value.absent(),
                Value<String?> returnedRecordId = const Value.absent(),
                Value<String> entryMode = const Value.absent(),
                Value<String> completionStatus = const Value.absent(),
                Value<String?> quickScene = const Value.absent(),
                Value<String?> tempRelationText = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GiftRecordsCompanion.insert(
                id: id,
                ledgerBookId: ledgerBookId,
                personId: personId,
                name: name,
                nickname: nickname,
                relation: relation,
                relationLabel: relationLabel,
                phone: phone,
                eventType: eventType,
                direction: direction,
                eventTone: eventTone,
                recordMethod: recordMethod,
                amount: amount,
                estimatedAmount: estimatedAmount,
                giftName: giftName,
                serviceDescription: serviceDescription,
                eventDate: eventDate,
                lunarDate: lunarDate,
                note: note,
                needReturn: needReturn,
                returnedRecordId: returnedRecordId,
                entryMode: entryMode,
                completionStatus: completionStatus,
                quickScene: quickScene,
                tempRelationText: tempRelationText,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GiftRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ledgerBookId = false, personId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (ledgerBookId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.ledgerBookId,
                                referencedTable: $$GiftRecordsTableReferences
                                    ._ledgerBookIdTable(db),
                                referencedColumn: $$GiftRecordsTableReferences
                                    ._ledgerBookIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (personId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.personId,
                                referencedTable: $$GiftRecordsTableReferences
                                    ._personIdTable(db),
                                referencedColumn: $$GiftRecordsTableReferences
                                    ._personIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GiftRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GiftRecordsTable,
      GiftRecordRow,
      $$GiftRecordsTableFilterComposer,
      $$GiftRecordsTableOrderingComposer,
      $$GiftRecordsTableAnnotationComposer,
      $$GiftRecordsTableCreateCompanionBuilder,
      $$GiftRecordsTableUpdateCompanionBuilder,
      (GiftRecordRow, $$GiftRecordsTableReferences),
      GiftRecordRow,
      PrefetchHooks Function({bool ledgerBookId, bool personId})
    >;
typedef $$RemindersTableCreateCompanionBuilder =
    RemindersCompanion Function({
      required String id,
      required String ledgerBookId,
      Value<String?> personId,
      Value<String?> relatedRecordId,
      required String type,
      required String title,
      required DateTime date,
      required DateTime remindAt,
      Value<String> status,
      Value<String?> note,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$RemindersTableUpdateCompanionBuilder =
    RemindersCompanion Function({
      Value<String> id,
      Value<String> ledgerBookId,
      Value<String?> personId,
      Value<String?> relatedRecordId,
      Value<String> type,
      Value<String> title,
      Value<DateTime> date,
      Value<DateTime> remindAt,
      Value<String> status,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$RemindersTableReferences
    extends BaseReferences<_$AppDatabase, $RemindersTable, ReminderRow> {
  $$RemindersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LedgerBooksTable _ledgerBookIdTable(_$AppDatabase db) =>
      db.ledgerBooks.createAlias('reminders__ledger_book_id__ledger_books__id');

  $$LedgerBooksTableProcessedTableManager get ledgerBookId {
    final $_column = $_itemColumn<String>('ledger_book_id')!;

    final manager = $$LedgerBooksTableTableManager(
      $_db,
      $_db.ledgerBooks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ledgerBookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RemindersTableFilterComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get personId => $composableBuilder(
    column: $table.personId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relatedRecordId => $composableBuilder(
    column: $table.relatedRecordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get remindAt => $composableBuilder(
    column: $table.remindAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$LedgerBooksTableFilterComposer get ledgerBookId {
    final $$LedgerBooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ledgerBookId,
      referencedTable: $db.ledgerBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LedgerBooksTableFilterComposer(
            $db: $db,
            $table: $db.ledgerBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get personId => $composableBuilder(
    column: $table.personId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relatedRecordId => $composableBuilder(
    column: $table.relatedRecordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get remindAt => $composableBuilder(
    column: $table.remindAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$LedgerBooksTableOrderingComposer get ledgerBookId {
    final $$LedgerBooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ledgerBookId,
      referencedTable: $db.ledgerBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LedgerBooksTableOrderingComposer(
            $db: $db,
            $table: $db.ledgerBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get personId =>
      $composableBuilder(column: $table.personId, builder: (column) => column);

  GeneratedColumn<String> get relatedRecordId => $composableBuilder(
    column: $table.relatedRecordId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get remindAt =>
      $composableBuilder(column: $table.remindAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$LedgerBooksTableAnnotationComposer get ledgerBookId {
    final $$LedgerBooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ledgerBookId,
      referencedTable: $db.ledgerBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LedgerBooksTableAnnotationComposer(
            $db: $db,
            $table: $db.ledgerBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RemindersTable,
          ReminderRow,
          $$RemindersTableFilterComposer,
          $$RemindersTableOrderingComposer,
          $$RemindersTableAnnotationComposer,
          $$RemindersTableCreateCompanionBuilder,
          $$RemindersTableUpdateCompanionBuilder,
          (ReminderRow, $$RemindersTableReferences),
          ReminderRow,
          PrefetchHooks Function({bool ledgerBookId})
        > {
  $$RemindersTableTableManager(_$AppDatabase db, $RemindersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ledgerBookId = const Value.absent(),
                Value<String?> personId = const Value.absent(),
                Value<String?> relatedRecordId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<DateTime> remindAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemindersCompanion(
                id: id,
                ledgerBookId: ledgerBookId,
                personId: personId,
                relatedRecordId: relatedRecordId,
                type: type,
                title: title,
                date: date,
                remindAt: remindAt,
                status: status,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ledgerBookId,
                Value<String?> personId = const Value.absent(),
                Value<String?> relatedRecordId = const Value.absent(),
                required String type,
                required String title,
                required DateTime date,
                required DateTime remindAt,
                Value<String> status = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => RemindersCompanion.insert(
                id: id,
                ledgerBookId: ledgerBookId,
                personId: personId,
                relatedRecordId: relatedRecordId,
                type: type,
                title: title,
                date: date,
                remindAt: remindAt,
                status: status,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RemindersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ledgerBookId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (ledgerBookId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.ledgerBookId,
                                referencedTable: $$RemindersTableReferences
                                    ._ledgerBookIdTable(db),
                                referencedColumn: $$RemindersTableReferences
                                    ._ledgerBookIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RemindersTable,
      ReminderRow,
      $$RemindersTableFilterComposer,
      $$RemindersTableOrderingComposer,
      $$RemindersTableAnnotationComposer,
      $$RemindersTableCreateCompanionBuilder,
      $$RemindersTableUpdateCompanionBuilder,
      (ReminderRow, $$RemindersTableReferences),
      ReminderRow,
      PrefetchHooks Function({bool ledgerBookId})
    >;
typedef $$GiftTemplatesTableCreateCompanionBuilder =
    GiftTemplatesCompanion Function({
      required String id,
      required String name,
      required String eventType,
      Value<String?> relationType,
      required int defaultAmount,
      Value<String?> noteTemplate,
      Value<bool> isSystem,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$GiftTemplatesTableUpdateCompanionBuilder =
    GiftTemplatesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> eventType,
      Value<String?> relationType,
      Value<int> defaultAmount,
      Value<String?> noteTemplate,
      Value<bool> isSystem,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$GiftTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $GiftTemplatesTable> {
  $$GiftTemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relationType => $composableBuilder(
    column: $table.relationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultAmount => $composableBuilder(
    column: $table.defaultAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get noteTemplate => $composableBuilder(
    column: $table.noteTemplate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GiftTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $GiftTemplatesTable> {
  $$GiftTemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relationType => $composableBuilder(
    column: $table.relationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultAmount => $composableBuilder(
    column: $table.defaultAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get noteTemplate => $composableBuilder(
    column: $table.noteTemplate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GiftTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GiftTemplatesTable> {
  $$GiftTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<String> get relationType => $composableBuilder(
    column: $table.relationType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get defaultAmount => $composableBuilder(
    column: $table.defaultAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get noteTemplate => $composableBuilder(
    column: $table.noteTemplate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSystem =>
      $composableBuilder(column: $table.isSystem, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$GiftTemplatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GiftTemplatesTable,
          GiftTemplateRow,
          $$GiftTemplatesTableFilterComposer,
          $$GiftTemplatesTableOrderingComposer,
          $$GiftTemplatesTableAnnotationComposer,
          $$GiftTemplatesTableCreateCompanionBuilder,
          $$GiftTemplatesTableUpdateCompanionBuilder,
          (
            GiftTemplateRow,
            BaseReferences<_$AppDatabase, $GiftTemplatesTable, GiftTemplateRow>,
          ),
          GiftTemplateRow,
          PrefetchHooks Function()
        > {
  $$GiftTemplatesTableTableManager(_$AppDatabase db, $GiftTemplatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GiftTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GiftTemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GiftTemplatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<String?> relationType = const Value.absent(),
                Value<int> defaultAmount = const Value.absent(),
                Value<String?> noteTemplate = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GiftTemplatesCompanion(
                id: id,
                name: name,
                eventType: eventType,
                relationType: relationType,
                defaultAmount: defaultAmount,
                noteTemplate: noteTemplate,
                isSystem: isSystem,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String eventType,
                Value<String?> relationType = const Value.absent(),
                required int defaultAmount,
                Value<String?> noteTemplate = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => GiftTemplatesCompanion.insert(
                id: id,
                name: name,
                eventType: eventType,
                relationType: relationType,
                defaultAmount: defaultAmount,
                noteTemplate: noteTemplate,
                isSystem: isSystem,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GiftTemplatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GiftTemplatesTable,
      GiftTemplateRow,
      $$GiftTemplatesTableFilterComposer,
      $$GiftTemplatesTableOrderingComposer,
      $$GiftTemplatesTableAnnotationComposer,
      $$GiftTemplatesTableCreateCompanionBuilder,
      $$GiftTemplatesTableUpdateCompanionBuilder,
      (
        GiftTemplateRow,
        BaseReferences<_$AppDatabase, $GiftTemplatesTable, GiftTemplateRow>,
      ),
      GiftTemplateRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LedgerBooksTableTableManager get ledgerBooks =>
      $$LedgerBooksTableTableManager(_db, _db.ledgerBooks);
  $$PersonsTableTableManager get persons =>
      $$PersonsTableTableManager(_db, _db.persons);
  $$GiftRecordsTableTableManager get giftRecords =>
      $$GiftRecordsTableTableManager(_db, _db.giftRecords);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db, _db.reminders);
  $$GiftTemplatesTableTableManager get giftTemplates =>
      $$GiftTemplatesTableTableManager(_db, _db.giftTemplates);
}
