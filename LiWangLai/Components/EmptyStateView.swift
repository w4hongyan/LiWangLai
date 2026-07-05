import SwiftUI

struct EmptyStateView: View {
    let title: String
    let message: String
    var buttonTitle: String?
    var action: (() -> Void)?

    var body: some View {
        PaperCard {
            VStack(spacing: 14) {
                SealStamp(text: "礼", size: 58)
                    .opacity(0.8)
                Text(title)
                    .font(.titleSong(24))
                    .foregroundStyle(LWColors.ink)
                Text(message)
                    .font(.bodySong(16))
                    .foregroundStyle(LWColors.muted)
                    .multilineTextAlignment(.center)
                if let buttonTitle, let action {
                    Button(buttonTitle, action: action)
                        .buttonStyle(.borderedProminent)
                        .tint(LWColors.cinnabar)
                        .controlSize(.large)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
        }
    }
}
