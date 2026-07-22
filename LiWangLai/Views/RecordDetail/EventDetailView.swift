import SwiftData
import SwiftUI

struct EventDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState

    let event: GiftEvent
    /// 非场次聚合只保留记录主键，不在 body 重算时读取传入快照中的 SwiftData 对象。
    private let initialRecordIDs: Set<UUID>

    /// 视图自持实时查询：页内删除/新增后列表与统计自动刷新，
    /// 避免重算时访问已删除的快照对象导致崩溃
    @Query(sort: \GiftRecord.date, order: .reverse) private var allRecords: [GiftRecord]

    @State private var editingRecord: GiftRecord?
    @State private var showAddRecord = false
    @State private var pendingDelete: GiftRecord?
    @State private var showDeleteConfirm = false
    @State private var presentedEventSheet: HostedEventSheetDestination?
    @State private var showDeleteEventConfirm = false
    @State private var dataErrorMessage: String?

    init(event: GiftEvent) {
        self.event = event
        initialRecordIDs = Set(event.records.map(\.id))
    }

    private var hostedEvent: HostedGiftEvent? {
        event.hostedEvent
    }

    private var displayTitle: String {
        hostedEvent?.title ?? event.title
    }

    private var displayDate: Date? {
        hostedEvent?.date ?? event.date
    }

    private var displayEventType: GiftEventType? {
        hostedEvent?.eventType ?? event.eventType
    }

    private var displayNote: String {
        hostedEvent?.note ?? ""
    }

    private var records: [GiftRecord] {
        guard let hostedEventID = event.hostedEventID else {
            return allRecords
                .filter { initialRecordIDs.contains($0.id) }
                .sorted { $0.date > $1.date }
        }
        return allRecords
            .filter { $0.type == .received && $0.hostedEventID == hostedEventID }
            .sorted { $0.date > $1.date }
    }

    private var totalReceivedFen: Int {
        records.filter { $0.type == .received }.reduce(0) { $0 + $1.amountFenValue }
    }

    private var pendingReturnCount: Int {
        records.filter(\.needsReturn).count
    }

    /// 这些宾客的历史「我方送礼」合计（排除归属本场的记录）
    private var historicalGivenTotalFen: Int {
        HostedEventService.givenTotalFenForGuests(
            of: records,
            excludingHostedEventID: event.hostedEventID,
            in: allRecords
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                detailHeader
                overviewCard
                if hostedEvent != nil {
                    deskModeButton
                }
                recordsCard
                addRecordButton
            }
            .padding(.horizontal, LWSpacing.page)
            .padding(.top, 10)
            .padding(.bottom, 18)
        }
        .background(PaperTexture())
        .navigationTitle("我家一场事")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let hostedEvent {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            presentedEventSheet = .edit(hostedEvent)
                        } label: {
                            Label("编辑一场事", systemImage: "pencil")
                        }
                        Button(role: .destructive) {
                            showDeleteEventConfirm = true
                        } label: {
                            Label("删除一场事", systemImage: "trash")
                        }
                    } label: {
                        Label("更多操作", systemImage: "ellipsis.circle")
                    }
                    .foregroundStyle(LWColors.cinnabar)
                }
            }
        }
        .sheet(item: $editingRecord) { record in
            NavigationStack {
                AddRecordView(editingRecord: record)
            }
        }
        .sheet(isPresented: $showAddRecord) {
            NavigationStack {
                AddRecordView(
                    presetType: .received,
                    presetEventType: displayEventType,
                    presetDate: displayDate,
                    presetNote: displayTitle,
                    presetEventID: event.hostedEventID
                )
            }
        }
        .sheet(item: $presentedEventSheet) { destination in
            switch destination {
            case .create:
                EmptyView()
            case .edit(let hostedEvent):
                HostedEventEditorSheet(event: hostedEvent, linkedRecords: records)
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
            Text("删除后将无法在这场事和礼簿中查看这笔记录。")
        }
        .confirmationDialog("确认删除这场事？", isPresented: $showDeleteEventConfirm, titleVisibility: .visible) {
            Button("删除一场事", role: .destructive) {
                deleteHostedEvent()
            }
            Button("取消", role: .cancel) {}
        } message: {
            if records.isEmpty {
                Text("这场事目前没有礼簿记录，删除后无法恢复。")
            } else {
                Text("这场事会被删除；其中 \(records.count) 笔礼簿记录会保留，并转为普通收礼记录。")
            }
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

    private var detailHeader: some View {
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
                    Text(displayTitle)
                        .font(.titleSong(40))
                        .foregroundStyle(LWColors.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                    Text("\(displayDate?.lwDualDateText ?? event.monthKey) · \(displayEventType?.title ?? "我家办的事")")
                        .font(.bodySong(17))
                        .foregroundStyle(LWColors.warmGold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 18)
            }
        }
        .frame(minHeight: 124, alignment: .top)
    }

    private var overviewCard: some View {
        PaperCard(padding: 14, spacing: 10) {
            HStack {
                Image(systemName: "scroll")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(LWColors.warmGold)
                Text("收礼总览")
                    .font(.titleSong(16))
                    .foregroundStyle(LWColors.ink)
                Spacer()
                Image("prototype_gold_clouds")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50)
                    .opacity(0.6)
            }
            overviewRow(title: "记录", value: "\(records.count) 笔", color: LWColors.ink)
            GoldLineDivider()
            overviewRow(title: "收礼", value: totalReceivedFen.fenCurrencyText, color: LWColors.cinnabar)
            if !records.isEmpty {
                GoldLineDivider()
                overviewRow(
                    title: "收送对比",
                    value: "本场收 \(records.count) 笔 \(totalReceivedFen.fenCurrencyText) · 历史送出 \(historicalGivenTotalFen.fenCurrencyText)",
                    color: LWColors.ink
                )
            }
            GoldLineDivider()
            overviewRow(title: "未回礼", value: "\(pendingReturnCount) 笔", color: pendingReturnCount > 0 ? LWColors.cinnabar : LWColors.muted)
            if !displayNote.isEmpty {
                GoldLineDivider()
                VStack(alignment: .leading, spacing: 4) {
                    Text("备注")
                        .font(.titleSong(13))
                        .foregroundStyle(LWColors.ink)
                    Text(displayNote)
                        .font(.bodySong(13))
                        .foregroundStyle(LWColors.inkSoft)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    private func overviewRow(title: String, value: String, color: Color) -> some View {
        HStack {
            Text(title)
                .font(.titleSong(14))
                .foregroundStyle(LWColors.ink)
            Spacer()
            Text(value)
                .font(.amountKai(14))
                .foregroundStyle(color)
        }
    }

    private var recordsCard: some View {
        PaperCard(padding: 14, spacing: 10) {
            Text("来随礼的人")
                .font(.titleSong(16))
                .foregroundStyle(LWColors.ink)

            if records.isEmpty {
                Text("还没有收礼记录，从这场事里新增一笔吧。")
                    .font(.bodySong(13))
                    .foregroundStyle(LWColors.muted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 6)
            } else {
                ForEach(records) { record in
                    NavigationLink {
                        RecordDetailView(record: record)
                    } label: {
                        RecordRow(record: record)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button("编辑") {
                            editingRecord = record
                        }
                        if record.needsReturn {
                            Button("标记已回") {
                                do {
                                    try RecordService.markReturned(record, in: modelContext)
                                } catch {
                                    dataErrorMessage = error.localizedDescription
                                }
                            }
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

    private var deskModeButton: some View {
        Button {
            guard let hostedEvent else { return }
            appState.deskRequest = DeskRequest(hostedEventID: hostedEvent.id)
            HapticsManager.lightTap()
        } label: {
            PaperCard(padding: 12) {
                HStack(spacing: 12) {
                    Image("ceremony_table_badge")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("进入礼台模式")
                            .font(.titleSong(16))
                            .foregroundStyle(LWColors.ink)
                        Text("继续为“\(displayTitle)”现场收礼入簿")
                            .font(.bodySong(12))
                            .foregroundStyle(LWColors.muted)
                    }
                    Spacer()
                    Image(systemName: "rectangle.landscape.rotate")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(LWColors.cinnabar)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(LWColors.cinnabar)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("event.deskMode")
    }

    private var addRecordButton: some View {
        SealButton(title: "新增一笔", systemImage: "plus.circle", fontSize: 15, verticalPadding: 11, cornerRadius: 18) {
            showAddRecord = true
        }
    }

    private func deleteHostedEvent() {
        guard let hostedEvent else { return }
        do {
            try HostedEventService.delete(hostedEvent, linkedRecords: records, in: modelContext)
            HapticsManager.success()
            dismiss()
        } catch {
            dataErrorMessage = error.localizedDescription
        }
    }
}
