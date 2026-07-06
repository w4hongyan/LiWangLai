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
            VStack(alignment: .leading, spacing: 6) {
                settingsHeader
                appCard
                section(title: "数据与备份") {
                    settingsToggle(icon: "icloud", title: "iCloud 同步", isOn: $iCloudEnabled, footnote: "预留入口，首版默认本地保存")
                    settingsRow(icon: "externaldrive", title: "本地备份", subtitle: "导出后可自行保存到文件")
                    Button {
                        exportExcel()
                    } label: {
                        settingsRowContent(icon: "tablecells", title: "导出 Excel", subtitle: "可用 Excel / Numbers 打开")
                    }
                    .buttonStyle(.plain)
                }

                if let exportURL {
                    ShareLink(item: exportURL) {
                        Label("分享刚导出的 Excel", systemImage: "square.and.arrow.up")
                            .font(.bodySong(13))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(LWColors.cinnabar, in: RoundedRectangle(cornerRadius: LWRadius.button))
                    }
                }

                section(title: "隐私安全") {
                    settingsToggle(icon: "faceid", title: "Face ID 解锁", isOn: $appState.faceIDEnabled, footnote: "入口已预留，后续接入 LocalAuthentication")
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
            Text("请稍后再试，或检查设备存储空间。")
        }
    }

    private var settingsHeader: some View {
        ZStack(alignment: .topTrailing) {
            MountainDecoration()
                .frame(width: 180, height: 88)
                .offset(x: 20, y: 0)
                .opacity(0.36)
                .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 6) {
                Text("我的")
                    .font(.titleSong(30))
                    .foregroundStyle(LWColors.ink)
                Text("偏好与数据")
                    .font(.bodySong(13))
                    .foregroundStyle(LWColors.warmGold)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 10)
        }
        .frame(height: 94)
    }

    private var appCard: some View {
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

    private func settingsRow(icon: String, title: String, subtitle: String? = nil) -> some View {
        settingsRowContent(icon: icon, title: title, subtitle: subtitle)
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

    private func settingsToggle(icon: String, title: String, isOn: Binding<Bool>, footnote: String? = nil) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(LWColors.warmGold)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.bodySong(13))
                    .foregroundStyle(LWColors.ink)
                if let footnote {
                    Text(footnote)
                        .font(.bodySong(10))
                        .foregroundStyle(LWColors.muted)
                        .lineLimit(1)
                }
            }
            Spacer()
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(LWColors.cinnabar)
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
            showExportError = true
        }
    }
}
