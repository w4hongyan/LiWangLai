import SwiftData
import SwiftUI

struct DuplicateMergeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var groups: [DuplicateMergeService.DuplicateGroup]
    @State private var resultMessage: String?
    @State private var errorMessage: String?

    init(records: [GiftRecord]) {
        _groups = State(initialValue: DuplicateMergeService.groups(in: records))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    introCard
                    if groups.isEmpty {
                        EmptyStateView(
                            title: resultMessage == nil ? "没有明确重复项" : "整理完成",
                            message: resultMessage ?? "姓名、日期、事件、收送方向和金额均相同的记录才会被列为重复。"
                        )
                    } else {
                        ForEach(groups) { group in
                            PaperCard(padding: 12, spacing: 6) {
                                HStack {
                                    SealStamp(text: "重", size: 36, color: LWColors.cinnabar)
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(group.displayName)
                                            .font(.titleSong(15))
                                            .foregroundStyle(LWColors.ink)
                                        Text(group.summary)
                                            .font(.bodySong(11))
                                            .foregroundStyle(LWColors.muted)
                                            .lineLimit(2)
                                    }
                                    Spacer()
                                    Text("\(group.records.count) 笔")
                                        .font(.bodySong(12).weight(.semibold))
                                        .foregroundStyle(LWColors.cinnabar)
                                }
                                Text("合并时保留信息较完整的一笔，并补全备注、地点、礼品和联系方式。")
                                    .font(.bodySong(10))
                                    .foregroundStyle(LWColors.muted)
                            }
                        }

                        SealButton(
                            title: "合并 \(groups.reduce(0) { $0 + $1.duplicateCount }) 笔重复记录",
                            systemImage: "arrow.triangle.merge",
                            fontSize: 14,
                            verticalPadding: 10,
                            cornerRadius: 12
                        ) {
                            mergeAll()
                        }
                    }
                }
                .padding(LWSpacing.page)
            }
            .background(PaperTexture())
            .navigationTitle("去重合并")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
                        .foregroundStyle(LWColors.cinnabar)
                }
            }
            .alert("合并失败", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("知道了", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "请稍后再试。")
            }
        }
    }

    private var introCard: some View {
        PaperCard(padding: 12) {
            HStack(spacing: 10) {
                Image(systemName: "rectangle.on.rectangle.angled")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(LWColors.warmGold)
                VStack(alignment: .leading, spacing: 3) {
                    Text("先预览，再合并")
                        .font(.titleSong(15))
                        .foregroundStyle(LWColors.ink)
                    Text("不会根据相似姓名猜测，也不会改动不确定的记录。")
                        .font(.bodySong(11))
                        .foregroundStyle(LWColors.muted)
                }
            }
        }
    }

    private func mergeAll() {
        do {
            let summary = try DuplicateMergeService.merge(groups, in: modelContext)
            resultMessage = "已整理 \(summary.groupCount) 组，合并移除 \(summary.removedRecordCount) 笔重复记录。"
            groups = []
            HapticsManager.success()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct ExcelImportPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let prepared: ExcelImportService.PreparedImport
    @State private var importedCount: Int?
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    summaryCard
                    if !prepared.issues.isEmpty {
                        issueCard
                    }
                    if let importedCount {
                        EmptyStateView(title: "导入完成", message: "已新增 \(importedCount) 笔往来记录，重复项和无法识别的行没有写入。")
                    } else if prepared.summary.importableCount > 0 {
                        SealButton(
                            title: "确认导入 \(prepared.summary.importableCount) 笔",
                            systemImage: "arrow.down.doc",
                            fontSize: 14,
                            verticalPadding: 10,
                            cornerRadius: 12
                        ) {
                            commit()
                        }
                    } else {
                        EmptyStateView(title: "没有需要新增的记录", message: "文件中的有效记录都已存在，或者内容无法识别。")
                    }
                }
                .padding(LWSpacing.page)
            }
            .background(PaperTexture())
            .navigationTitle("Excel 导入预览")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
                        .foregroundStyle(LWColors.cinnabar)
                }
            }
            .alert("导入失败", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("知道了", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "请稍后再试。")
            }
        }
    }

    private var summaryCard: some View {
        PaperCard(padding: 14, spacing: 10) {
            HStack {
                summaryValue("文件记录", prepared.summary.totalRowCount, color: LWColors.ink)
                summaryValue("可导入", prepared.summary.importableCount, color: LWColors.cinnabar)
                summaryValue("已存在", prepared.summary.duplicateCount, color: LWColors.warmGold)
                summaryValue("无法识别", prepared.summary.invalidCount, color: LWColors.muted)
            }
            GoldLineDivider()
            Text("导入只会新增数据，不会覆盖现有礼簿；重复记录会自动跳过。")
                .font(.bodySong(11))
                .foregroundStyle(LWColors.muted)
        }
    }

    private var issueCard: some View {
        PaperCard(padding: 12, spacing: 7) {
            Text("未导入的行")
                .font(.titleSong(14))
                .foregroundStyle(LWColors.ink)
            ForEach(prepared.issues.prefix(5)) { issue in
                Text("第 \(issue.rowNumber) 行：\(issue.message)")
                    .font(.bodySong(11))
                    .foregroundStyle(LWColors.muted)
            }
            if prepared.issues.count > 5 {
                Text("另有 \(prepared.issues.count - 5) 行未显示")
                    .font(.bodySong(10))
                    .foregroundStyle(LWColors.warmGold)
            }
        }
    }

    private func summaryValue(_ title: String, _ value: Int, color: Color) -> some View {
        VStack(spacing: 3) {
            Text("\(value)")
                .font(.amountKai(20))
                .foregroundStyle(color)
            Text(title)
                .font(.bodySong(9))
                .foregroundStyle(LWColors.muted)
        }
        .frame(maxWidth: .infinity)
    }

    private func commit() {
        do {
            importedCount = try ExcelImportService.commit(prepared, in: modelContext)
            HapticsManager.success()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
