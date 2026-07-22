import SwiftUI

struct HomeView: View {
    @Environment(AppState.self) private var appState
    @Environment(PurchaseManager.self) private var purchases
    let records: [GiftRecord]
    let onOpenDeskMode: (() -> Void)?

    init(records: [GiftRecord], onOpenDeskMode: (() -> Void)? = nil) {
        self.records = records
        self.onOpenDeskMode = onOpenDeskMode
    }

    private var filteredRecords: [GiftRecord] {
        SearchService.filter(records, query: appState.homeSearchText)
    }

    private var reminders: [ReminderItem] {
        ReminderService.reminders(from: records)
    }

    private var returnGiftReminderCount: Int {
        reminders.filter { $0.kind == .returnGift }.count
    }

    private var sendGiftReminderCount: Int {
        reminders.filter { $0.kind == .sendGift }.count
    }

    private var currentYearRecords: [GiftRecord] {
        records.filter { Calendar.current.component(.year, from: $0.date) == Calendar.current.component(.year, from: .now) }
    }

    private var lastYearRecords: [GiftRecord] {
        let lastYear = Calendar.current.component(.year, from: .now) - 1
        return records.filter { Calendar.current.component(.year, from: $0.date) == lastYear }
    }

    private var totalReceivedFen: Int {
        currentYearRecords.filter { $0.type == .received }.reduce(0) { $0 + $1.amountFenValue }
    }

    private var totalGivenFen: Int {
        currentYearRecords.filter { $0.type == .given }.reduce(0) { $0 + $1.amountFenValue }
    }

    private var lastYearNetFen: Int {
        let received = lastYearRecords.filter { $0.type == .received }.reduce(0) { $0 + $1.amountFenValue }
        let given = lastYearRecords.filter { $0.type == .given }.reduce(0) { $0 + $1.amountFenValue }
        return received - given
    }

    var body: some View {
        @Bindable var appState = appState

        ScrollView {
            VStack(alignment: .leading, spacing: 11) {
                homeHero

                if let onOpenDeskMode {
                    deskModeButton(action: onOpenDeskMode)
                }

                SearchField(placeholder: "搜索姓名 / 事件 / 备注", text: $appState.homeSearchText, fontSize: 14, iconSize: 18, verticalPadding: 9)

                if !appState.homeSearchText.isEmpty {
                    searchResults
                } else {
                    reminderCard
                    yearlyCard
                    recentCard
                    quickActions
                }
            }
            .padding(.horizontal, LWSpacing.page)
            .padding(.top, -4)
            .padding(.bottom, 64)
        }
        .scrollIndicators(.hidden)
        .background(PaperTexture())
    }

