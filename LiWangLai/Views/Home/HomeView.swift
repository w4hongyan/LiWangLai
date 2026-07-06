import SwiftUI

struct HomeView: View {
    @Environment(AppState.self) private var appState
    let records: [GiftRecord]

    private var filteredRecords: [GiftRecord] {
        SearchService.filter(records, query: appState.homeSearchText)
    }

    private var reminders: [ReminderItem] {
        ReminderService.reminders(from: records)
    }

    private var currentYearRecords: [GiftRecord] {
        records.filter { Calendar.current.component(.year, from: $0.date) == Calendar.current.component(.year, from: .now) }
    }

    private var totalReceived: Int {
        currentYearRecords.filter { $0.type == .received }.reduce(0) { $0 + $1.amountYuan }
    }

    private var totalGiven: Int {
        currentYearRecords.filter { $0.type == .given }.reduce(0) { $0 + $1.amountYuan }
    }

    var body: some View {
        @Bindable var appState = appState

        ScrollView {
            VStack(alignment: .leading, spacing: 9) {
                homeHero

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
        .navigationDestination(for: String.self) { name in
            PersonDetailView(summary: RecordService.people(from: records).first { $0.name == name })
        }
    }

    private var homeHero: some View {
        ZStack(alignment: .topTrailing) {
            MountainDecoration()
                .frame(width: 180, height: 88)
                .offset(x: 20, y: 0)
                .opacity(0.98)

            VStack(alignment: .leading, spacing: 6) {
                Text("礼往来")
                    .font(.titleSong(30))
                    .foregroundStyle(LWColors.ink)
                    .fixedSize()
                Text("人情有数，往来有度")
                    .font(.bodySong(13))
                    .foregroundStyle(LWColors.warmGold)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 10)
        }
        .frame(height: 94)
    }

    private var reminderCard: some View {
        NavigationLink {
            ReminderListView(records: records)
        } label: {
            PaperCard(padding: 12) {
                HStack {
                    Circle()
                        .fill(LWColors.cinnabar)
                        .frame(width: 32, height: 32)
                        .overlay {
                            Image("lwl_gift_red")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                        }
                    Text("回礼提醒")
                        .font(.titleSong(16))
                        .foregroundStyle(LWColors.ink)
                    Spacer()
                    Text("待回礼 \(reminders.count) 人")
                        .font(.titleSong(15))
                        .foregroundStyle(LWColors.cinnabar)
                    Image(systemName: "chevron.right")
                        .foregroundStyle(LWColors.muted)
                }
                GoldLineDivider()
                if let first = reminders.first {
                    Label("最近一件： \(first.record.personName) · \(first.record.eventType.title) · \(first.record.date.lwDayText)", systemImage: "clock")
                        .font(.bodySong(12))
                        .foregroundStyle(LWColors.inkSoft)
                    Label("建议回礼： \(suggestionRange(for: first.record))", systemImage: "tag")
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
            PaperCard(padding: 12) {
                HStack {
                    Label("\(String(Calendar.current.component(.year, from: .now))) 年人情往来", systemImage: "scroll")
                        .font(.titleSong(16))
                        .foregroundStyle(LWColors.ink)
                    Spacer()
                    Image("lwl_cloud_card_top")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 48, height: 22)
            }

                HStack(spacing: 0) {
                    statItem(seal: "收", title: "收礼", value: totalReceived.yuanText, color: LWColors.cinnabar)
                    statDivider
                    statItem(seal: "送", title: "送礼", value: totalGiven.yuanText, color: LWColors.warmGold)
                    statDivider
                    statItem(seal: "未", title: "未回礼", value: "\(records.filter(\.needsReturn).count) 笔", color: LWColors.muted)
                    statDivider
                    statItem(seal: "净", title: "净额", value: (totalReceived - totalGiven).yuanText, color: LWColors.cinnabar)
                }
        }
    }

    private func statItem(seal: String, title: String, value: String, color: Color) -> some View {
        VStack(spacing: 3) {
            statSeal(seal: seal, color: color)
            Text(title)
                .font(.bodySong(11))
                .foregroundStyle(LWColors.ink)
            Text(value)
                .font(.system(size: 13, weight: .medium, design: .serif))
                .foregroundStyle(color == LWColors.muted ? LWColors.ink : color)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func statSeal(seal: String, color: Color) -> some View {
        if seal == "收" {
            Image("lwl_badge_receive")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
        } else if seal == "送" {
            Image("lwl_badge_give")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
        } else {
            SealStamp(text: seal, size: 26, color: color)
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
                    .font(.titleSong(15))
                    .foregroundStyle(LWColors.ink)
                    .lineLimit(1)
                Text(record.date.lwDayText)
                    .font(.bodySong(11))
                    .foregroundStyle(LWColors.muted)
                    .lineLimit(1)
            }
            Spacer(minLength: 8)
            Text(record.amountYuan.yuanText)
                .font(.system(size: 13, weight: .semibold, design: .serif))
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
            VStack(alignment: .leading, spacing: 7) {
            Text("快捷操作")
                .font(.titleSong(15))
                .foregroundStyle(LWColors.ink)
            HStack(spacing: 9) {
                quickAction("收礼", image: "gift", tab: .add)
                quickAction("送礼", image: "gift", tab: .add)
                quickAction("查旧账", image: "book", tab: .people)
                quickAction("导出", image: "square.and.arrow.up", tab: .settings)
            }
        }
    }

    private func quickAction(_ title: String, image: String, tab: AppTab) -> some View {
        Button {
            appState.selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                quickActionIcon(title: title, systemImage: image)
                Text(title)
                    .font(.bodySong(12))
                    .foregroundStyle(LWColors.ink)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white.opacity(0.52))
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
                Text("没有找到相关往来，换个姓名或事件试试。")
                    .font(.bodySong(13))
                    .foregroundStyle(LWColors.muted)
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

    private func suggestionRange(for record: GiftRecord) -> String {
        let lower = max(100, record.amountYuan / 100 * 100)
        let upper = lower + 200
        return "\(lower.yuanText) - \(upper.yuanText)"
    }
}
