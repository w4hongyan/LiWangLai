import SwiftData

enum LiWangLaiSchemaV1: VersionedSchema {
    // The original unversioned SwiftData schema also uses 1.0.0 by default.
    // Keep the first explicit schema on that identifier so existing stores can
    // be adopted without inventing a migration between identical models.
    static let versionIdentifier = Schema.Version(1, 0, 0)
    static let models: [any PersistentModel.Type] = [
        HostedGiftEvent.self,
        GiftRecord.self
    ]
}

enum LiWangLaiMigrationPlan: SchemaMigrationPlan {
    static let schemas: [any VersionedSchema.Type] = [
        LiWangLaiSchemaV1.self
    ]

    static let stages: [MigrationStage] = []
}
