/// 账本（设计文档 §11.1）。A 阶段固定为「我家」单账本，
/// B 阶段会扩展主题、归档、账本切换。
enum LedgerBookType {
  personal('personal'),
  family('family'),
  parents('parents'),
  custom('custom');

  const LedgerBookType(this.wire);

  final String wire;

  static LedgerBookType fromWire(String? value) => switch (value) {
        'family' => LedgerBookType.family,
        'parents' => LedgerBookType.parents,
        'custom' => LedgerBookType.custom,
        _ => LedgerBookType.personal,
      };
}

class LedgerBook {
  const LedgerBook({
    required this.id,
    required this.name,
    required this.type,
    required this.themeId,
    required this.isDefault,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final LedgerBookType type;
  final String themeId;
  final bool isDefault;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  LedgerBook copyWith({
    String? id,
    String? name,
    LedgerBookType? type,
    String? themeId,
    bool? isDefault,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LedgerBook(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      themeId: themeId ?? this.themeId,
      isDefault: isDefault ?? this.isDefault,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'type': type.wire,
        'theme_id': themeId,
        'is_default': isDefault ? 1 : 0,
        'is_archived': isArchived ? 1 : 0,
        'created_at': createdAt.millisecondsSinceEpoch,
        'updated_at': updatedAt.millisecondsSinceEpoch,
      };
}