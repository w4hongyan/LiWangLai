enum ReminderType {
  event('event'),
  returnGift('returnGift'),
  birthday('birthday'),
  custom('custom');

  const ReminderType(this.wire);

  final String wire;

  static ReminderType fromWire(String? value) => switch (value) {
        'returnGift' => ReminderType.returnGift,
        'birthday' => ReminderType.birthday,
        'custom' => ReminderType.custom,
        _ => ReminderType.event,
      };
}

enum ReminderStatus {
  pending('pending'),
  done('done'),
  ignored('ignored');

  const ReminderStatus(this.wire);

  final String wire;

  static ReminderStatus fromWire(String? value) => switch (value) {
        'done' => ReminderStatus.done,
        'ignored' => ReminderStatus.ignored,
        _ => ReminderStatus.pending,
      };
}

/// 提醒（设计文档 §11.4）
class Reminder {
  const Reminder({
    required this.id,
    required this.ledgerBookId,
    required this.type,
    required this.title,
    required this.date,
    required this.remindAt,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.personId,
    this.relatedRecordId,
    this.note,
  });

  final String id;
  final String ledgerBookId;
  final String? personId;
  final String? relatedRecordId;
  final ReminderType type;
  final String title;
  final DateTime date;
  final DateTime remindAt;
  final ReminderStatus status;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get daysLeft =>
      date.difference(DateTime.now()).inDays.clamp(-9999, 9999);

  Reminder copyWith({
    String? id,
    String? ledgerBookId,
    String? personId,
    String? relatedRecordId,
    ReminderType? type,
    String? title,
    DateTime? date,
    DateTime? remindAt,
    ReminderStatus? status,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Reminder(
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
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'ledger_book_id': ledgerBookId,
        'person_id': personId,
        'related_record_id': relatedRecordId,
        'type': type.wire,
        'title': title,
        'date': date.millisecondsSinceEpoch,
        'remind_at': remindAt.millisecondsSinceEpoch,
        'status': status.wire,
        'note': note,
        'created_at': createdAt.millisecondsSinceEpoch,
        'updated_at': updatedAt.millisecondsSinceEpoch,
      };
}

/// UI 用的轻量提醒（首页「即将到来」展示）。这是 AppReminder 的纯 UI 模型，
/// 区别于持久化的 [Reminder] 实体。
class ReminderItem {
  const ReminderItem(this.title, this.subtitle, this.daysLeft);

  final String title;
  final String subtitle;
  final int daysLeft;
}