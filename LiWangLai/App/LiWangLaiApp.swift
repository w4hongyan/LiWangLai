import SwiftData
import SwiftUI
import UserNotifications

@main
struct LiWangLaiApp: App {
    @State private var appState = AppState()
    private let modelBootstrap = ModelContainerBootstrap.make()
    private let notificationDelegate = AppNotificationDelegate()

    init() {
        UNUserNotificationCenter.current().delegate = notificationDelegate
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if let errorDescription = modelBootstrap.errorDescription {
                    DataStoreRecoveryView(errorDescription: errorDescription)
                } else {
                    RootView()
                }
            }
            .environment(appState)
            .environment(\.locale, Locale(identifier: "zh_Hans_CN"))
        }
        .modelContainer(modelBootstrap.container)
    }
}

private final class AppNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}

struct ModelContainerBootstrap {
    let container: ModelContainer
    let errorDescription: String?

    @MainActor
    static func make(
        persistentStore: @MainActor () throws -> ModelContainer = makePersistentStore,
        fallbackStore: @MainActor () throws -> ModelContainer = makeFallbackStore
    ) -> ModelContainerBootstrap {
        do {
            return ModelContainerBootstrap(
                container: try persistentStore(),
                errorDescription: nil
            )
        } catch {
            let persistentError = error
            do {
                return ModelContainerBootstrap(
                    container: try fallbackStore(),
                    errorDescription: persistentError.localizedDescription
                )
            } catch {
                fatalError("Unable to create fallback SwiftData container: \(error)")
            }
        }
    }

    @MainActor
    private static func makePersistentStore() throws -> ModelContainer {
        let schema = Schema(versionedSchema: LiWangLaiSchemaV1.self)
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        return try ModelContainer(
            for: schema,
            migrationPlan: LiWangLaiMigrationPlan.self,
            configurations: [configuration]
        )
    }

    @MainActor
    private static func makeFallbackStore() throws -> ModelContainer {
        let schema = Schema(versionedSchema: LiWangLaiSchemaV1.self)
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(
            for: schema,
            migrationPlan: LiWangLaiMigrationPlan.self,
            configurations: [configuration]
        )
    }
}

private struct DataStoreRecoveryView: View {
    let errorDescription: String

    var body: some View {
        ZStack {
            PaperTexture()
            VStack(spacing: 18) {
                SealStamp(text: "护", size: 72, color: LWColors.cinnabar)
                Text("暂时无法打开礼簿")
                    .font(.titleSong(24))
                    .foregroundStyle(LWColors.ink)
                Text("原有数据没有被重建或覆盖。请完全退出 App 后重新打开；如果仍然失败，请保留设备上的 App 数据并联系支持。")
                    .font(.bodySong(14))
                    .foregroundStyle(LWColors.inkSoft)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                Text(errorDescription)
                    .font(.caption)
                    .foregroundStyle(LWColors.muted)
                    .multilineTextAlignment(.center)
                    .textSelection(.enabled)
            }
            .padding(28)
        }
    }
}
