import SwiftUI

struct LockScreenView: View {
    @Environment(AppState.self) private var appState
    let onUnlock: () -> Void

    @State private var showAuthError = false

    var body: some View {
        ZStack {
            LWColors.paper.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                SealStamp(text: "礼", size: 82)

                Text("礼往来")
                    .font(.custom("SourceHanSerifSC-SemiBold", size: 42))
                    .foregroundStyle(LWColors.ink)

                Text("人情有数，往来有度")
                    .font(.custom("SourceHanSerifSC-Regular", size: 18))
                    .foregroundStyle(LWColors.warmGold)

                Spacer()

                SealButton(
                    title: "解锁查看礼簿",
                    systemImage: BiometricService.isAvailable ? "faceid" : "lock"
                ) {
                    authenticate()
                }
                .padding(.horizontal, 36)

                if showAuthError {
                    Text("验证未通过，可重试或使用设备密码")
                        .font(.custom("SourceHanSerifSC-Regular", size: 13))
                        .foregroundStyle(LWColors.cinnabar)
                }
            }
            .padding(.bottom, 60)
        }
    }

    private func authenticate() {
        Task { @MainActor in
            let result = await BiometricService.authenticate()
            switch result {
            case .success:
                withAnimation(.easeOut(duration: 0.25)) {
                    onUnlock()
                }
            case .failure:
                showAuthError = true
            }
        }
    }
}
