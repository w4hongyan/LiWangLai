import SwiftData
import SwiftUI

struct RootView: View {
    @Environment(AppState.self) private var appState
    @Query(sort: \GiftRecord.date, order: .reverse) private var records: [GiftRecord]
    @Query(sort: \HostedGiftEvent.date, order: .reverse) private var hostedEvents: [HostedGiftEvent]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase

    @State private var isLocked: Bool
    @State private var migrationErrorMessage: String?
    @State private var isShowingIPadDesk = false
    @State private var selectedIPadDeskEventID: UUID?

    private var reminderRevision: String {
        records
            .sorted { $0.id.uuidString < $1.id.uuidString }
            .map {
                "\($0.id.uuidString):\($0.returnReminderDate?.timeIntervalSinceReferenceDate ?? 0):\($0.isReturned):\($0.updatedAt.timeIntervalSinceReferenceDate)"
            }
            .joined(separator: "|")
    }

    init() {
        let enabled = UserDefaults.standard.bool(forKey: "liwanglai.biometricLock")
        _isLocked = State(initialValue: enabled)
    }

    var body: some View {
        @Bindable var appState = appState
        let activeTheme = appState.selectedTheme

        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                PaperTexture()

                if UIDevice.current.userInterfaceIdiom == .pad {
                    Group {
                        if isShowingIPadDesk {
                            if geometry.size.width > geometry.size.height {
                                IPadQuickDeskView(
                                    records: records,
                                    hostedEvents: hostedEvents,
                                    initialHostedEventID: selectedIPadDeskEventID,
                                    openSettings: {
                                        isShowingIPadDesk = false
                                        appState.selectedTab = .settings
                                    }
                                )
                            } else {
                                IPadPortraitPrompt()
                            }
                        } else {
                            tabContent {
                                selectedIPadDeskEventID = nil
                                isShowingIPadDesk = true
                            }
                        }
                    }
                    .padding(.bottom, 46)

                    TabBar(selectedTab: $appState.selectedTab) { _ in
                        isShowingIPadDesk = false
                    }
                } else {
                    tabContent()
                    .padding(.bottom, 46)

                    TabBar(selectedTab: $appState.selectedTab)
                }

                if isLocked, appState.isBiometricLockEnabled {
                    LockScreenView {
                        isLocked = false
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.18), value: activeTheme)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase != .active, appState.isBiometricLockEnabled {
                isLocked = true
            }
        }
        .onChange(of: appState.isBiometricLockEnabled) { _, enabled in
            if enabled {
                isLocked = true
            }
        }
        .onChange(of: appState.ipadDeskRequest) { _, request in
            guard UIDevice.current.userInterfaceIdiom == .pad,
                  let request else { return }
            selectedIPadDeskEventID = request.hostedEventID
            isShowingIPadDesk = true
            appState.selectedTab = .home
        }
        .task {
#if DEBUG
            SampleData.seedIPadPreviewIfRequested(modelContext: modelContext)
#endif
            do {
                try HostedEventService.backfillUnambiguousLinks(
                    events: hostedEvents,
                    records: records,
                    in: modelContext
                )
            } catch {
                migrationErrorMessage = error.localizedDescription
            }
        }
        .task(id: reminderRevision) {
            guard LocalNotificationService.isEnabled else { return }
            try? await LocalNotificationService.reconcile(records: records)
        }
        .alert("数据整理未完成", isPresented: Binding(
            get: { migrationErrorMessage != nil },
            set: { if !$0 { migrationErrorMessage = nil } }
        )) {
            Button("知道了", role: .cancel) {}
        } message: {
            Text("旧版的一场事关联暂未整理完成，你的原始礼簿记录仍会保留。\n\n\(migrationErrorMessage ?? "")")
        }
    }

    @ViewBuilder
    private func tabContent(onOpenDeskMode: (() -> Void)? = nil) -> some View {
        switch appState.selectedTab {
        case .home:
            NavigationStack {
                HomeView(records: records, onOpenDeskMode: onOpenDeskMode)
            }
        case .ledger:
            NavigationStack {
                LedgerView(records: records)
            }
        case .add:
            NavigationStack {
                AddRecordView(presetType: appState.addPresetType)
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
}

private struct TabBar: View {
    @Binding var selectedTab: AppTab
    var onSelect: ((AppTab) -> Void)?

    init(selectedTab: Binding<AppTab>, onSelect: ((AppTab) -> Void)? = nil) {
        _selectedTab = selectedTab
        self.onSelect = onSelect
    }

    var body: some View {
        HStack(alignment: .bottom) {
            tab(.home, title: "今日", image: "house")
            tab(.ledger, title: "礼簿", image: "book")
            addTab
            tab(.people, title: "人情", image: "person.2")
            tab(.settings, title: "我的", image: "person")
        }
        .padding(.horizontal, 18)
        .padding(.top, 1)
        .padding(.bottom, 2)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) {
            GoldLineDivider()
        }
    }

    private func tab(_ tab: AppTab, title: String, image: String) -> some View {
        Button {
            selectedTab = tab
            onSelect?(tab)
            HapticsManager.lightTap()
        } label: {
            VStack(spacing: 2) {
                Image(systemName: selectedTab == tab ? "\(image).fill" : image)
                    .font(.system(size: 15))
                Text(title)
                    .font(.bodySong(10))
            }
            .foregroundStyle(selectedTab == tab ? LWColors.cinnabar : LWColors.inkSoft)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    private var addTab: some View {
        Button {
            selectedTab = .add
            onSelect?(.add)
            HapticsManager.lightTap()
        } label: {
            VStack(spacing: 2) {
                Image("lwl_fab_add")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .shadow(color: LWColors.cinnabar.opacity(0.14), radius: 5, x: 0, y: 3)
                Text("入簿")
                    .font(.bodySong(10))
                    .foregroundStyle(selectedTab == .add ? LWColors.cinnabar : LWColors.inkSoft)
            }
            .frame(maxWidth: .infinity)
            .offset(y: -4)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    RootView()
        .modelContainer(for: [HostedGiftEvent.self, GiftRecord.self], inMemory: true)
        .environment(AppState())
}
