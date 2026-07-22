import SwiftUI

struct ProPaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(PurchaseManager.self) private var purchases

    let source: PaywallSource

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                hero
                featureList
                trustNote
            }
            .padding(.horizontal, 22)
            .padding(.top, 18)
            .padding(.bottom, 18)
        }
        .background(PaperTexture())
        .safeAreaInset(edge: .bottom, spacing: 0) {
            purchaseDock
        }
        .overlay(alignment: .topTrailing) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(LWColors.inkSoft)
                    .frame(width: 34, height: 34)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .buttonStyle(.plain)
            .padding(14)
        }
        .task {
            if purchases.proProduct == nil {
                await purchases.loadProduct()
            }
        }
        .onChange(of: purchases.isProUnlocked) { _, unlocked in
            if unlocked {
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(650))
                    dismiss()
                }
            }
        }
    }

    private var hero: some View {
        VStack(spacing: 11) {
            ZStack {
                Circle()
                    .fill(LWColors.cinnabar.opacity(0.08))
                    .frame(width: 96, height: 96)

                // 付费页使用界面内的品牌印章，不直接缩放 App Icon。
                // App Icon 自带不透明留白，小尺寸展示会形成突兀的白色方块。
                SealStamp(text: "礼", size: 70, color: LWColors.cinnabar)
                    .overlay {
                        Circle()
                            .stroke(LWColors.warmGold.opacity(0.78), lineWidth: 1.5)
                            .padding(3)
                    }
                    .shadow(color: LWColors.cinnabar.opacity(0.16), radius: 8, y: 4)

                Text("PRO")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(LWColors.cinnabarDark, in: Capsule())
                    .overlay(Capsule().stroke(Color.white.opacity(0.72), lineWidth: 1))
                    .offset(x: 31, y: 31)
            }

            Text("礼往来 Pro")
                .font(.titleSong(30))
                .foregroundStyle(LWColors.ink)
            Text(source.feature?.subtitle ?? "一次买断，永久使用；手机与 iPad 通用")
                .font(.bodySong(14))
                .foregroundStyle(LWColors.muted)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Text("基础入簿、提醒、备份与隐私锁永久免费")
                .font(.bodySong(11).weight(.semibold))
                .foregroundStyle(LWColors.cinnabar)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(LWColors.cinnabar.opacity(0.07), in: Capsule())
        }
    }

    private var featureList: some View {
        PaperCard(padding: 14, spacing: 0) {
            ForEach(Array(PremiumFeature.allCases.enumerated()), id: \.element.id) { index, feature in
                HStack(spacing: 12) {
                    Image(systemName: feature.systemImage)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(feature == source.feature ? .white : LWColors.cinnabar)
                        .frame(width: 38, height: 38)
                        .background(
                            feature == source.feature ? LWColors.cinnabar : LWColors.cinnabar.opacity(0.08),
                            in: RoundedRectangle(cornerRadius: 10)
                        )
                    VStack(alignment: .leading, spacing: 3) {
                        Text(feature.title)
                            .font(.titleSong(14))
                            .foregroundStyle(LWColors.ink)
                        Text(feature.subtitle)
                            .font(.bodySong(10))
                            .foregroundStyle(LWColors.muted)
                            .lineLimit(2)
                    }
                    Spacer(minLength: 0)
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(LWColors.warmGold)
                }
                .padding(.vertical, 9)

                if index < PremiumFeature.allCases.count - 1 {
                    GoldLineDivider()
                        .padding(.leading, 50)
                }
            }
        }
    }

    private var purchaseDock: some View {
        VStack(spacing: 10) {
            SealButton(
                title: purchaseTitle,
                systemImage: purchaseSystemImage,
                fontSize: 15,
                verticalPadding: 12,
                cornerRadius: 14
            ) {
                Task { await purchases.purchasePro() }
            }
            .disabled(
                purchases.isProUnlocked
                    || purchases.isPurchasing
                    || purchases.isLoadingProduct
                    || purchases.proProduct == nil
            )

            if purchases.proProduct == nil, !purchases.isLoadingProduct {
                Button {
                    Task { await purchases.loadProduct() }
                } label: {
                    Text("重新获取价格")
                        .font(.bodySong(12).weight(.semibold))
                        .foregroundStyle(LWColors.cinnabar)
                }
                .buttonStyle(.plain)
            }

            Button {
                Task { await purchases.restorePurchases() }
            } label: {
                Text(purchases.isRestoring ? "正在恢复购买…" : "恢复购买")
                    .font(.bodySong(13).weight(.semibold))
                    .foregroundStyle(LWColors.cinnabar)
            }
            .buttonStyle(.plain)
            .disabled(purchases.isRestoring)

            if let message = purchases.statusMessage {
                Text(message)
                    .font(.bodySong(11))
                    .foregroundStyle(LWColors.inkSoft)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 22)
        .padding(.top, 12)
        .padding(.bottom, 10)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(LWColors.warmGold.opacity(0.2))
                .frame(height: 1)
        }
    }

    private var purchaseTitle: String {
        if purchases.isProUnlocked { return "礼往来 Pro 已永久解锁" }
        if purchases.isPurchasing { return "正在确认购买" }
        if let price = purchases.proProduct?.displayPrice {
            return "永久解锁 · \(price)"
        }
        return "正在获取本地价格…"
    }

    private var purchaseSystemImage: String {
        if purchases.isProUnlocked { return "checkmark.seal.fill" }
        if purchases.isPurchasing || purchases.isLoadingProduct { return "hourglass" }
        return "seal.fill"
    }

    private var trustNote: some View {
        VStack(spacing: 5) {
            Text("一次购买 · 无订阅 · 无广告")
                .font(.bodySong(11).weight(.semibold))
                .foregroundStyle(LWColors.inkSoft)
            Text("付款由 App Store 安全处理。使用同一 Apple 账户，可在 iPhone 与 iPad 恢复购买；完整备份与恢复始终免费。")
                .font(.bodySong(10))
                .foregroundStyle(LWColors.muted)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
    }
}

#Preview {
    ProPaywallView(source: .settings)
        .environment(PurchaseManager())
}
