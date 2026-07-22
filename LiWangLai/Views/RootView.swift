import SwiftData
import SwiftUI

struct RootView: View {
    @Environment(AppState.self) private var appState
    @Environment(PurchaseManager.self) private var purchases
    @Query(sort: \GiftRecord.date, order: .reverse) private var records: [GiftRecord]
    @Query(sort: \HostedGiftEvent.date, order: .reverse) private var hostedEvents: [HostedGiftEvent]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase

    @State private var isLocked: Bool
    @State private var migrationErrorMessage: String?
    @State private var isShowingDesk = false
    @State private var selectedDeskEventID: UUID?
    @State private var showsOnboarding = false
    @AppStorage("liwanglai.hasSeenOnboarding") private var hasSeenOnboarding = false

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
        @Bindable var purchases = purchases
        let activeTheme = appState.selectedTheme

        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                PaperTexture()

                if isShowingDesk {
                    if geometry.size.width > geometry.size.height {
                        IPadQuickDeskView(
                            records: records,
                            hostedEvents: hostedEvents,
                            initialHostedEventID: selectedDeskEventID,
                            openSettings: {
                                isShowingDesk = false
                                appState.selectedTab = .settings
                            }
                        )
                    } else {
                        DeskPortraitPrompt {
                            isShowingDesk = false
                        }
                    }
                } else {
                    tabContent {
                        openDeskMode(hostedEventID: nil)
                    }
                    .padding(.bottom, 46)

                    TabBar(selectedTab: $appState.selectedTab) { _ in
                        isShowingDesk = false
                    }
                }

                if isLocked, appState.isBiometricLockEnabled {
                    LockScreenView {
                        isLocked = false
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.18), value: activeTheme)
        .onAppear {
#if DEBUG
            let isAutomation = ProcessInfo.processInfo.arguments.contains("-liwanglaiSeedScreenshots")
#else
            let isAutomation = false
#endif
            if !hasSeenOnboarding, !isAutomation {
                showsOnboarding = true
            }
        }
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
        .onChange(of: purchases.hasLoadedEntitlements) { _, loaded in
            guard loaded, !purchases.isProUnlocked else { return }
            if appState.selectedTheme != .paper {
                appState.selectedTheme = .paper
            }
        }
        .onChange(of: appState.deskRequest) { _, request in
            guard let request else { return }
            openDeskMode(hostedEventID: request.hostedEventID)
            appState.deskRequest = nil
        }
        .task {
            await purchases.start()
#if DEBUG
            if ProcessInfo.processInfo.arguments.contains("-liwanglaiSeedScreenshots") {
                SampleData.seedIfEmpty(modelContext: modelContext)
            }
            SampleData.seedIPadPreviewIfRequested(modelContext: modelContext)
            if ProcessInfo.processInfo.arguments.contains("-liwanglaiShowPaywall") {
                purchases.presentPaywall()
            }
            if ProcessInfo.processInfo.arguments.contains("-liwanglaiShowDesk") {
                try? await Task.sleep(for: .milliseconds(350))
                openDeskMode(hostedEventID: hostedEvents.first?.id)
            }
#endif
            do {
                try RecordService.backfillPersonIDs(records: records, in: modelContext)
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
            Text("旧版人物或场次关联暂未整理完成，你的原始礼簿记录仍会保留。\n\n\(migrationErrorMessage ?? "")")
        }
        .sheet(item: $purchases.paywallSource) { source in
            ProPaywallView(source: source)
        }
        .fullScreenCover(isPresented: $showsOnboarding) {
            FirstLaunchGuide {
                hasSeenOnboarding = true
                showsOnboarding = false
            }
        }
    }

    private func openDeskMode(hostedEventID: UUID?) {
        guard purchases.isProUnlocked else {
            purchases.presentPaywall(for: .deskMode)
            return
        }
        selectedDeskEventID = hostedEventID
        isShowingDesk = true
        appState.selectedTab = .home
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

private struct FirstLaunchGuide: View {
    let finish: () -> Void

    var body: some View {
        ZStack {
            PaperTexture()
            ScrollView {
                VStack(spacing: 22) {
                    Spacer(minLength: 36)
                    SealStamp(text: "礼", size: 82, color: LWColors.cinnabar)
                    VStack(spacing: 8) {
                        Text("把人情往来记明白")
                            .font(.titleSong(30))
                            .foregroundStyle(LWColors.ink)
                        Text("收礼、送礼、回礼提醒，一本礼簿都管好")
                            .font(.bodySong(15))
                            .foregroundStyle(LWColors.muted)
                            .multilineTextAlignment(.center)
                    }

                    PaperCard(padding: 16, spacing: 16) {
                        guideRow("1", title: "先记一笔", detail: "填写姓名、金额和事件；金额支持两位小数。")
                        GoldLineDivider()
                        guideRow("2", title: "需要回礼就设日期", detail: "设了提醒日期的收礼会统一进入“待回礼”。")
                        GoldLineDivider()
                        guideRow("3", title: "办喜事用一场事", detail: "现场连续登记，结束后可一键设置本场回礼提醒。")
                    }

                    SealButton(
                        title: "开始记礼",
                        systemImage: "book.closed",
                        fontSize: 16,
                        verticalPadding: 12,
                        cornerRadius: 16,
                        action: finish
                    )
                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 24)
            }
        }
    }

    private func guideRow(_ number: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            SealStamp(text: number, size: 34, color: LWColors.warmGold)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.titleSong(16))
                    .foregroundStyle(LWColors.ink)
                Text(detail)
                    .font(.bodySong(13))
                    .foregroundStyle(LWColors.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
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
        .environment(PurchaseManager())
}
