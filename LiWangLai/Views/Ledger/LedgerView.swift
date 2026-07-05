import SwiftData
import SwiftUI

struct LedgerView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext

    let records: [GiftRecord]
    @State private var typeFilter: LedgerTypeFilter = .all
    @State private var timeFilter: LedgerTimeFilter = .thisYear
    @State private var editingRecord: GiftRecord?
    @State private var pendingDelete: GiftRecord?
    @State private var showDeleteConfirm = false

    private var filteredRecords: [GiftRecord] {
        SearchService.filter(records, query: appState.ledgerSearchText)
            .filter { record in
                switch typeFilter {
                case .all: true
                case .received: record.type == .received
                case .given: record.type == .given
                case .notReturned: record.needsReturn
                case .returned: record.isReturned
                }
            }
            .filter { record in
                switch timeFilter {
                case .thisYear:
                    Calendar.current.component(.year, from: record.date) == Calendar.current.component(.year, from: .now)
                case .lastYear:
                    Calendar.current.component(.year, from: record.date) == Calendar.current.component(.year, from: .now) - 1
                case .all:
                    true
                }
            }
    }

    private var groupedRecords: [(String, [GiftRecord])] {
        Dictionary(grouping: filteredRecords) { $0.date.lwMonthText }
            .map { ($0.key, $0.value.sorted { $0.date > $1.date }) }
            .sorted { lhs, rhs in
                (lhs.1.first?.date ?? .distantPast) > (rhs.1.first?.date ?? .distantPast)
            }
    }

    var body: some View {
        @Bindable var appState = appState

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                PageHeader(
                    title: "礼簿",
                    subtitle: "人情有数，往来有度",
                    trailing: AnyView(exportButton)
                )
                SearchField(placeholder: "搜索姓名 / 事件 / 备注", text: $appState.ledgerSearchText)
                typeFilters
                timeFilters

                if filteredRecords.isEmpty {
                    EmptyStateView(title: "还没有入簿", message: "第一笔人情往来，记下来才安心。", buttonTitle: "记一笔") {
                        appState.selectedTab = .add
                    }
                } else {
                    ForEach(groupedRecords, id: \.0) { month, records in
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(month)
                                    .font(.titleSong(24))
                                    .foregroundStyle(LWColors.ink)
                                Spacer()
                                MountainDecoration()
                                    .frame(width: 70, height: 22)
                            }
                            PaperCard {
                                ForEach(records) { record in
                                    NavigationLink {
                                        RecordDetailView(record: record)
                                    } label: {
                                        RecordRow(record: record)
                                    }
                                    .buttonStyle(.plain)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            pendingDelete = record
                                            showDeleteConfirm = true
                                        } label: {
                                            Label("删除", systemImage: "trash")
                                        }
                                        Button {
                                            editingRecord = record
                                        } label: {
                                            Label("编辑", systemImage: "pencil")
                                        }
                                        .tint(LWColors.warmGold)
                                    }
                                    .contextMenu {
                                        Button("编辑") {
                                            editingRecord = record
                                        }
                                        Button("标记已回") {
                                            RecordService.markReturned(record, in: modelContext)
                                        }
                                        Button("删除", role: .destructive) {
                                            pendingDelete = record
                                            showDeleteConfirm = true
                                        }
                                    }
                                    if record.id != records.last?.id {
                                        GoldLineDivider()
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, LWSpacing.page)
            .padding(.top, 28)
        }
        .background(PaperTexture())
        .sheet(item: $editingRecord) { record in
            NavigationStack {
                AddRecordView(editingRecord: record)
            }
        }
        .confirmationDialog("确认删除这条往来记录？", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("删除记录", role: .destructive) {
                if let pendingDelete {
                    RecordService.delete(pendingDelete, in: modelContext)
                }
                pendingDelete = nil
            }
            Button("取消", role: .cancel) {
                pendingDelete = nil
            }
        } message: {
            Text("删除后将无法在礼簿和人情详情中查看这笔记录。")
        }
    }

    private var exportButton: some View {
        Button {
            appState.selectedTab = .settings
        } label: {
            Label("导出", systemImage: "square.and.arrow.up")
                .font(.bodySong(16))
                .foregroundStyle(LWColors.ink)
        }
        .buttonStyle(.plain)
    }

    private var typeFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(LedgerTypeFilter.allCases) { filter in
                    Button {
                        typeFilter = filter
                    } label: {
                        RelationshipTag(title: filter.title, isSelected: typeFilter == filter)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var timeFilters: some View {
        HStack(spacing: 12) {
            ForEach(LedgerTimeFilter.allCases) { filter in
                Button {
                    timeFilter = filter
                } label: {
                    Text(filter.title)
                        .font(.bodySong(17))
                        .foregroundStyle(timeFilter == filter ? LWColors.cinnabar : LWColors.ink)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.56))
                                .overlay(Capsule().stroke(timeFilter == filter ? LWColors.cinnabar : LWColors.cardStroke.opacity(0.35)))
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private enum LedgerTypeFilter: String, CaseIterable, Identifiable {
    case all
    case received
    case given
    case notReturned
    case returned

    var id: String { rawValue }
    var title: String {
        switch self {
        case .all: "全部"
        case .received: "收礼"
        case .given: "送礼"
        case .notReturned: "未回礼"
        case .returned: "已回礼"
        }
    }
}

private enum LedgerTimeFilter: String, CaseIterable, Identifiable {
    case thisYear
    case lastYear
    case all

    var id: String { rawValue }
    var title: String {
        switch self {
        case .thisYear: "今年"
        case .lastYear: "去年"
        case .all: "全部"
        }
    }
}
