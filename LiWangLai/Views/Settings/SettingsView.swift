import Foundation
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @Environment(PurchaseManager.self) private var purchases
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \HostedGiftEvent.date, order: .reverse) private var hostedEvents: [HostedGiftEvent]
    let records: [GiftRecord]

    @State private var exportURL: URL?
    @State private var showBackupImporter = false
    @State private var showExcelImporter = false
    @State private var dataSheet: DataManagementSheet?
    @State private var activeAlert: SettingsAlert?
    @State private var showAbout = false
    @State private var showPrivacy = false
    @State private var showTerms = false
    @State private var notificationsEnabled = LocalNotificationService.isEnabled
    @State private var notificationStatus = "正在读取状态"
    @State private var pendingExport: DataExportKind?

    var body: some View {
        @Bindable var appState = appState

        ScrollView {
            VStack(alignment: .leading, spacing: 11) {
                settingsHeader
                appCard
                proSection
                dataSection
                notificationSection
                privacySection(appState: appState)
                themeSection
                otherSection

                Text("· 数据仅保存在你的设备中 · 建议定期备份 ·")
                    .font(.bodySong(10))
                    .foregroundStyle(LWColors.warmGold)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 8)
            }
            .padding(.horizontal, LWSpacing.page)
            .padding(.top, -4)
            .padding(.bottom, 12)
        }
        .background(PaperTexture())
        .confirmationDialog(
            "导出文件包含私人信息",
            isPresented: Binding(
                get: { pendingExport != nil },
                set: { if !$0 { pendingExport = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("继续导出") {
                performPendingExport()
            }
            Button("取消", role: .cancel) {
                pendingExport = nil
            }
        } message: {
            Text("文件可能包含姓名、联系方式、金额和备注，且不会自动加密。请只保存到可信位置。")
        }
        .alert(item: $activeAlert) { alert in
            switch alert {
            case .error(let message):
                return Alert(
                    title: Text("操作失败"),
                    message: Text(message),
                    dismissButton: .default(Text("知道了"))
                )
            case .restore(let backup):
                let summary = backup.summary
                return Alert(
                    title: Text("恢复完整备份？"),
                    message: Text("备份包含 \(summary.recordCount) 笔往来和 \(summary.eventCount) 场我家办的事。恢复会替换当前设备上的全部礼簿数据。"),
                    primaryButton: .destructive(Text("替换并恢复")) {
                        restore(backup)
                    },
                    secondaryButton: .cancel(Text("取消"))
                )
            case .restoreSucceeded(let summary):
                return Alert(
                    title: Text("恢复完成"),
                    message: Text("已恢复 \(summary.recordCount) 笔往来和 \(summary.eventCount) 场我家办的事。"),
                    dismissButton: .default(Text("知道了"))
                )
            }
        }
        .sheet(isPresented: $showAbout) {
            AboutView()
                .presentationDetents([.height(270)])
        }
        .sheet(isPresented: $showPrivacy) {
            LegalView(title: "隐私政策", content: privacyContent)
        }
        .sheet(isPresented: $showTerms) {
            LegalView(title: "用户协议", content: termsContent)
        }
        .sheet(item: $exportURL) { url in
            ShareSheet(items: [url])
        }
        .sheet(item: $dataSheet) { sheet in
            switch sheet {
            case .duplicates:
                DuplicateMergeView(records: records)
            case .excel(let prepared):
                ExcelImportPreviewView(prepared: prepared)
            }
        }
        .fileImporter(
            isPresented: $showBackupImporter,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            importBackup(result)
        }
        .fileImporter(
            isPresented: $showExcelImporter,
            allowedContentTypes: [UTType(filenameExtension: "xlsx") ?? .data],
            allowsMultipleSelection: false
        ) { result in
            importExcel(result)
        }
        .task {
            notificationStatus = await LocalNotificationService.authorizationDescription()
            notificationsEnabled = LocalNotificationService.isEnabled
        }
    }

    private var dataSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("数据与备份")
                .font(.bodySong(12))
                .foregroundStyle(LWColors.inkSoft)
                .padding(.leading, 10)
            PaperCard(padding: 0) {
                VStack(spacing: 0) {
                    Button {
                        requirePro(.excelTools) {
                            pendingExport = .excel
                        }
                    } label: {
                        settingsRowContent(icon: "tablecells", title: "导出 Excel", subtitle: records.isEmpty ? "暂无记录可导出" : "生成 .xlsx 文件，含完整往来字段", premiumFeature: .excelTools)
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())

                    Button {
                        requirePro(.excelTools) {
                            showExcelImporter = true
                        }
                    } label: {
                        settingsRowContent(icon: "square.and.arrow.down", title: "导入 Excel", subtitle: "先预览，重复项自动跳过，不覆盖现有数据", premiumFeature: .excelTools)
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())

                    Button {
                        requirePro(.duplicateMerge) {
                            dataSheet = .duplicates
                        }
                    } label: {
                        let duplicateCount = DuplicateMergeService.groups(in: records).reduce(0) { $0 + $1.duplicateCount }
                        settingsRowContent(
                            icon: "rectangle.on.rectangle.angled",
                            title: "去重合并",
                            subtitle: duplicateCount == 0 ? "未发现明确重复记录" : "发现 \(duplicateCount) 笔明确重复记录",
                            premiumFeature: .duplicateMerge
                        )
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())

                    Button {
                        pendingExport = .backup
                    } label: {
                        settingsRowContent(
                            icon: "archivebox",
                            title: "导出完整备份",
                            subtitle: records.isEmpty && hostedEvents.isEmpty ? "暂无数据可备份" : "用于在礼往来中完整恢复"
                        )
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())

                    Button {
                        showBackupImporter = true
                    } label: {
                        settingsRowContent(icon: "arrow.down.doc", title: "从备份恢复", subtitle: "恢复前会展示内容并再次确认")
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())
                }
            }
        }
    }

    private var notificationSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("送礼与回礼提醒")
                .font(.bodySong(12))
                .foregroundStyle(LWColors.inkSoft)
                .padding(.leading, 10)
            PaperCard(padding: 0) {
                HStack(spacing: 10) {
                    Image(systemName: "bell.badge")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(LWColors.warmGold)
                        .frame(width: 20)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("系统通知")
                            .font(.bodySong(13))
                            .foregroundStyle(LWColors.ink)
                        Text("\(notificationStatus) · 在入簿的更多信息中设置日期")
                            .font(.bodySong(10))
                            .foregroundStyle(LWColors.muted)
                            .lineLimit(2)
                    }
                    Spacer()
                    Toggle("", isOn: Binding(
                        get: { notificationsEnabled },
                        set: { enabled in
                            Task { await updateNotifications(enabled) }
                        }
                    ))
                    .tint(LWColors.cinnabar)
                    .labelsHidden()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
            }
        }
    }

    private func privacySection(appState: AppState) -> some View {
        @Bindable var appState = appState

        return VStack(alignment: .leading, spacing: 4) {
            Text("隐私安全")
                .font(.bodySong(12))
                .foregroundStyle(LWColors.inkSoft)
                .padding(.leading, 10)
            PaperCard(padding: 0) {
                VStack(spacing: 0) {
                    if BiometricService.isAvailable {
                        HStack(spacing: 10) {
                            biometricLabel
                            Spacer()
                            Toggle("", isOn: $appState.isBiometricLockEnabled)
                                .tint(LWColors.cinnabar)
                                .labelsHidden()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 9)
                    }
                }
            }
        }
    }

    private var settingsHeader: some View {
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
                    Text("我的")
                        .font(.titleSong(40))
                        .foregroundStyle(LWColors.ink)
                    Text("偏好与数据")
                        .font(.bodySong(17))
                        .foregroundStyle(LWColors.warmGold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 18)
            }
        }
        .frame(minHeight: 124, alignment: .top)
    }

    private var appCard: some View {
        Button {
            showAbout = true
        } label: {
            PaperCard(padding: 10) {
                HStack(spacing: 10) {
                    Image("lwl_app_icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("礼往来")
                            .font(.titleSong(18))
                            .foregroundStyle(LWColors.ink)
                        Text("人情有数，往来有度")
                            .font(.bodySong(12))
                            .foregroundStyle(LWColors.warmGold)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(LWColors.muted)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var proSection: some View {
        Button {
            purchases.presentPaywall()
        } label: {
            PaperCard(padding: 12) {
                HStack(spacing: 12) {
                    ZStack {
                        Image("ceremony_table_badge")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 46, height: 46)
                        if !purchases.isProUnlocked {
                            Text("PRO")
                                .font(.system(size: 8, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(LWColors.cinnabar, in: Capsule())
                                .offset(x: 18, y: 18)
                        }
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(purchases.isProUnlocked ? "礼往来 Pro 已解锁" : "升级礼往来 Pro")
                            .font(.titleSong(17))
                            .foregroundStyle(LWColors.ink)
                        Text(proStatusSubtitle)
                            .font(.bodySong(11))
                            .foregroundStyle(LWColors.muted)
                            .lineLimit(2)
                    }
                    Spacer()
                    Image(systemName: purchases.isProUnlocked ? "checkmark.seal.fill" : "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(purchases.isProUnlocked ? LWColors.jade : LWColors.cinnabar)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var proStatusSubtitle: String {
        if purchases.isProUnlocked {
            return "永久版 · 手机与 iPad 通用"
        }
        return "一次买断：礼台模式、Excel、智能去重与高级主题"
    }

    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.bodySong(12))
                .foregroundStyle(LWColors.inkSoft)
                .padding(.leading, 10)
            PaperCard(padding: 0) {
                VStack(spacing: 0) {
                    content()
                }
            }
        }
    }

    private var themeSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("主题")
                .font(.bodySong(12))
                .foregroundStyle(LWColors.inkSoft)
                .padding(.leading, 10)
            PaperCard(padding: 8) {
                HStack(spacing: 6) {
                    ForEach(AppTheme.allCases) { theme in
                        Button {
                            if theme == .paper || purchases.isProUnlocked {
                                appState.selectedTheme = theme
                            } else {
                                purchases.presentPaywall(for: .premiumThemes)
                            }
                        } label: {
                            VStack(spacing: 3) {
                                Circle()
                                    .fill(themeColor(theme))
                                    .frame(width: 14, height: 14)
                                Text(theme.title)
                                    .font(.bodySong(10))
                                    .foregroundStyle(LWColors.ink)
                                Image(systemName: theme != .paper && !purchases.isProUnlocked ? "lock.fill" : (appState.selectedTheme == theme ? "checkmark.circle.fill" : "circle"))
                                    .font(.system(size: 10))
                                    .foregroundStyle(theme != .paper && !purchases.isProUnlocked ? LWColors.warmGold : (appState.selectedTheme == theme ? LWColors.cinnabar : LWColors.cardStroke))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 5)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.5))
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(appState.selectedTheme == theme ? LWColors.cinnabar : LWColors.cardStroke.opacity(0.35)))
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var otherSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("其他")
                .font(.bodySong(12))
                .foregroundStyle(LWColors.inkSoft)
                .padding(.leading, 10)
            PaperCard(padding: 0) {
                VStack(spacing: 0) {
                    Button {
                        showPrivacy = true
                    } label: {
                        settingsRowContent(icon: "hand.raised", title: "隐私政策", subtitle: nil)
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())

                    Button {
                        showTerms = true
                    } label: {
                        settingsRowContent(icon: "doc.text", title: "用户协议", subtitle: nil)
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())

                    Button {
                        showAbout = true
                    } label: {
                        settingsRowContent(icon: "info.circle", title: "关于我们", subtitle: nil)
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())
                }
            }
        }
    }

    private func settingsRowContent(icon: String, title: String, subtitle: String? = nil, premiumFeature: PremiumFeature? = nil) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(LWColors.warmGold)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.bodySong(13))
                    .foregroundStyle(LWColors.ink)
                if let subtitle {
                    Text(subtitle)
                        .font(.bodySong(10))
                        .foregroundStyle(LWColors.muted)
                        .lineLimit(2)
                }
            }
            Spacer()
            if premiumFeature != nil, !purchases.isProUnlocked {
                proBadge
            }
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(LWColors.muted.opacity(0.7))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .overlay(alignment: .bottom) {
            GoldLineDivider()
                .padding(.leading, 44)
        }
    }

    private var biometricLabel: some View {
        Group {
            Image(systemName: "faceid")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(LWColors.warmGold)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text("\(BiometricService.biometricTypeName) 解锁")
                    .font(.bodySong(13))
                    .foregroundStyle(LWColors.ink)
                Text("打开 App 时验证身份以查看礼簿")
                    .font(.bodySong(10))
                    .foregroundStyle(LWColors.muted)
                    .lineLimit(2)
            }
        }
    }

    private var proBadge: some View {
        Text("PRO")
            .font(.system(size: 8, weight: .black, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(LWColors.cinnabar, in: Capsule())
    }

    private func requirePro(_ feature: PremiumFeature, action: () -> Void) {
        if purchases.isProUnlocked {
            action()
        } else {
            purchases.presentPaywall(for: feature)
        }
    }

    private func themeColor(_ theme: AppTheme) -> Color {
        switch theme {
        case .paper: theme.palette.paperDeep
        case .cinnabar, .inkGreen, .warmGold: theme.palette.primary
        }
    }

    private func exportExcel() {
        do {
            exportURL = try ExportService.writeExcel(from: records)
            HapticsManager.success()
        } catch {
            activeAlert = .error((error as? LocalizedError)?.errorDescription ?? error.localizedDescription)
        }
    }

    private func exportCompleteBackup() {
        do {
            exportURL = try BackupService.writeBackup(records: records, events: hostedEvents)
            HapticsManager.success()
        } catch {
            activeAlert = .error((error as? LocalizedError)?.errorDescription ?? error.localizedDescription)
        }
    }

    private func performPendingExport() {
        let export = pendingExport
        pendingExport = nil
        switch export {
        case .excel:
            exportExcel()
        case .backup:
            exportCompleteBackup()
        case nil:
            break
        }
    }

    private func importBackup(_ result: Result<[URL], Error>) {
        do {
            guard let url = try result.get().first else { return }
            let didAccess = url.startAccessingSecurityScopedResource()
            defer {
                if didAccess {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            let data = try Data(contentsOf: url)
            activeAlert = .restore(try BackupService.prepareRestore(from: data))
        } catch let error as CocoaError where error.code == .userCancelled {
            return
        } catch {
            activeAlert = .error((error as? LocalizedError)?.errorDescription ?? error.localizedDescription)
        }
    }

    private func restore(_ backup: BackupService.PreparedBackup) {
        do {
            let summary = try BackupService.restore(backup, in: modelContext)
            HapticsManager.success()
            Task { @MainActor in
                activeAlert = .restoreSucceeded(summary)
            }
        } catch {
            activeAlert = .error((error as? LocalizedError)?.errorDescription ?? error.localizedDescription)
        }
    }

    private func importExcel(_ result: Result<[URL], Error>) {
        do {
            guard let url = try result.get().first else { return }
            let didAccess = url.startAccessingSecurityScopedResource()
            defer {
                if didAccess { url.stopAccessingSecurityScopedResource() }
            }
            let data = try Data(contentsOf: url)
            dataSheet = .excel(try ExcelImportService.prepare(from: data, existingRecords: records))
        } catch let error as CocoaError where error.code == .userCancelled {
            return
        } catch {
            activeAlert = .error((error as? LocalizedError)?.errorDescription ?? error.localizedDescription)
        }
    }

    @MainActor
    private func updateNotifications(_ enabled: Bool) async {
        do {
            if enabled {
                let granted = try await LocalNotificationService.requestAndEnable(records: records)
                notificationsEnabled = granted
                if !granted {
                    activeAlert = .error("通知权限未开启。可前往 iPhone“设置 → 通知 → 礼往来”重新允许。")
                }
            } else {
                await LocalNotificationService.disable()
                notificationsEnabled = false
            }
            notificationStatus = await LocalNotificationService.authorizationDescription()
        } catch {
            notificationsEnabled = false
            activeAlert = .error(error.localizedDescription)
        }
    }

}

private enum DataExportKind {
    case excel
    case backup
}

private enum DataManagementSheet: Identifiable {
    case duplicates
    case excel(ExcelImportService.PreparedImport)

    var id: String {
        switch self {
        case .duplicates: "duplicates"
        case .excel(let prepared): "excel-\(prepared.id.uuidString)"
        }
    }
}

private enum SettingsAlert: Identifiable {
    case error(String)
    case restore(BackupService.PreparedBackup)
    case restoreSucceeded(BackupService.Summary)

    var id: String {
        switch self {
        case .error(let message): "error-\(message)"
        case .restore(let backup): "restore-\(backup.summary.createdAt.timeIntervalSince1970)"
        case .restoreSucceeded(let summary): "success-\(summary.createdAt.timeIntervalSince1970)"
        }
    }
}

private struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    private var versionText: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "-"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "-"
        return "版本 \(version)（\(build)）· 数据默认保存在你的设备中"
    }

    var body: some View {
        VStack(spacing: 12) {
            Image("lwl_app_icon")
                .resizable()
                .scaledToFit()
                .frame(width: 52, height: 52)
            Text("礼往来")
                .font(.titleSong(22))
                .foregroundStyle(LWColors.ink)
            Text("人情有数，往来有度")
                .font(.bodySong(13))
                .foregroundStyle(LWColors.warmGold)
            Text(versionText)
                .font(.bodySong(11))
                .foregroundStyle(LWColors.muted)
            Button {
                dismiss()
            } label: {
                Text("知道了")
                    .font(.bodySong(13).weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 9)
                    .background(LWColors.cinnabar, in: RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .padding(20)
        .background(PaperTexture())
    }
}


// MARK: - Privacy & Terms Content

private let privacyContent = """
我们非常重视你的隐私。

数据存储：
所有礼往来数据（姓名、金额、事件、日期等往来记录）仅保存在你的设备本地，不会上传至任何服务器，也不会分享给任何第三方。

数据收集：
我们不收集任何个人数据。礼往来不使用任何分析工具、广告 SDK 或用户追踪技术。

购买信息：
礼往来 Pro 的购买与恢复由 Apple App Store 处理。App 仅通过 StoreKit 读取你是否拥有 Pro 权益，不会读取或保存银行卡等付款信息。

系统权限：
· Face ID / Touch ID：仅用于 App 本地解锁验证，生物特征数据由系统安全模块处理，App 无法读取。
· 导出功能：仅在用户主动触发时生成 Excel 或完整备份文件并保存至设备。导出文件不会自动加密，请只保存到可信位置。
· 通知：仅在用户主动开启后，由 iPhone 在设备本地安排送礼或回礼提醒。

如你对隐私保护有任何疑问，欢迎通过 App Store 评论区联系我们。
"""

private let termsContent = """
欢迎使用「礼往来」。

一、服务说明
礼往来是一款帮助你管理人情往来记录的工具 App。所有数据存储在设备本地，不会上传至云端或第三方服务器。

二、数据安全
请妥善保管你的设备。我们建议开启 Face ID / Touch ID 解锁以保护你的隐私。如设备丢失或损坏，存在数据丢失风险，建议定期导出完整备份。

三、免费功能与 Pro
App 可免费下载，基础入簿、查询、提醒、Face ID / Touch ID 隐私锁以及完整备份与恢复可免费使用。礼往来 Pro 为一次性购买项目，用于永久解锁礼台模式、Excel 工具、智能去重和高级主题；实际价格以 App Store 购买页显示为准。使用同一 Apple 账户，可在 iPhone 与 iPad 通过“恢复购买”恢复权益。

四、免责声明
本 App 仅提供记录与管理功能，不对任何因使用本 App 而产生的争议或损失承担责任。礼金金额、回礼建议等仅供参考，不构成任何建议。

五、适用法律
本协议适用中华人民共和国法律。如本协议任何条款无效，不影响其余条款的效力。

如有疑问，欢迎通过 App Store 联系我们。
"""

private struct LegalView: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    let content: String

    var body: some View {
        NavigationStack {
            ScrollView {
                Text(content)
                    .font(.bodySong(14))
                    .foregroundStyle(LWColors.ink)
                    .padding(LWSpacing.page)
            }
            .background(PaperTexture())
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundStyle(LWColors.cinnabar)
                }
            }
        }
    }
}

// MARK: - Share Sheet

private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}
