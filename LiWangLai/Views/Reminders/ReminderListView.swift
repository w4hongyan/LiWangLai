import SwiftData
import SwiftUI

struct ReminderListView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    let records: [GiftRecord]
    @State private var filter: ReminderFilter = .all
    @State private var dataErrorMessage: String?

    private var reminders: [ReminderItem] {
        ReminderService.reminders(from: records).filter { item in
            switch filter {
            case .all: true
            case .returnGift: item.record.needsReturn
            case .date: item.isDateReminder
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 11) {
                reminderHeader
                PaperCard(padding: 12) {
                    HStack {
                        Image("lwl_gift_circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 48)
                        VStack(alignment: .leading, spacing: 5) {
                            Text("待处理")
                                .font(.bodySong(14))
                                .foregroundStyle(LWColors.inkSoft)
                            Text("\(reminders.count) 项")
                                .font(.amountKai(28))
                                .foregroundStyle(LWColors.cinnabar)
                        }
                        Spacer()
                        Image("lwl_calendar_clock")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 54)
                    }
                }
                filterChips

                if reminders.isEmpty {
                    EmptyStateView(title: "暂无提醒", message: emptyMessage, buttonTitle: records.isEmpty ? "记一笔" : nil) {
                        appState.addPresetType = .received
                        appState.selectedTab = .add
                    }
                } else {
                    ForEach(reminders) { item in
                        PaperCard(padding: 12) {
                            HStack(spacing: 10) {
                                SealStamp(text: item.record.type == .received ? "礼" : "记", size: 40, color: item.record.needsReturn ? LWColors.cinnabar : LWColors.warmGold)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.title)
                                        .font(.titleSong(14))
                                        .foregroundStyle(LWColors.ink)
                                        .lineLimit(1)
                                    Label(item.subtitle, systemImage: item.isDateReminder ? "calendar" : "clock")
                                        .font(.bodySong(11))
                                        .foregroundStyle(LWColors.muted)
                                        .lineLimit(1)
                                }
                                Spacer()
                                NavigationLink {
                                    RecordDetailView(record: item.record)
                                } label: {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundStyle(LWColors.muted)
                                }
                            }
                            GoldLineDivider()
                            HStack {
                                Button {
                                    markHandled(item.record)
                                } label: {
                                    Label(item.record.type == .received ? "标记已回礼" : "标记已送礼", systemImage: "checkmark.circle")
                                }
                                if item.record.type == .received {
                                    Spacer()
                                    NavigationLink {
                                        AddRecordView(
                                            presetName: item.record.personName,
                                            presetType: .given,
                                            returningRecord: item.record
                                        )
                                    } label: {
                                        Label("新增送礼记录", systemImage: "gift")
                                    }
                                }
                            }
                            .font(.bodySong(12))
                            .foregroundStyle(LWColors.cinnabar)
                        }
                    }
                }

                Image("lwl_bottom_slogan")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 240)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .padding(.horizontal, LWSpacing.page)
            .padding(.top, -4)
            .padding(.bottom, 10)
        }
        .background(PaperTexture())
        .alert("处理失败", isPresented: Binding(
            get: { dataErrorMessage != nil },
            set: { if !$0 { dataErrorMessage = nil } }
        )) {
            Button("知道了", role: .cancel) {}
        } message: {
            Text(dataErrorMessage ?? "请稍后再试。")
        }
    }

    private var emptyMessage: String {
        if records.isEmpty {
            return "先记下一笔收礼或送礼，系统会帮你整理需要处理的往来。"
        }
        switch filter {
        case .all:
            return "当前没有需要处理的提醒。"
        case .returnGift:
            return "没有待回礼记录，心里可以稍微松一口气。"
        case .date:
            return "还没有设置日期提醒。"
        }
    }

    private var reminderHeader: some View {
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
                    Text("心意提醒")
                        .font(.titleSong(40))
                        .foregroundStyle(LWColors.ink)
                    Text("别忘心意往来")
                        .font(.bodySong(17))
                        .foregroundStyle(LWColors.warmGold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 18)
            }
        }
        .frame(height: 124)
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(ReminderFilter.allCases) { option in
                    Button {
                        filter = option
                    } label: {
                        RelationshipTag(title: option.title, isSelected: filter == option)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private extension ReminderListView {
    func markHandled(_ record: GiftRecord) {
        do {
            try RecordService.completeReminder(record, in: modelContext)
            HapticsManager.success()
        } catch {
            dataErrorMessage = error.localizedDescription
        }
    }
}

private enum ReminderFilter: String, CaseIterable, Identifiable {
    case all
    case returnGift
    case date

    var id: String { rawValue }
    var title: String {
        switch self {
        case .all: "全部"
        case .returnGift: "待回礼"
        case .date: "日期提醒"
        }
    }
}
