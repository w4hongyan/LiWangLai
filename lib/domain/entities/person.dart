/// 人物（设计文档 §11.2）。B 阶段会接驳账本与记录；A 阶段只建实体与表。
class Person {
  const Person({
    required this.id,
    required this.ledgerBookId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.nickname,
    this.relationType,
    this.relationLabel,
    this.phone,
    this.avatar,
    this.note,
    this.birthdaySolar,
    this.birthdayLunar,
    this.isImportant = false,
  });

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

  Person copyWith({
    String? id,
    String? ledgerBookId,
    String? name,
    String? nickname,
    String? relationType,
    String? relationLabel,
    String? phone,
    String? avatar,
    String? note,
    DateTime? birthdaySolar,
    String? birthdayLunar,
    bool? isImportant,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Person(
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
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'ledger_book_id': ledgerBookId,
        'name': name,
        'nickname': nickname,
        'relation_type': relationType,
        'relation_label': relationLabel,
        'phone': phone,
        'avatar': avatar,
        'note': note,
        'birthday_solar': birthdaySolar?.millisecondsSinceEpoch,
        'birthday_lunar': birthdayLunar,
        'is_important': isImportant ? 1 : 0,
        'created_at': createdAt.millisecondsSinceEpoch,
        'updated_at': updatedAt.millisecondsSinceEpoch,
      };
}