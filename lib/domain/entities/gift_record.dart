/// 礼品方向（设计文档 §11.3 direction）
enum GiftDirection {
  received('received', '收礼'),
  given('given', '回礼');

  const GiftDirection(this.wire, this.label);

  /// DB 存储字符串
  final String wire;
  final String label;

  static GiftDirection fromWire(String? value) {
    return switch (value) {
      'given' => GiftDirection.given,
      _ => GiftDirection.received,
    };
  }
}

/// 事件调性（§11.3 eventTone）
enum EventTone {
  red('red', '红榜'),
  white('white', '白榜');

  const EventTone(this.wire, this.label);

  final String wire;
  final String label;

  static EventTone fromWire(String? value) =>
      value == 'white' ? EventTone.white : EventTone.red;
}

/// 记录方式（§11.3 recordMethod）
enum GiftMethod {
  cash('cash', '现金'),
  gift('gift', '礼品'),
  service('service', '出力');

  const GiftMethod(this.wire, this.label);

  final String wire;
  final String label;

  static GiftMethod fromWire(String? value) => switch (value) {
        'gift' => GiftMethod.gift,
        'service' => GiftMethod.service,
        _ => GiftMethod.cash,
      };

  /// 反向：从 UI 显示名解析（兼容旧 UI 传入 '现金'/'礼品'/'出力'）
  static GiftMethod fromLabel(String? label) => switch (label) {
        '礼品' => GiftMethod.gift,
        '出力' => GiftMethod.service,
        _ => GiftMethod.cash,
      };
}

/// 进入方式（§11.3 entryMode）
enum GiftEntryMode {
  normal('normal'),
  quickDesk('quickDesk');

  const GiftEntryMode(this.wire);

  final String wire;

  static GiftEntryMode fromWire(String? value) =>
      value == 'quickDesk' ? GiftEntryMode.quickDesk : GiftEntryMode.normal;
}

/// 补全状态（§11.3 completionStatus）
enum GiftCompletionStatus {
  complete('complete'),
  partial('partial');

  const GiftCompletionStatus(this.wire);

  final String wire;

  static GiftCompletionStatus fromWire(String? value) =>
      value == 'partial'
          ? GiftCompletionStatus.partial
          : GiftCompletionStatus.complete;
}

/// 礼金记录实体（设计文档 §11.3）
///
/// 字段命名沿用既有 UI API（book/event/date/method/...），内部值映射到
/// 文档要求的 ledgerBookId/eventType/eventDate/recordMethod；扩展字段全部可选。
// ignore_for_file: prefer_initializing_formals, unnecessary_this
class GiftRecord {
  GiftRecord({
    required this.id,
    required this.name,
    required this.relation,
    required this.event,
    required this.direction,
    required this.tone,
    required this.amount,
    required this.date,
    required this.method,
    required this.book,
    this.note = '',
    this.itemDescription = '',
    this.partial = false,
    this.needReturn = false,
    // ===== 设计文档 §11.3 扩展字段（全部可选）=====
    this.personId,
    this.nickname,
    this.relationLabel,
    this.phone,
    this.estimatedAmount,
    this.giftName,
    this.serviceDescription,
    this.lunarDate,
    this.returnedRecordId,
    this.entryMode = GiftEntryMode.normal,
    GiftCompletionStatus? completionStatus,
    this.quickScene,
    this.tempRelationText,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isDeleted = false,
  })  : _createdAt = createdAt,
        _updatedAt = updatedAt,
        completionStatus = completionStatus ??
            (partial
                ? GiftCompletionStatus.partial
                : GiftCompletionStatus.complete);

  // ===== 主要字段（与 UI 旧 API 对齐）=====
  final String id;
  final String name;
  final String relation;
  final String event;
  final GiftDirection direction;
  final EventTone tone;
  final int amount;
  final DateTime date;
  final String method;
  final String book;
  final String note;
  final String itemDescription;
  final bool partial;
  final bool needReturn;

  // ===== 设计文档 §11.3 扩展字段 =====
  final String? personId;
  final String? nickname;
  final String? relationLabel;
  final String? phone;
  final int? estimatedAmount;
  final String? giftName;
  final String? serviceDescription;
  final String? lunarDate;
  final String? returnedRecordId;
  final GiftEntryMode entryMode;
  final GiftCompletionStatus completionStatus;
  final String? quickScene;
  final String? tempRelationText;
  final bool isDeleted;
  final DateTime? _createdAt;
  final DateTime? _updatedAt;

  /// 创建时间。显式传 null 时 fallback 到 1970-01-01（用于 UI 默认值）。
  DateTime get createdAt => _createdAt ?? _epoch;

  /// 更新时间。语义同上。
  DateTime get updatedAt => _updatedAt ?? _createdAt ?? _epoch;

  /// 文档字段别名
  String get ledgerBookId => book;
  String get eventType => event;
  String get eventToneWire => tone.wire;
  GiftMethod get recordMethod => GiftMethod.fromLabel(method);
  DateTime get eventDate => date;

  GiftRecord copyWith({
    String? id,
    String? name,
    String? relation,
    String? event,
    GiftDirection? direction,
    EventTone? tone,
    int? amount,
    DateTime? date,
    String? method,
    String? book,
    String? note,
    String? itemDescription,
    bool? partial,
    bool? needReturn,
    String? personId,
    String? nickname,
    String? relationLabel,
    String? phone,
    int? estimatedAmount,
    String? giftName,
    String? serviceDescription,
    String? lunarDate,
    String? returnedRecordId,
    GiftEntryMode? entryMode,
    GiftCompletionStatus? completionStatus,
    String? quickScene,
    String? tempRelationText,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return GiftRecord(
      id: id ?? this.id,
      name: name ?? this.name,
      relation: relation ?? this.relation,
      event: event ?? this.event,
      direction: direction ?? this.direction,
      tone: tone ?? this.tone,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      method: method ?? this.method,
      book: book ?? this.book,
      note: note ?? this.note,
      itemDescription: itemDescription ?? this.itemDescription,
      partial: partial ?? this.partial,
      needReturn: needReturn ?? this.needReturn,
      personId: personId ?? this.personId,
      nickname: nickname ?? this.nickname,
      relationLabel: relationLabel ?? this.relationLabel,
      phone: phone ?? this.phone,
      estimatedAmount: estimatedAmount ?? this.estimatedAmount,
      giftName: giftName ?? this.giftName,
      serviceDescription: serviceDescription ?? this.serviceDescription,
      lunarDate: lunarDate ?? this.lunarDate,
      returnedRecordId: returnedRecordId ?? this.returnedRecordId,
      entryMode: entryMode ?? this.entryMode,
      completionStatus: completionStatus ?? this.completionStatus,
      quickScene: quickScene ?? this.quickScene,
      tempRelationText: tempRelationText ?? this.tempRelationText,
      createdAt: createdAt ?? this._createdAt,
      updatedAt: updatedAt ?? this._updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  static final DateTime _epoch = DateTime.fromMillisecondsSinceEpoch(0);
}

/// 收/支合计（UI 使用）
class LedgerTotals {
  const LedgerTotals({required this.received, required this.given});

  final int received;
  final int given;

  int get balance => received - given;

  factory LedgerTotals.fromRecords(Iterable<GiftRecord> records) {
    var received = 0;
    var given = 0;
    for (final record in records) {
      if (record.direction == GiftDirection.received) {
        received += record.amount;
      } else {
        given += record.amount;
      }
    }
    return LedgerTotals(received: received, given: given);
  }
}