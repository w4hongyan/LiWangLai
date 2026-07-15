import Foundation
import SwiftData
import Testing
@testable import LiWangLai

struct BackupServiceTests {
    @Test func emptyBackupThrows() {
        #expect(throws: BackupService.BackupError.emptyData) {
            try BackupService.makeData(records: [], events: [])
        }
    }

    @Test func backupSummaryContainsRecordsAndEvents() throws {
        let event = HostedGiftEvent(title: "我家婚礼", eventType: .wedding)
        let record = GiftRecord(
            personName: "张三",
            type: .received,
            amountYuan: 600,
            eventType: .wedding,
            relationship: .friend,
            hostedEventID: event.id
        )

        let data = try BackupService.makeData(records: [record], events: [event])
        let backup = try BackupService.prepareRestore(from: data)

        #expect(backup.summary.recordCount == 1)
        #expect(backup.summary.eventCount == 1)
    }

    @MainActor
    @Test func restoreReplacesExistingDataAndPreservesLinks() throws {
        let backupEvent = HostedGiftEvent(title: "备份里的婚礼", eventType: .wedding)
        let backupRecord = GiftRecord(
            personName: "备份用户",
            type: .received,
            amountYuan: 888,
            eventType: .wedding,
            relationship: .friend,
            hostedEventID: backupEvent.id
        )
        let data = try BackupService.makeData(records: [backupRecord], events: [backupEvent])
        let backup = try BackupService.prepareRestore(from: data)

        let schema = Schema([HostedGiftEvent.self, GiftRecord.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        container.mainContext.insert(GiftRecord(
            personName: "旧用户",
            type: .given,
            amountYuan: 200,
            eventType: .festival,
            relationship: .other
        ))
        try container.mainContext.save()

        try BackupService.restore(backup, in: container.mainContext)

        let records = try container.mainContext.fetch(FetchDescriptor<GiftRecord>())
        let events = try container.mainContext.fetch(FetchDescriptor<HostedGiftEvent>())
        #expect(records.count == 1)
        #expect(records.first?.personName == "备份用户")
        #expect(records.first?.hostedEventID == events.first?.id)
    }

    @MainActor
    @Test func versionedSchemaCreatesContainer() throws {
        let schema = Schema(versionedSchema: LiWangLaiSchemaV1.self)
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        _ = try ModelContainer(
            for: schema,
            migrationPlan: LiWangLaiMigrationPlan.self,
            configurations: [configuration]
        )
    }

    @MainActor
    @Test func versionedSchemaOpensLegacyUnversionedStore() throws {
        let directory = FileManager.default.temporaryDirectory
            .appending(path: UUID().uuidString, directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        let storeURL = directory.appending(path: "legacy.store")
        do {
            let legacySchema = Schema([HostedGiftEvent.self, GiftRecord.self])
            let legacyConfiguration = ModelConfiguration(schema: legacySchema, url: storeURL)
            let legacyContainer = try ModelContainer(
                for: legacySchema,
                configurations: [legacyConfiguration]
            )
            legacyContainer.mainContext.insert(GiftRecord(
                personName: "旧版本数据",
                type: .received,
                amountYuan: 600,
                eventType: .wedding,
                relationship: .friend
            ))
            try legacyContainer.mainContext.save()
        }

        let currentSchema = Schema(versionedSchema: LiWangLaiSchemaV1.self)
        let currentConfiguration = ModelConfiguration(schema: currentSchema, url: storeURL)
        let currentContainer = try ModelContainer(
            for: currentSchema,
            migrationPlan: LiWangLaiMigrationPlan.self,
            configurations: [currentConfiguration]
        )
        let records = try currentContainer.mainContext.fetch(FetchDescriptor<GiftRecord>())

        #expect(records.count == 1)
        #expect(records.first?.personName == "旧版本数据")
    }
}
