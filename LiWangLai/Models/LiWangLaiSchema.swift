import Foundation
import SwiftData

/// 首发未版本化数据库的逐字段快照。这里的模型形状保持冻结，后续字段只加到新 Schema。
enum LiWangLaiSchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)

    static let models: [any PersistentModel.Type] = [
        HostedGiftEvent.self,
        GiftRecord.self
    ]

    @Model
    final class HostedGiftEvent {
        @Attribute(.unique) var id: UUID
        var title: String
        var eventTypeRawValue: String
        var date: Date
        var note: String
        var createdAt: Date
        var updatedAt: Date

        init(
            id: UUID = UUID(),
            title: String,
            eventTypeRawValue: String,
            date: Date = .now,
            note: String = "",
            createdAt: Date = .now,
            updatedAt: Date = .now
        ) {
            self.id = id
            self.title = title
            self.eventTypeRawValue = eventTypeRawValue
            self.date = date
            self.note = note
            self.createdAt = createdAt
            self.updatedAt = updatedAt
        }
    }

    @Model
    final class GiftRecord {
        @Attribute(.unique) var id: UUID
        var personName: String
        var typeRawValue: String
        var amountYuan: Int
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
            typeRawValue: String,
            amountYuan: Int,
            eventTypeRawValue: String,
            relationshipRawValue: String,
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
            self.typeRawValue = typeRawValue
            self.amountYuan = amountYuan
            self.eventTypeRawValue = eventTypeRawValue
            self.relationshipRawValue = relationshipRawValue
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
    }
}

/// V2 增加可选 amountFen，以固定小数精度保存金额；旧 amountYuan 字段继续保留兼容读取。
enum LiWangLaiSchemaV2: VersionedSchema {
    static let versionIdentifier = Schema.Version(2, 0, 0)
    static let models: [any PersistentModel.Type] = [
        HostedGiftEvent.self,
        GiftRecord.self
    ]
}

enum LiWangLaiMigrationPlan: SchemaMigrationPlan {
    static let schemas: [any VersionedSchema.Type] = [
        LiWangLaiSchemaV1.self,
        LiWangLaiSchemaV2.self
    ]

    static let stages: [MigrationStage] = [
        .lightweight(fromVersion: LiWangLaiSchemaV1.self, toVersion: LiWangLaiSchemaV2.self)
    ]
}
