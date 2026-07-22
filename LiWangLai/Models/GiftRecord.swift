import Foundation
import SwiftData

@Model
final class GiftRecord {
    @Attribute(.unique) var id: UUID
    var personName: String
    var typeRawValue: String
    var amountYuan: Int
    /// 新版精确金额（分）。旧数据为空时由 amountYuan × 100 兼容读取。
    var amountFen: Int?
    /// 稳定人物身份；避免修改手机号后被拆成两个往来人。
    var personID: UUID?
    var eventTypeRawValue: String
    var relationshipRawValue: String
    var date: Date
    var note: String
    var isReturned: Bool
    var returnReminderDate: Date?
    var location: String
    var giftName: String
   var contact: String
   var createdAt: Date
   var updatedAt: Date
    var hostedEventID: UUID?

   init(
       id: UUID = UUID(),
       personName: String,
       type: GiftRecordType,
       amountYuan: Int,
       amountFen: Int? = nil,
       personID: UUID? = nil,
       eventType: GiftEventType,
       relationship: RelationshipType,
       date: Date = .now,
       note: String = "",
       isReturned: Bool = false,
       returnReminderDate: Date? = nil,
       location: String = "",
       giftName: String = "",
       contact: String = "",
       createdAt: Date = .now,
        updatedAt: Date = .now,
        hostedEventID: UUID? = nil
   ) {
       self.id = id
       self.personName = personName
       self.typeRawValue = type.rawValue
       self.amountYuan = amountYuan
       self.amountFen = amountFen ?? amountYuan * 100
       self.personID = personID
       self.eventTypeRawValue = eventType.rawValue
       self.relationshipRawValue = relationship.rawValue
       self.date = date
       self.note = note
       self.isReturned = isReturned
       self.returnReminderDate = returnReminderDate
       self.location = location
       self.giftName = giftName
       self.contact = contact
       self.createdAt = createdAt
       self.updatedAt = updatedAt
        self.hostedEventID = hostedEventID
   }

    var type: GiftRecordType {
        get { GiftRecordType(rawValue: typeRawValue) ?? .received }
        set { typeRawValue = newValue.rawValue }
    }

    var eventType: GiftEventType {
        get { GiftEventType(rawValue: eventTypeRawValue) ?? .other }
        set { eventTypeRawValue = newValue.rawValue }
    }

    var relationship: RelationshipType {
        get { RelationshipType(rawValue: relationshipRawValue) ?? .other }
        set { relationshipRawValue = newValue.rawValue }
    }

    var amountFenValue: Int {
        amountFen ?? amountYuan * 100
    }

    func setAmount(fen: Int) {
        amountFen = fen
        // 保留旧字段，便于旧格式备份以及降级诊断；精确值始终读取 amountFen。
        amountYuan = fen / 100
    }

    var needsReturn: Bool {
        type == .received && !isReturned && returnReminderDate != nil
    }

    var returnStatusText: String? {
        guard type == .received else { return nil }
        if isReturned { return "已回" }
        if needsReturn { return "待回" }
        return nil
    }
}
