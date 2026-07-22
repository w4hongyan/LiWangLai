import Foundation
import SwiftData

enum BackupService {
    static let formatVersion = 1

    enum BackupError: LocalizedError, Equatable {
        case emptyData
        case unsupportedVersion(Int)
        case invalidFile

        var errorDescription: String? {
            switch self {
            case .emptyData:
                "还没有可以备份的数据。"
            case .unsupportedVersion(let version):
                "这个备份来自不支持的格式版本（\(version)）。"
            case .invalidFile:
                "无法读取这个礼往来备份文件。"
            }
        }
    }

    struct Summary: Equatable {
        let recordCount: Int
        let eventCount: Int
        let createdAt: Date
    }

    struct PreparedBackup {
        fileprivate let envelope: Envelope

        var summary: Summary {
            Summary(
                recordCount: envelope.records.count,
                eventCount: envelope.events.count,
                createdAt: envelope.createdAt
            )
        }
    }

    static func writeBackup(records: [GiftRecord], events: [HostedGiftEvent]) throws -> URL {
        let data = try makeData(records: records, events: events)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd-HHmm"
        let fileName = "礼往来完整备份-\(formatter.string(from: .now)).json"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try data.write(to: url, options: .atomic)
        return url
    }

    static func makeData(records: [GiftRecord], events: [HostedGiftEvent]) throws -> Data {
        guard !records.isEmpty || !events.isEmpty else { throw BackupError.emptyData }
        let envelope = Envelope(
            formatVersion: formatVersion,
            createdAt: .now,
            records: records.map(RecordSnapshot.init),
            events: events.map(EventSnapshot.init)
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(envelope)
    }

    static func prepareRestore(from data: Data) throws -> PreparedBackup {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let envelope = try? decoder.decode(Envelope.self, from: data) else {
            throw BackupError.invalidFile
        }
        guard envelope.formatVersion == formatVersion else {
            throw BackupError.unsupportedVersion(envelope.formatVersion)
        }
        guard !envelope.records.isEmpty || !envelope.events.isEmpty else {
            throw BackupError.invalidFile
        }
        guard Set(envelope.records.map(\.id)).count == envelope.records.count,
              Set(envelope.events.map(\.id)).count == envelope.events.count else {
            throw BackupError.invalidFile
        }
        return PreparedBackup(envelope: envelope)
    }

    @MainActor
    @discardableResult
    static func restore(_ backup: PreparedBackup, in context: ModelContext) throws -> Summary {
        let existingRecords = try context.fetch(FetchDescriptor<GiftRecord>())
        let existingEvents = try context.fetch(FetchDescriptor<HostedGiftEvent>())

        existingRecords.forEach(context.delete)
        existingEvents.forEach(context.delete)

        // 手工编辑过的备份可能带悬空 hostedEventID，恢复前按备份内的场次集合校验，悬空一律置 nil。
        let validEventIDs = Set(backup.envelope.events.map(\.id))
        for snapshot in backup.envelope.events {
            context.insert(snapshot.model)
        }
        for snapshot in backup.envelope.records {
            context.insert(snapshot.model(validEventIDs: validEventIDs))
        }

        do {
            try context.save()
            return backup.summary
        } catch {
            context.rollback()
            throw error
        }
    }
}

private extension BackupService {
    struct Envelope: Codable {
        let formatVersion: Int
        let createdAt: Date
        let records: [RecordSnapshot]
        let events: [EventSnapshot]
    }

    struct RecordSnapshot: Codable {
        let id: UUID
        let personName: String
        let type: GiftRecordType
        let amountYuan: Int
        let amountFen: Int?
        let personID: UUID?
        let eventType: GiftEventType
        let relationship: RelationshipType
        let date: Date
        let note: String
        let isReturned: Bool
        let returnReminderDate: Date?
        let location: String
        let giftName: String
        let contact: String
        let createdAt: Date
        let updatedAt: Date
        let hostedEventID: UUID?

        init(_ record: GiftRecord) {
            id = record.id
            personName = record.personName
            type = record.type
            amountYuan = record.amountYuan
            amountFen = record.amountFenValue
            personID = record.personID
            eventType = record.eventType
            relationship = record.relationship
            date = record.date
            note = record.note
            isReturned = record.isReturned
            returnReminderDate = record.returnReminderDate
            location = record.location
            giftName = record.giftName
            contact = record.contact
            createdAt = record.createdAt
            updatedAt = record.updatedAt
            hostedEventID = record.hostedEventID
        }

        func model(validEventIDs: Set<UUID>) -> GiftRecord {
            let resolvedHostedEventID = hostedEventID.flatMap { validEventIDs.contains($0) ? $0 : nil }
            return GiftRecord(
                id: id,
                personName: personName,
                type: type,
                amountYuan: amountYuan,
                amountFen: amountFen ?? amountYuan * 100,
                personID: personID,
                eventType: eventType,
                relationship: relationship,
                date: date,
                note: note,
                isReturned: isReturned,
                returnReminderDate: returnReminderDate,
                location: location,
                giftName: giftName,
                contact: contact,
                createdAt: createdAt,
                updatedAt: updatedAt,
                hostedEventID: resolvedHostedEventID
            )
        }
    }

    struct EventSnapshot: Codable {
        let id: UUID
        let title: String
        let eventType: GiftEventType
        let date: Date
        let note: String
        let createdAt: Date
        let updatedAt: Date

        init(_ event: HostedGiftEvent) {
            id = event.id
            title = event.title
            eventType = event.eventType
            date = event.date
            note = event.note
            createdAt = event.createdAt
            updatedAt = event.updatedAt
        }

        var model: HostedGiftEvent {
            HostedGiftEvent(
                id: id,
                title: title,
                eventType: eventType,
                date: date,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt
            )
        }
    }
}
