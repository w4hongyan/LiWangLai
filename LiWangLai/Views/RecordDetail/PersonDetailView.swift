import SwiftData
import SwiftUI

struct PersonDetailView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let summary: PersonSummary?
    @State private var editingRecord: GiftRecord?
    @State private var quickAddType: GiftRecordType?
    @State private var pendingDelete: GiftRecord?
    @State private var showDeleteConfirm = false

    private var records: [GiftRecord] {
        summary?.records.sorted { $0.date > $1.date } ?? []
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                detailHeader

                if let summary {
                    overviewCard(summary)
                    suggestionCard(summary)
                    timelineCard(summary)
                    quickButtons(summary)
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
                AddRecordView(presetName: summary?.name ?? "", presetType: type)
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
        }
    }

    private var detailHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text(summary?.name ?? "往来详情")
                    .font(.titleSong(30))
                    .foregroundStyle(LWColors.ink)
                Text("\(summary?.relationship.title ?? "") · 往来 \(summary?.records.count ?? 0) 次")
                    .font(.bodySong(13))
                    .foregroundStyle(LWColors.warmGold)
            }
            Spacer()
            MountainDecoration()
                .frame(width: 150, height: 64)
        }
    }

    private func overviewCard(_ summary: PersonSummary) -> some View {
        PaperCard(padding: 12, spacing: 8) {
            overviewRow(icon: "gift", title: "我送出：", value: summary.totalGiven.yuanText, color: LWColors.cinnabar)
            GoldLineDivider()
            overviewRow(icon: "tray.and.arrow.down", title: "我收到：", value: summary.totalReceived.yuanText, color: LWColors.cinnabar)
            GoldLineDivider()
            overviewRow(icon: "clock", title: "最近一次：", value: "\(summary.latestRecord?.date.lwCompactMonthText ?? "-") \(summary.latestRecord?.eventType.title ?? "")", color: LWColors.ink)
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
        let base = lastReceived?.amountYuan ?? lastGiven?.amountYuan ?? 600

        return PaperCard(padding: 12, spacing: 8) {
            HStack {
                Label("回礼参考", systemImage: "gift")
                    .font(.titleSong(16))
                    .foregroundStyle(LWColors.ink)
                Spacer()
                MountainDecoration()
                    .frame(width: 58, height: 20)
            }
            adviceRow("上次他家给你：", value: lastReceived?.amountYuan.yuanText ?? "暂无")
            adviceRow("你上次给他：", value: lastGiven?.amountYuan.yuanText ?? "暂无")
            adviceRow("本地常见区间：", value: "\(max(100, base - 100).yuanText) - \((base + 200).yuanText)")
            GoldLineDivider()
            Label("建议： \(base.yuanText) 左右较稳妥", systemImage: "star.fill")
                .font(.titleSong(16))
                .foregroundStyle(LWColors.cinnabar)
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
        PaperCard(padding: 12, spacing: 8) {
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
                    SealStamp(text: record.type.shortTitle, size: 34, color: record.type.accentColor)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(record.date.lwCompactMonthText)
                            .font(.bodySong(11))
                            .foregroundStyle(LWColors.muted)
                        Text(record.type == .given ? "他家\(record.eventType.title)，我送礼" : "我家\(record.eventType.title)，他送礼")
                            .font(.bodyKai(15))
                            .foregroundStyle(LWColors.ink)
                        if !record.note.isEmpty {
                            Text(record.note)
                                .font(.bodySong(11))
                                .foregroundStyle(LWColors.muted)
                        }
                    }
                    Spacer()
                    Text(record.amountYuan.yuanText)
                        .font(.amountKai(14))
                        .foregroundStyle(record.type == .received ? LWColors.cinnabar : LWColors.ink)
                    Menu {
                        Button("编辑") {
                            editingRecord = record
                        }
                        if record.needsReturn {
                            Button("标记已回") {
                                RecordService.markReturned(record, in: modelContext)
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
