import SwiftData
import SwiftUI

struct ReminderListView: View {
    @Environment(\.modelContext) private var modelContext
    let records: [GiftRecord]
    @State private var filter: ReminderFilter = .all

    private var reminders: [ReminderItem] {
        ReminderService.reminders(from: records).filter { item in
            switch filter {
            case .all: true
            case .returnGift: item.record.needsReturn
            case .date: item.isDateReminder
            case .custom: !item.record.needsReturn && !item.isDateReminder
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Spacer()
                    Text("回礼提醒")
                        .font(.titleSong(24))
                        .foregroundStyle(LWColors.ink)
                    Spacer()
                }
                MountainDecoration()
                    .frame(height: 68)
                PaperCard {
                    HStack {
                        SealStamp(text: "礼", size: 64)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("待处理")
                                .font(.bodySong(18))
                                .foregroundStyle(LWColors.inkSoft)
                            Text("\(reminders.count) 项")
                                .font(.system(size: 42, weight: .medium, design: .serif))
                                .foregroundStyle(LWColors.cinnabar)
                        }
                        Spacer()
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 52))
                            .foregroundStyle(LWColors.goldPale.opacity(0.65))
                    }
                }
                filterChips

                if reminders.isEmpty {
                    EmptyStateView(title: "暂无提醒", message: "礼尚往来，心意常在。")
                } else {
                    ForEach(reminders) { item in
                        PaperCard {
                            HStack(spacing: 16) {
                                SealStamp(text: item.record.type == .received ? "礼" : "记", size: 58, color: item.record.needsReturn ? LWColors.cinnabar : LWColors.warmGold)
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(item.title)
                                        .font(.titleSong(22))
                                        .foregroundStyle(LWColors.ink)
                                    Label(item.subtitle, systemImage: item.isDateReminder ? "calendar" : "clock")
                                        .font(.bodySong(15))
                                        .foregroundStyle(LWColors.muted)
                                }
                                Spacer()
                                NavigationLink {
                                    RecordDetailView(record: item.record)
                                } label: {
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(LWColors.muted)
                                }
                            }
                            GoldLineDivider()
                            HStack {
                                Button {
                                    RecordService.markReturned(item.record, in: modelContext)
                                } label: {
                                    Label("标记已处理", systemImage: "checkmark.circle")
                                }
                                Spacer()
                                NavigationLink {
                                    AddRecordView(presetName: item.record.personName, presetType: .given)
                                } label: {
                                    Label("新增送礼记录", systemImage: "gift")
                                }
                            }
                            .font(.bodySong(16))
                            .foregroundStyle(LWColors.cinnabar)
                        }
                    }
                }

                Text("礼尚往来 · 心意常在")
                    .font(.bodySong(18))
                    .foregroundStyle(LWColors.warmGold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .padding(.horizontal, LWSpacing.page)
            .padding(.top, 24)
        }
        .background(PaperTexture())
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

private enum ReminderFilter: String, CaseIterable, Identifiable {
    case all
    case returnGift
    case date
    case custom

    var id: String { rawValue }
    var title: String {
        switch self {
        case .all: "全部"
        case .returnGift: "待回礼"
        case .date: "日期提醒"
        case .custom: "自定义"
        }
    }
}
