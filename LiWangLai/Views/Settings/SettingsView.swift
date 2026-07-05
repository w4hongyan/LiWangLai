import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    let records: [GiftRecord]

    @State private var exportURL: URL?
    @State private var showExportError = false
    @State private var iCloudEnabled = false

    var body: some View {
        @Bindable var appState = appState

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                PageHeader(title: "我的")
                appCard
                section(title: "数据与备份") {
                    settingsToggle(icon: "icloud", title: "iCloud 同步", isOn: $iCloudEnabled, footnote: "预留入口，首版默认本地保存")
                    settingsRow(icon: "externaldrive", title: "本地备份", subtitle: "导出后可自行保存到文件")
                    Button {
                        exportCSV()
                    } label: {
                        settingsRowContent(icon: "doc.badge.arrow.up", title: "导出 CSV", subtitle: "姓名、类型、金额、事件、关系、日期、备注、回礼状态")
                    }
                    .buttonStyle(.plain)
                    settingsRow(icon: "tablecells", title: "导出 Excel", subtitle: "后续扩展")
                }

                if let exportURL {
                    ShareLink(item: exportURL) {
                        Label("分享刚导出的 CSV", systemImage: "square.and.arrow.up")
                            .font(.bodySong(18))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(LWColors.cinnabar, in: RoundedRectangle(cornerRadius: LWRadius.button))
                    }
                }

                section(title: "隐私安全") {
                    settingsToggle(icon: "faceid", title: "Face ID 解锁", isOn: $appState.faceIDEnabled, footnote: "入口已预留，后续接入 LocalAuthentication")
                    settingsToggle(icon: "eye.slash", title: "隐藏金额", isOn: $appState.prefersHiddenAmounts)
                    settingsRow(icon: "circle.grid.3x3", title: "打开时默认模糊金额", subtitle: "后续扩展")
                }

                themeSection

                section(title: "其他") {
                    NavigationLink {
                        QuickDeskView()
                    } label: {
                        settingsRowContent(icon: "rectangle.split.2x1", title: "横屏记账台", subtitle: "现场连续入簿雏形")
                    }
                    .buttonStyle(.plain)
                    settingsRow(icon: "bubble.left", title: "意见反馈", subtitle: "后续接入邮箱或表单")
                    settingsRow(icon: "info.circle", title: "关于礼往来", subtitle: "版本 1.0")
                }

                Text("· 数据默认保存在你的设备中 ·")
                    .font(.bodySong(14))
                    .foregroundStyle(LWColors.warmGold)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 24)
            }
            .padding(.horizontal, LWSpacing.page)
            .padding(.top, 28)
        }
        .background(PaperTexture())
        .alert("导出失败", isPresented: $showExportError) {
            Button("知道了", role: .cancel) {}
        } message: {
            Text("请稍后再试，或检查设备存储空间。")
        }
    }

    private var appCard: some View {
        PaperCard {
            HStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [LWColors.cinnabar, LWColors.cinnabarDark],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 76, height: 76)
                    .overlay(
                        Text("礼")
                            .font(.titleSong(42))
                            .foregroundStyle(.white)
                    )
                VStack(alignment: .leading, spacing: 8) {
                    Text("礼往来")
                        .font(.titleSong(27))
                        .foregroundStyle(LWColors.ink)
                    Text("人情有数，往来有度")
                        .font(.bodySong(17))
                        .foregroundStyle(LWColors.warmGold)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(LWColors.muted)
            }
        }
    }

    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.bodySong(18))
                .foregroundStyle(LWColors.inkSoft)
                .padding(.leading, 16)
            PaperCard(padding: 0) {
                VStack(spacing: 0) {
                    content()
                }
            }
        }
    }

    private var themeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("主题")
                .font(.bodySong(18))
                .foregroundStyle(LWColors.inkSoft)
                .padding(.leading, 16)
            PaperCard {
                HStack(spacing: 10) {
                    ForEach(AppTheme.allCases) { theme in
                        Button {
                            appState.selectedTheme = theme
                        } label: {
                            VStack(spacing: 8) {
                                Circle()
                                    .fill(themeColor(theme))
                                    .frame(width: 20, height: 20)
                                Text(theme.title)
                                    .font(.bodySong(15))
                                    .foregroundStyle(LWColors.ink)
                                Image(systemName: appState.selectedTheme == theme ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(appState.selectedTheme == theme ? LWColors.cinnabar : LWColors.cardStroke)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white.opacity(0.5))
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(appState.selectedTheme == theme ? LWColors.cinnabar : LWColors.cardStroke.opacity(0.35)))
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func settingsRow(icon: String, title: String, subtitle: String? = nil) -> some View {
        settingsRowContent(icon: icon, title: title, subtitle: subtitle)
    }

    private func settingsRowContent(icon: String, title: String, subtitle: String? = nil) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(LWColors.warmGold)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.bodySong(18))
                    .foregroundStyle(LWColors.ink)
                if let subtitle {
                    Text(subtitle)
                        .font(.bodySong(13))
                        .foregroundStyle(LWColors.muted)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(LWColors.muted.opacity(0.7))
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .overlay(alignment: .bottom) {
            GoldLineDivider()
                .padding(.leading, 60)
        }
    }

    private func settingsToggle(icon: String, title: String, isOn: Binding<Bool>, footnote: String? = nil) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(LWColors.warmGold)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.bodySong(18))
                    .foregroundStyle(LWColors.ink)
                if let footnote {
                    Text(footnote)
                        .font(.bodySong(13))
                        .foregroundStyle(LWColors.muted)
                }
            }
            Spacer()
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(LWColors.cinnabar)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .overlay(alignment: .bottom) {
            GoldLineDivider()
                .padding(.leading, 60)
        }
    }

    private func themeColor(_ theme: AppTheme) -> Color {
        switch theme {
        case .paper: LWColors.paper
        case .cinnabar: LWColors.cinnabar
        case .inkGreen: LWColors.jade
        case .warmGold: LWColors.warmGold
        }
    }

    private func exportCSV() {
        do {
            exportURL = try ExportService.writeCSV(from: records)
            HapticsManager.success()
        } catch {
            showExportError = true
        }
    }
}
