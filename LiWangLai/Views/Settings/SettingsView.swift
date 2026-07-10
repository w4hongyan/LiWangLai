import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    let records: [GiftRecord]

    @State private var exportURL: URL?
    @State private var showExportError = false
    @State private var exportErrorMessage = "请稍后再试，或检查设备存储空间。"
    @State private var showAbout = false
    @State private var showPrivacy = false
    @State private var showTerms = false

    var body: some View {
        @Bindable var appState = appState

        ScrollView {
            VStack(alignment: .leading, spacing: 11) {
                settingsHeader
                appCard
                dataSection
                privacySection(appState: appState)
                themeSection
                otherSection

                Text("· 数据仅保存在你的设备中 ·")
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
        .alert("导出失败", isPresented: $showExportError) {
            Button("知道了", role: .cancel) {}
        } message: {
            Text(exportErrorMessage)
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
                        exportExcel()
                    } label: {
                        settingsRowContent(icon: "tablecells", title: "导出 Excel", subtitle: records.isEmpty ? "暂无记录可导出" : "生成 .xlsx 文件，含完整往来字段")
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())
                }
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
                                    .lineLimit(1)
                            }
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
        .frame(height: 124)
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
                            appState.selectedTheme = theme
                        } label: {
                            VStack(spacing: 3) {
                                Circle()
                                    .fill(themeColor(theme))
                                    .frame(width: 14, height: 14)
                                Text(theme.title)
                                    .font(.bodySong(10))
                                    .foregroundStyle(LWColors.ink)
                                Image(systemName: appState.selectedTheme == theme ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 10))
                                    .foregroundStyle(appState.selectedTheme == theme ? LWColors.cinnabar : LWColors.cardStroke)
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

    private func settingsRowContent(icon: String, title: String, subtitle: String? = nil) -> some View {
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
                        .lineLimit(1)
                }
            }
            Spacer()
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
            exportErrorMessage = (error as? LocalizedError)?.errorDescription ?? "请稍后再试，或检查设备存储空间。"
            showExportError = true
        }
    }

}

private struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

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
            Text("版本 1.0 · 数据默认保存在你的设备中")
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

系统权限：
· Face ID / Touch ID：仅用于 App 本地解锁验证，生物特征数据由系统安全模块处理，App 无法读取。
· 导出功能：仅在用户主动触发时生成 Excel 文件并保存至设备。

如你对隐私保护有任何疑问，欢迎通过 App Store 评论区联系我们。
"""

private let termsContent = """
欢迎使用「礼往来」。

一、服务说明
礼往来是一款帮助你管理人情往来记录的工具 App。所有数据存储在设备本地，不会上传至云端或第三方服务器。

二、数据安全
请妥善保管你的设备。我们建议开启 Face ID / Touch ID 解锁以保护你的隐私。如设备丢失或损坏，存在数据丢失风险，建议定期通过导出功能备份数据。

三、免责声明
本 App 仅提供记录与管理功能，不对任何因使用本 App 而产生的争议或损失承担责任。礼金金额、回礼建议等仅供参考，不构成任何建议。

四、适用法律
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
