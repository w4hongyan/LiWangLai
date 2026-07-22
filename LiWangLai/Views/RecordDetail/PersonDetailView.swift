import SwiftData
import SwiftUI

struct PersonDetailView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    /// 只保留值类型身份信息，避免视图长期持有包含 SwiftData 对象的聚合快照。
    private let summaryID: String?
    private let initialName: String
    private let initialContact: String
    private let initialPersonID: UUID?
    private let initialRelationship: RelationshipType
    private let initialIdentityHint: String?

    /// 视图自持实时查询：页内删除/新增后列表与统计自动刷新，
    /// 避免重算时访问已删除的快照对象导致崩溃
    @Query(sort: \GiftRecord.date, order: .reverse) private var allRecords: [GiftRecord]

    @State private var editingRecord: GiftRecord?
    @State private var quickAddType: GiftRecordType?
    @State private var pendingDelete: GiftRecord?
    @State private var showDeleteConfirm = false
    @State private var dataErrorMessage: String?

    init(summary: PersonSummary?) {
        summaryID = summary?.id
        initialName = summary?.name ?? ""
        initialContact = summary?.primaryContact ?? ""
        initialPersonID = summary?.personID
        initialRelationship = summary?.relationship ?? .other
        initialIdentityHint = summary?.identityHint
    }

    /// 基于实时记录重建人物聚合，过滤口径与 RecordService.people 的 PersonIdentity 分组一致
    private var liveSummary: PersonSummary? {
        guard let summaryID else { return nil }
        if let regenerated = RecordService.people(from: allRecords).first(where: { $0.id == summaryID }) {
            return regenerated
        }
        // 分组身份发生变化（如补录联系方式后重新拆分/合并）时，按同一套 PersonIdentity 语义兜底
        let fallbackRecords = allRecords.filter {
            PersonIdentity.matches($0, name: initialName, contact: initialContact)
        }
        guard !fallbackRecords.isEmpty else { return nil }
        let latest = fallbackRecords.sorted { $0.date > $1.date }.first
        return PersonSummary(
            id: summaryID,
            name: latest?.personName ?? initialName,
            relationship: latest?.relationship ?? initialRelationship,
            records: fallbackRecords,
            identityHint: initialIdentityHint
        )
    }

    private var records: [GiftRecord] {
        liveSummary?.records.sorted { $0.date > $1.date } ?? []
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                detailHeader

                if let liveSummary {
                    overviewCard(liveSummary)
                    suggestionCard(liveSummary)
                    timelineCard(liveSummary)
                    quickButtons(liveSummary)
                } else {
                    EmptyStateView(title: "没有找到这位往来人", message: "记录可能已被删除，回到礼簿看看其他往来。")
                }
            }
            .padding(.horizontal, LWSpacing.page)
            .padding(.top, 10)
            .padding(.bottom, 18)
        }
        .background(PaperTexture())
        .navigationTitle("往来详情")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $editingRecord) { record in
            NavigationStack {
                AddRecordView(editingRecord: record)
            }
        }
        .sheet(item: $quickAddType) { type in
            NavigationStack {
                AddRecordView(
                    presetName: liveSummary?.name ?? initialName,
                    presetContact: liveSummary?.primaryContact ?? initialContact,
                    presetPersonID: liveSummary?.personID ?? initialPersonID,
                    presetType: type
                )
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
                    Text(liveSummary?.name ?? (initialName.isEmpty ? "往来详情" : initialName))
                        .font(.titleSong(40))
                        .foregroundStyle(LWColors.ink)
                    Text(detailSubtitle)
                        .font(.bodySong(17))
                        .foregroundStyle(LWColors.warmGold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 18)
            }
        }
        .frame(minHeight: 124, alignment: .top)
    }

    private var detailSubtitle: String {
        let relationship = liveSummary?.relationship.title ?? initialRelationship.title
        let hint = (liveSummary?.identityHint ?? initialIdentityHint).map { " · \($0)" } ?? ""
        return "\(relationship)\(hint) · 往来 \(records.count) 次"
    }

    private func overviewCard(_ summary: PersonSummary) -> some View {
        PaperCard(padding: 14, spacing: 10) {
            overviewRow(icon: "gift", title: "我送出：", value: summary.totalGivenFen.fenCurrencyText, color: LWColors.cinnabar)
            GoldLineDivider()
            overviewRow(icon: "tray.and.arrow.down", title: "我收到：", value: summary.totalReceivedFen.fenCurrencyText, color: LWColors.cinnabar)
            GoldLineDivider()
            overviewRow(icon: "clock", title: "最近一次：", value: "\(summary.latestRecord?.date.lwDayText ?? "-") \(summary.latestRecord?.eventType.title ?? "")", color: LWColors.ink)
            GoldLineDivider()
            overviewRow(icon: "checkmark.circle", title: "状态：", value: summary.statusText, color: summary.pendingReturnCount > 0 ? LWColors.cinnabar : LWColors.warmGold)
        }
    }

    private func overviewRow(icon: String, title: String, value: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(LWColors.warmGold)
                .frame(width: 20)
            Text(title)
                .font(.titleSong(14))
                .foregroundStyle(LWColors.ink)
            Text(value)
                .font(.amountKai(14))
                .foregroundStyle(color)
            Spacer()
        }
    }

    private func suggestionCard(_ summary: PersonSummary) -> some View {
        let lastReceived = records.first { $0.type == .received }
        let lastGiven = records.first { $0.type == .given }
        let baseFen = lastReceived?.amountFenValue ?? lastGiven?.amountFenValue ?? 600 * 100

        return PaperCard(padding: 14, spacing: 10) {
            HStack {
                Image(systemName: "gift")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(LWColors.warmGold)
                Text("回礼参考")
                    .font(.titleSong(16))
                    .foregroundStyle(LWColors.ink)
                Spacer()
                Image("prototype_gold_clouds")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50)
                    .opacity(0.6)
            }
            adviceRow("上次他家给你：", value: lastReceived?.amountFenValue.fenCurrencyText ?? "暂无")
            adviceRow("你上次给他：", value: lastGiven?.amountFenValue.fenCurrencyText ?? "暂无")
            adviceRow("按上次金额参考：", value: "\(max(100 * 100, baseFen - 100 * 100).fenCurrencyText) - \((baseFen + 200 * 100).fenCurrencyText)")
            GoldLineDivider()
            HStack {
                Image(systemName: "star.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(LWColors.warmGold)
                Text("参考：可从 \(baseFen.fenCurrencyText) 左右考虑")
                    .font(.titleSong(15))
                    .foregroundStyle(LWColors.cinnabar)
            }
        }
    }

    private func adviceRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.bodySong(13))
                .foregroundStyle(LWColors.inkSoft)
            Spacer()
            Text(value)
                .font(.bodySong(13))
                .foregroundStyle(LWColors.ink)
        }
    }

    private func timelineCard(_ summary: PersonSummary) -> some View {
        PaperCard(padding: 14, spacing: 10) {
            Text("往来记录")
                .font(.titleSong(16))
                .foregroundStyle(LWColors.ink)

            ForEach(Array(records.enumerated()), id: \.element.id) { index, record in
                HStack(alignment: .top, spacing: 10) {
                    VStack(spacing: 0) {
                        Circle()
                            .fill(record.type.accentColor)
                            .frame(width: 9, height: 9)
                        Rectangle()
                            .fill(index == records.count - 1 ? Color.clear : LWColors.goldPale.opacity(0.5))
                            .frame(width: 1, height: 44)
                    }
                    SealStamp(text: record.type.shortTitle, size: 32, color: record.type.accentColor)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(record.date.lwDayText)
                            .font(.bodySong(11))
                            .foregroundStyle(LWColors.muted)
                        Text(record.type == .given ? "他家\(record.eventType.title)，我送礼" : "我家\(record.eventType.title)，他送礼")
                            .font(.bodyKai(14))
                            .foregroundStyle(LWColors.ink)
                        if !record.note.isEmpty {
                            Text(record.note)
                                .font(.bodySong(11))
                                .foregroundStyle(LWColors.muted)
                        }
                    }
                    Spacer()
                    Text(record.amountFenValue.fenCurrencyText)
                        .font(.amountKai(13))
                        .foregroundStyle(record.type == .received ? LWColors.cinnabar : LWColors.ink)
                    Menu {
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
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundStyle(LWColors.muted)
                    }
                }
            }
        }
    }

    private func quickButtons(_ summary: PersonSummary) -> some View {
        HStack(spacing: 12) {
            Button {
                quickAddType = .given
            } label: {
                Label("给他家送礼", systemImage: "gift")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(DetailActionStyle(color: LWColors.cinnabar))

            Button {
                quickAddType = .received
            } label: {
                Label("收到他家礼", systemImage: "tray.and.arrow.down")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(DetailActionStyle(color: LWColors.warmGold))
        }
        .font(.bodySong(14).weight(.semibold))
    }
}

private struct DetailActionStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .padding(.vertical, 10)
            .background(color, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .opacity(configuration.isPressed ? 0.82 : 1)
    }
}
