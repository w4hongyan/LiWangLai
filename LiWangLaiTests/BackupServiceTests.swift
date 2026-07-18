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

    @Test func invalidBackupDataIsRejected() {
        #expect(throws: BackupService.BackupError.invalidFile) {
            try BackupService.prepareRestore(from: Data("not-json".utf8))
        }
    }

    @Test func unsupportedBackupVersionIsRejected() {
        let json = """
        {
          "formatVersion": 999,
          "createdAt": "2026-07-17T00:00:00Z",
          "records": [],
          "events": []
        }
        """

        #expect(throws: BackupService.BackupError.unsupportedVersion(999)) {
            try BackupService.prepareRestore(from: Data(json.utf8))
        }
    }

    @Test func emptyRestoreFileIsRejected() {
        let json = """
        {
          "formatVersion": 1,
          "createdAt": "2026-07-17T00:00:00Z",
          "records": [],
          "events": []
        }
        """

        #expect(throws: BackupService.BackupError.invalidFile) {
            try BackupService.prepareRestore(from: Data(json.utf8))
        }
    }

    @Test func writeBackupCreatesJSONFile() throws {
        let record = GiftRecord(
            personName: "备份测试",
            type: .received,
            amountYuan: 600,
            eventType: .wedding,
            relationship: .friend
        )

        let url = try BackupService.writeBackup(records: [record], events: [])
        defer { try? FileManager.default.removeItem(at: url) }

        #expect(url.pathExtension == "json")
        #expect(FileManager.default.fileExists(atPath: url.path))
        #expect(try Data(contentsOf: url).isEmpty == false)
    }

    @Test func restoreRejectsDuplicateRecordAndEventIDs() throws {
        let record = GiftRecord(
            personName: "重复记录",
            type: .received,
            amountYuan: 600,
            eventType: .wedding,
            relationship: .friend
        )
        let duplicatedRecords = try BackupService.makeData(records: [record, record], events: [])
        #expect(throws: BackupService.BackupError.invalidFile) {
            try BackupService.prepareRestore(from: duplicatedRecords)
        }

        let event = HostedGiftEvent(title: "重复活动", eventType: .wedding)
        let duplicatedEvents = try BackupService.makeData(records: [], events: [event, event])
        #expect(throws: BackupService.BackupError.invalidFile) {
            try BackupService.prepareRestore(from: duplicatedEvents)
        }
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

    @MainActor
    @Test func modelBootstrapUsesPersistentStoreWhenAvailable() throws {
        let container = try makeInMemoryContainer()
        let result = ModelContainerBootstrap.make(
            persistentStore: { container },
            fallbackStore: { throw BootstrapTestError.fallbackShouldNotRun }
        )

        #expect(result.errorDescription == nil)
        #expect(result.container === container)
    }

    @MainActor
    @Test func modelBootstrapShowsRecoveryWithoutOverwritingData() throws {
        let fallback = try makeInMemoryContainer()
        let result = ModelContainerBootstrap.make(
            persistentStore: { throw BootstrapTestError.persistentStoreFailed },
            fallbackStore: { fallback }
        )

        #expect(result.errorDescription == "测试数据库无法打开")
        #expect(result.container === fallback)
        #expect(try fallback.mainContext.fetch(FetchDescriptor<GiftRecord>()).isEmpty)
    }

    @MainActor
    private func makeInMemoryContainer() throws -> ModelContainer {
        let schema = Schema(versionedSchema: LiWangLaiSchemaV1.self)
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(
            for: schema,
            migrationPlan: LiWangLaiMigrationPlan.self,
            configurations: [configuration]
        )
    }
}

private enum BootstrapTestError: LocalizedError {
    case persistentStoreFailed
    case fallbackShouldNotRun

    var errorDescription: String? {
        switch self {
        case .persistentStoreFailed: "测试数据库无法打开"
        case .fallbackShouldNotRun: "不应创建备用数据库"
        }
    }
}
