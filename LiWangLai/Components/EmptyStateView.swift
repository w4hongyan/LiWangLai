import SwiftUI

struct EmptyStateView: View {
    let title: String
    let message: String
    var buttonTitle: String?
    var action: (() -> Void)?

    var body: some View {
        PaperCard {
            VStack(spacing: 14) {
                SealStamp(text: "礼", size: 44)
                    .opacity(0.75)
                Text(title)
                    .font(.titleSong(17))
                    .foregroundStyle(LWColors.ink)
                Text(message)
                    .font(.bodySong(13))
                    .foregroundStyle(LWColors.muted)
                    .multilineTextAlignment(.center)
                if let buttonTitle, let action {
                    Button(action: action) {
                        Text(buttonTitle)
                            .font(.bodySong(13).weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 8)
                            .background(LWColors.cinnabar, in: RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        }
    }
}
