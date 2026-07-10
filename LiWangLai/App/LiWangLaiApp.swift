import SwiftData
import SwiftUI

@main
struct LiWangLaiApp: App {
    @State private var appState = AppState()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            HostedGiftEvent.self,
            GiftRecord.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Unable to create SwiftData container: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .environment(\.locale, Locale(identifier: "zh_Hans_CN"))
        }
        .modelContainer(sharedModelContainer)
    }
}
