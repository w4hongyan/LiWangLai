/// 礼金模板（设计文档 §11.5）。B 阶段可由用户在「我的-礼金模板」里维护，
/// A 阶段先建实体与表，默认带一组系统模板。
class GiftTemplate {
  const GiftTemplate({
    required this.id,
    required this.name,
    required this.eventType,
    required this.defaultAmount,
    required this.isSystem,
    required this.createdAt,
    required this.updatedAt,
    this.relationType,
    this.noteTemplate,
  });

  final String id;
  final String name;
  final String eventType;
  final String? relationType;
  final int defaultAmount;
  final String? noteTemplate;
  final bool isSystem;
  final DateTime createdAt;
  final DateTime updatedAt;

  GiftTemplate copyWith({
    String? id,
    String? name,
    String? eventType,
    String? relationType,
    int? defaultAmount,
    String? noteTemplate,
    bool? isSystem,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GiftTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      eventType: eventType ?? this.eventType,
      relationType: relationType ?? this.relationType,
      defaultAmount: defaultAmount ?? this.defaultAmount,
      noteTemplate: noteTemplate ?? this.noteTemplate,
      isSystem: isSystem ?? this.isSystem,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'event_type': eventType,
        'relation_type': relationType,
        'default_amount': defaultAmount,
        'note_template': noteTemplate,
        'is_system': isSystem ? 1 : 0,
        'created_at': createdAt.millisecondsSinceEpoch,
        'updated_at': updatedAt.millisecondsSinceEpoch,
      };
}