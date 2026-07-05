import SwiftData
import SwiftUI

struct RootView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \GiftRecord.date, order: .reverse) private var records: [GiftRecord]

    var body: some View {
        @Bindable var appState = appState

        ZStack(alignment: .bottom) {
            PaperTexture()

            Group {
                switch appState.selectedTab {
                case .home:
                    NavigationStack {
                        HomeView(records: records)
                    }
                case .ledger:
                    NavigationStack {
                        LedgerView(records: records)
                    }
                case .add:
                    NavigationStack {
                        AddRecordView()
                    }
                case .people:
                    NavigationStack {
                        PeopleView(records: records)
                    }
                case .settings:
                    NavigationStack {
                        SettingsView(records: records)
                    }
                }
            }
            .padding(.bottom, 66)

            TabBar(selectedTab: $appState.selectedTab)
        }
        .task {
            MockData.seedIfNeeded(context: modelContext, existingCount: records.count)
        }
    }
}

private struct TabBar: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack(alignment: .bottom) {
            tab(.home, title: "今日", image: "house")
            tab(.ledger, title: "礼簿", image: "book")
            addTab
            tab(.people, title: "人情", image: "person.2")
            tab(.settings, title: "我的", image: "person")
        }
        .padding(.horizontal, 18)
        .padding(.top, 6)
        .padding(.bottom, 14)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) {
            GoldLineDivider()
        }
    }

    private func tab(_ tab: AppTab, title: String, image: String) -> some View {
        Button {
            selectedTab = tab
            HapticsManager.lightTap()
        } label: {
            VStack(spacing: 4) {
                Image(systemName: selectedTab == tab ? "\(image).fill" : image)
                    .font(.system(size: 20))
                Text(title)
                    .font(.bodySong(11))
            }
            .foregroundStyle(selectedTab == tab ? LWColors.cinnabar : LWColors.inkSoft)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    private var addTab: some View {
        Button {
            selectedTab = .add
            HapticsManager.lightTap()
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [LWColors.cinnabar, LWColors.cinnabarDark],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 46, height: 46)
                        .shadow(color: LWColors.cinnabar.opacity(0.22), radius: 10, x: 0, y: 5)
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(.white)
                }
                Text("入簿")
                    .font(.bodySong(11))
                    .foregroundStyle(selectedTab == .add ? LWColors.cinnabar : LWColors.inkSoft)
            }
            .frame(maxWidth: .infinity)
            .offset(y: -12)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    RootView()
        .modelContainer(for: GiftRecord.self, inMemory: true)
        .environment(AppState())
}