    private var homeHero: some View {
        ZStack(alignment: .topTrailing) {
            Image("prototype_header_mountain_plum")
                .resizable()
                .scaledToFit()
                .frame(width: 236)
                .offset(x: 24, y: 8)
                .opacity(0.88)
                .allowsHitTesting(false)

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("礼往来")
                        .font(.titleSong(40))
                        .foregroundStyle(LWColors.ink)
                    Text("人情有数，往来有度")
                        .font(.bodySong(17))
                        .foregroundStyle(LWColors.warmGold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 18)
            }
        }
        .frame(minHeight: 124, alignment: .top)
    }

    private func deskModeButton(action: @escaping () -> Void) -> some View {
        Button {
            action()
            HapticsManager.lightTap()
        } label: {
            PaperCard(padding: 12) {
                HStack(spacing: 12) {
                    Image("ceremony_table_badge")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 42, height: 42)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("礼台模式")
                            .font(.titleSong(17))
                            .foregroundStyle(LWColors.ink)
                        Text("横屏连续收礼，适合现场快速登记")
                            .font(.bodySong(12))
                            .foregroundStyle(LWColors.muted)
                    }

                    Spacer()

                    if !purchases.isProUnlocked {
                        Text("PRO")
                            .font(.system(size: 9, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(LWColors.cinnabar, in: Capsule())
                    }
                    Text("进入")
                        .font(.bodySong(12).weight(.semibold))
                        .foregroundStyle(LWColors.cinnabar)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(LWColors.cinnabar)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("home.deskMode")
    }

    private var reminderCard: some View {
        NavigationLink {
            ReminderListView(records: records)
        } label: {
            PaperCard(padding: 12) {
                HStack {
                    Image("lwl_gift_red")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                    Text("心意提醒")
                        .font(.titleSong(16))
                        .foregroundStyle(LWColors.ink)
                    Spacer()
                    Text("待处理 \(reminders.count) 项")
                        .font(.titleSong(15))
                        .foregroundStyle(LWColors.cinnabar)
                    Image(systemName: "chevron.right")
                        .foregroundStyle(LWColors.muted)
                }
                GoldLineDivider()
                if let first = reminders.first {
                    Label("回礼 \(returnGiftReminderCount) · 送礼 \(sendGiftReminderCount)", systemImage: "checklist")
                        .font(.bodySong(12))
                        .foregroundStyle(LWColors.inkSoft)
                    Label(first.subtitle, systemImage: first.kind == .returnGift ? "arrow.uturn.right" : "gift")
                        .font(.bodySong(13))
                        .foregroundStyle(LWColors.cinnabar)
                } else {
                    Text("礼尚往来，心意常在。暂时没有需要处理的提醒。")
                        .font(.bodySong(13))
                        .foregroundStyle(LWColors.muted)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var yearlyCard: some View {
        PaperCard(padding: 14) {
            HStack(spacing: 6) {
                yearlyHeaderIcon
                Text("\(String(Calendar.current.component(.year, from: .now))) 年人情往来")
                    .font(.titleSong(17))
                    .foregroundStyle(LWColors.ink)
                Spacer()
                Image("prototype_gold_clouds")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40)
                    .opacity(0.6)
            }

            HStack(spacing: 0) {
                statItem(seal: "收", title: "今年收礼", value: totalReceivedFen.fenCurrencyText, color: LWColors.cinnabar)
                statDivider
                statItem(seal: "送", title: "今年送礼", value: totalGivenFen.fenCurrencyText, color: LWColors.warmGold)
                statDivider
                statItem(icon: .document, title: "今年待回礼", value: "\(currentYearRecords.filter(\.needsReturn).count) 笔", color: LWColors.muted)
                statDivider
                statItem(icon: .trendUp, title: "今年净额", value: (totalReceivedFen - totalGivenFen).fenCurrencyText, color: LWColors.cinnabar)
            }
            GoldLineDivider()
            HStack(spacing: 6) {
                Image(systemName: "calendar.badge.clock")
                    .foregroundStyle(LWColors.warmGold)
                Text("去年净额 \(lastYearNetFen.fenCurrencyText)")
                Spacer()
                let delta = totalReceivedFen - totalGivenFen - lastYearNetFen
                Text("同比 \(delta >= 0 ? "+" : "")\(delta.fenCurrencyText)")
                    .foregroundStyle(delta >= 0 ? LWColors.cinnabar : LWColors.jade)
            }
            .font(.bodySong(11))
            .foregroundStyle(LWColors.inkSoft)
        }
    }

    private var yearlyHeaderIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(LWColors.cinnabar)
            VStack(spacing: 2) {
                ForEach(0..<3) { _ in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(.white.opacity(0.8))
                        .frame(width: 12, height: 2)
                }
            }
        }
        .frame(width: 22, height: 22)
    }

    private enum StatIcon {
        case seal(String)
        case document
        case trendUp
    }

    private func statItem(seal: String? = nil, icon: StatIcon? = nil, title: String, value: String, color: Color) -> some View {
        VStack(spacing: 5) {
            if let seal {
                statSeal(seal: seal, color: color)
            } else if let icon {
                statIconView(icon: icon, color: color)
            }
            Text(title)
                .font(.bodySong(11))
                .foregroundStyle(LWColors.muted)
            Text(value)
                .font(.amountKai(15))
                .foregroundStyle(LWColors.ink)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func statIconView(icon: StatIcon, color: Color) -> some View {
        switch icon {
        case .document:
            documentIcon
        case .trendUp:
            trendUpIcon
        case .seal(let text):
            SealStamp(text: text, size: 24, color: color)
        }
    }

    private var documentIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .stroke(LWColors.muted, lineWidth: 1.5)
            VStack(spacing: 2.5) {
                ForEach(0..<3) { _ in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(LWColors.muted)
                        .frame(width: 10, height: 1.5)
                }
            }
        }
        .frame(width: 22, height: 22)
    }

    private var trendUpIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .stroke(LWColors.cinnabar, lineWidth: 1.5)
            Path { path in
                path.move(to: CGPoint(x: 5, y: 16))
                path.addLine(to: CGPoint(x: 10, y: 10))
                path.addLine(to: CGPoint(x: 14, y: 13))
                path.addLine(to: CGPoint(x: 18, y: 6))
            }
            .stroke(LWColors.cinnabar, style: StrokeStyle(lineWidth: 1.8, lineCap: .round, lineJoin: .round))
            Path { path in
                path.move(to: CGPoint(x: 14, y: 6))
                path.addLine(to: CGPoint(x: 18, y: 6))
                path.addLine(to: CGPoint(x: 18, y: 10))
            }
            .stroke(LWColors.cinnabar, style: StrokeStyle(lineWidth: 1.8, lineCap: .round, lineJoin: .round))
        }
        .frame(width: 22, height: 22)
    }

    @ViewBuilder
    private func statSeal(seal: String, color: Color) -> some View {
        if seal == "收" {
            Image("lwl_badge_receive")
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
        } else {
            Image("lwl_badge_give")
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
        }
    }

    private var statDivider: some View {
        Rectangle()
            .fill(LWColors.cardStroke.opacity(0.35))
            .frame(width: 0.8, height: 36)
    }

    private var recentCard: some View {
        PaperCard(padding: 12) {
            HStack {
                Text("最近入簿")
                    .font(.titleSong(16))
                    .foregroundStyle(LWColors.ink)
                Spacer()
                Button("全部") {
                    appState.selectedTab = .ledger
                }
                .font(.bodySong(12))
                .foregroundStyle(LWColors.muted)
            }

            if records.isEmpty {
                Text("还没有往来记录，先记下一笔吧。")
                    .font(.bodySong(13))
                    .foregroundStyle(LWColors.muted)
            } else {
                ForEach(records.prefix(3)) { record in
                    NavigationLink {
                        RecordDetailView(record: record)
                    } label: {
                        compactRecentRow(record)
                    }
                    .buttonStyle(.plain)
                    if record.id != records.prefix(3).last?.id {
                        GoldLineDivider()
                    }
                }
            }
        }
    }

    private func compactRecentRow(_ record: GiftRecord) -> some View {
        HStack(spacing: 8) {
            recentBadge(for: record)
            VStack(alignment: .leading, spacing: 3) {
                Text("\(record.personName) · \(record.eventType.title)")
                    .font(.bodyKai(16))
                    .foregroundStyle(LWColors.ink)
                    .lineLimit(1)
                Text(record.date.lwDualDateText)
                    .font(.bodySong(11))
                    .foregroundStyle(LWColors.muted)
                    .lineLimit(1)
            }
            Spacer(minLength: 8)
            Text(record.amountFenValue.fenCurrencyText)
                .font(.amountKai(13))
                .foregroundStyle(record.type == .received ? LWColors.cinnabar : LWColors.ink)
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(LWColors.muted.opacity(0.62))
        }
        .frame(minHeight: 36)
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private func recentBadge(for record: GiftRecord) -> some View {
        if record.type == .received {
            Image("lwl_badge_receive")
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
        } else {
            Image("lwl_badge_give")
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
        }
    }

    private var quickActions: some View {
            VStack(alignment: .leading, spacing: 9) {
            Text("快捷操作")
                .font(.titleSong(15))
                .foregroundStyle(LWColors.ink)
            HStack(spacing: 10) {
                quickAction("收礼", systemImage: "gift", tab: .add, presetType: .received)
                quickAction("送礼", systemImage: "gift", tab: .add, presetType: .given)
                hostedEventAction
                quickAction("查旧账", systemImage: "magnifyingglass", tab: .people)
            }
        }
    }

    private var hostedEventAction: some View {
        NavigationLink {
            HostedEventsView()
        } label: {
            VStack(spacing: 4) {
                SealStamp(text: "事", size: 22, color: LWColors.cinnabar)
                Text("一场事")
                    .font(.bodySong(12))
                    .foregroundStyle(LWColors.ink)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(LWColors.card.opacity(0.84))
                    .overlay(alignment: .topTrailing) {
                        Image("prototype_gold_clouds")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32)
                            .padding(.top, 5)
                            .padding(.trailing, 6)
                            .opacity(0.7)
                    }
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(LWColors.cardStroke.opacity(0.35)))
            )
        }
        .buttonStyle(.plain)
    }

    private func quickAction(_ title: String, systemImage: String, tab: AppTab, presetType: GiftRecordType? = nil) -> some View {
        Button {
            if let presetType {
                appState.addPresetType = presetType
            }
            appState.selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                quickActionIcon(title: title, systemImage: systemImage)
                Text(title)
                    .font(.bodySong(12))
                    .foregroundStyle(LWColors.ink)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(LWColors.card.opacity(0.84))
                    .overlay(alignment: .topTrailing) {
                        Image("prototype_gold_clouds")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32)
                            .padding(.top, 5)
                            .padding(.trailing, 6)
                            .opacity(0.7)
                    }
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(LWColors.cardStroke.opacity(0.35)))
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func quickActionIcon(title: String, systemImage: String) -> some View {
        if title == "收礼" {
            Image("lwl_gift_red")
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)
        } else if title == "送礼" {
            Image(systemName: systemImage)
                .font(.system(size: 18))
                .foregroundStyle(LWColors.warmGold)
        } else {
            Image(systemName: systemImage)
                .font(.system(size: 18))
                .foregroundStyle(LWColors.warmGold)
        }
    }

    private var searchResults: some View {
        PaperCard(padding: 16) {
            Text("查旧账")
                .font(.titleSong(16))
                .foregroundStyle(LWColors.ink)
            if filteredRecords.isEmpty {
                VStack(spacing: 8) {
                    Text("没有找到相关往来")
                        .font(.titleSong(15))
                        .foregroundStyle(LWColors.ink)
                    Text("换个姓名、事件或备注关键词试试。")
                        .font(.bodySong(12))
                        .foregroundStyle(LWColors.muted)
                    Button {
                        appState.homeSearchText = ""
                    } label: {
                        Text("清空搜索")
                            .font(.bodySong(12).weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 7)
                            .background(LWColors.cinnabar, in: RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            } else {
                ForEach(filteredRecords.prefix(8)) { record in
                    NavigationLink {
                        RecordDetailView(record: record)
                    } label: {
                        RecordRow(record: record)
                    }
                    .buttonStyle(.plain)
                    if record.id != filteredRecords.prefix(8).last?.id {
                        GoldLineDivider()
                    }
                }
            }
        }
    }

}
