import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    let records: [GiftRecord]

    @State private var exportURL: URL?
    @State private var showExportError = false
    @State private var exportErrorMessage = "请稍后再试，或检查设备存储空间。"
    @State private var showAbout = false

    var body: some View {
        @Bindable var appState = appState

        ScrollView {
            VStack(alignment: .leading, spacing: 6) {
                settingsHeader
                appCard
                section(title: "数据") {
                    Button {
                        exportExcel()
                    } label: {
                        settingsRowContent(icon: "tablecells", title: "导出 Excel", subtitle: records.isEmpty ? "暂无记录可导出" : "生成 .xlsx 文件，含完整往来字段")
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

                themeSection

                section(title: "其他") {
                    Button {
                        showAbout = true
                    } label: {
                        settingsRowContent(icon: "info.circle", title: "关于礼往来", subtitle: "版本 1.0")
                    }
                    .buttonStyle(.plain)
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
            Text(exportErrorMessage)
        }
        .sheet(isPresented: $showAbout) {
            AboutView()
                .presentationDetents([.height(270)])
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
