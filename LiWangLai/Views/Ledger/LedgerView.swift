import SwiftData
import SwiftUI

struct LedgerView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \HostedGiftEvent.date, order: .reverse) private var hostedEvents: [HostedGiftEvent]

    let records: [GiftRecord]
    @State private var typeFilter: LedgerTypeFilter = .all
    @State private var timeFilter: LedgerTimeFilter = .thisYear
    @State private var customStartDate = Calendar.current.date(byAdding: .month, value: -1, to: .now) ?? .now
    @State private var customEndDate = Date.now
    @State private var showCustomDatePicker = false
    @State private var editingRecord: GiftRecord?
    @State private var pendingDelete: GiftRecord?
    @State private var showDeleteConfirm = false
    @State private var dataErrorMessage: String?

    private var filteredRecords: [GiftRecord] {
        SearchService.filter(records, query: appState.ledgerSearchText)
            .filter { record in
                switch typeFilter {
                case .all: return true
                case .received: return record.type == .received
                case .given: return record.type == .given
                }
            }
            .filter { record in
                switch timeFilter {
                case .thisYear:
                    return Calendar.current.component(.year, from: record.date) == Calendar.current.component(.year, from: .now)
                case .lastYear:
                    return Calendar.current.component(.year, from: record.date) == Calendar.current.component(.year, from: .now) - 1
                case .all:
                    return true
                case .custom:
                    return RecordDateRange.contains(
                        record.date,
                        start: customStartDate,
                        end: customEndDate
                    )
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
            VStack(alignment: .leading, spacing: 11) {
                ledgerHeader
                SearchField(placeholder: "搜索姓名 / 事件 / 备注", text: $appState.ledgerSearchText, fontSize: 14, iconSize: 18, verticalPadding: 9)
                typeFilters
                timeFilters

                if filteredRecords.isEmpty {
                    if records.isEmpty {
                        EmptyStateView(title: "还没有入簿", message: "第一笔人情往来，记下来才安心。", buttonTitle: "记一笔") {
                            appState.addPresetType = .received
                            appState.selectedTab = .add
                        }
                    } else {
                        EmptyStateView(title: "没有符合条件的记录", message: "换个关键词，或清空筛选后再看看。", buttonTitle: "清空筛选") {
                            appState.ledgerSearchText = ""
                            typeFilter = .all
                            timeFilter = .all
                        }
                    }
                } else {
                    ForEach(groupedRecords, id: \.0) { month, records in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(month)
                                    .font(.titleSong(16))
                                    .foregroundStyle(LWColors.ink)
                                Spacer()
                                MountainDecoration()
                                    .frame(width: 56, height: 18)
                                    .opacity(0.72)
                            }
                            eventStrip(for: records)
                            PaperCard(padding: 11) {
                                ForEach(records) { record in
                                    NavigationLink {
                                        RecordDetailView(record: record)
                                    } label: {
                                        RecordRow(record: record, showsReturnStatus: false)
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
            .padding(.top, -4)
            .padding(.bottom, 10)
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
                    do {
                        try RecordService.delete(pendingDelete, in: modelContext)
                    } catch {
                        dataErrorMessage = error.localizedDescription
                    }
                }
                pendingDelete = nil
            }
            Button("取消", role: .cancel) {
                pendingDelete = nil
            }
        } message: {
            Text("删除后将无法在礼簿和人情详情中查看这笔记录。")
        }
        .alert("操作失败", isPresented: Binding(
            get: { dataErrorMessage != nil },
            set: { if !$0 { dataErrorMessage = nil } }
        )) {
            Button("知道了", role: .cancel) {}
        } message: {
            Text(dataErrorMessage ?? "请稍后再试。")
        }
    }

    private var ledgerHeader: some View {
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
                    Text("礼簿")
                        .font(.titleSong(40))
                        .foregroundStyle(LWColors.ink)
                    Text("人情有数，往来有度")
                        .font(.bodySong(17))
                        .foregroundStyle(LWColors.warmGold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 18)

                exportButton
                    .padding(.top, 20)
            }
        }
        .frame(height: 124)
    }

    private var exportButton: some View {
        Button {
            appState.selectedTab = .settings
        } label: {
            Label("导出", systemImage: "square.and.arrow.up")
                .font(.bodySong(12))
                .foregroundStyle(LWColors.ink)
                .padding(.horizontal, 11)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.56))
                        .overlay(Capsule().stroke(LWColors.cardStroke.opacity(0.35)))
                )
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
                        ledgerFilterTag(filter.title, isSelected: typeFilter == filter)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var timeFilters: some View {
        HStack(spacing: 8) {
            ForEach(LedgerTimeFilter.allCases) { filter in
                Button {
                    if filter == .custom {
                        showCustomDatePicker = true
                    } else {
                        timeFilter = filter
                    }
                } label: {
                    Text(filter.title)
                        .font(.bodySong(12))
                        .foregroundStyle(timeFilter == filter ? LWColors.cinnabar : LWColors.ink)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.56))
                                .overlay(Capsule().stroke(timeFilter == filter ? LWColors.cinnabar : LWColors.cardStroke.opacity(0.35)))
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .sheet(isPresented: $showCustomDatePicker) {
            NavigationStack {
                VStack(spacing: 16) {
                    DatePicker("开始日期", selection: Binding(
                        get: { customStartDate },
                        set: { customStartDate = $0 }
                    ), displayedComponents: .date)
                    .datePickerStyle(.graphical)

                    DatePicker("结束日期", selection: Binding(
                        get: { customEndDate },
                        set: { customEndDate = $0 }
                    ), displayedComponents: .date)
                    .datePickerStyle(.graphical)
                }
                .padding()
                .navigationTitle("自定义时间范围")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("取消") {
                            showCustomDatePicker = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("确定") {
                            if customStartDate > customEndDate {
                                swap(&customStartDate, &customEndDate)
                            }
                            timeFilter = .custom
                            showCustomDatePicker = false
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }

    private func ledgerFilterTag(_ title: String, isSelected: Bool) -> some View {
        Text(title)
            .font(.bodySong(14))
            .foregroundStyle(isSelected ? .white : LWColors.ink)
            .padding(.horizontal, 18)
            .padding(.vertical, 9)
            .background(
                Capsule()
                    .fill(isSelected ? LWColors.cinnabar : LWColors.card.opacity(0.84))
                    .overlay(Capsule().stroke(isSelected ? LWColors.cinnabarDark.opacity(0.2) : LWColors.cardStroke.opacity(0.5), lineWidth: 0.8))
                    .shadow(color: isSelected ? LWColors.cinnabar.opacity(0.18) : .clear, radius: 8, x: 0, y: 4)
            )
    }

    private func events(for records: [GiftRecord]) -> [GiftEvent] {
        HostedEventService.giftEvents(from: hostedEvents, records: records)
    }

    @ViewBuilder
    private func eventStrip(for records: [GiftRecord]) -> some View {
        let events = events(for: records)
        if !events.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(events) { event in
                        NavigationLink {
                            EventDetailView(event: event)
                        } label: {
                            eventCard(event)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func eventCard(_ event: GiftEvent) -> some View {
        HStack(spacing: 8) {
            SealStamp(text: "事", size: 28, color: LWColors.cinnabar)
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.titleSong(13))
                    .foregroundStyle(LWColors.ink)
                Text("我家 · \(event.records.count) 笔 · \(event.totalAmount.yuanText)")
                    .font(.bodySong(10))
                    .foregroundStyle(LWColors.muted)
            }
            Image(systemName: "chevron.right")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(LWColors.muted.opacity(0.72))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(LWColors.card.opacity(0.86))
                .overlay(alignment: .topTrailing) {
                    Image("prototype_gold_clouds")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28)
                        .padding(.top, 5)
                        .padding(.trailing, 6)
                        .opacity(0.58)
                }
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(LWColors.cardStroke.opacity(0.36)))
        )
    }
}

private enum LedgerTypeFilter: String, CaseIterable, Identifiable {
    case all
    case received
    case given

    var id: String { rawValue }
    var title: String {
        switch self {
        case .all: "全部"
        case .received: "收礼"
        case .given: "送礼"
        }
    }
}

private enum LedgerTimeFilter: String, CaseIterable, Identifiable {
    case thisYear
    case lastYear
    case all
    case custom

    var id: String { rawValue }
    var title: String {
        switch self {
        case .thisYear: "今年"
        case .lastYear: "去年"
        case .all: "全部"
        case .custom: "自定义"
        }
    }
}
