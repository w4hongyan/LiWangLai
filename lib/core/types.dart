/// 类型 barrel：让所有引用同一套领域类型，避免
/// `import 'main.dart' as app` 与 `import 'domain/...'`
/// 被 Dart 识别为两个不同的 GiftRecord。
library;

export '../domain/entities/gift_record.dart'
    show
        GiftRecord,
        GiftDirection,
        EventTone,
        GiftMethod,
        GiftEntryMode,
        GiftCompletionStatus,
        LedgerTotals;
export '../domain/entities/ledger_book.dart'
    show LedgerBook, LedgerBookType;
export '../domain/entities/person.dart' show Person;
export '../domain/entities/reminder.dart' show Reminder, ReminderItem;
export '../domain/entities/gift_template.dart' show GiftTemplate;
export '../domain/services/return_gift_advisor.dart'
    show ReturnGiftAdvisor, ReturnGiftSuggestion;