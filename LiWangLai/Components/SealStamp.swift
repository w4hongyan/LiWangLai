import SwiftUI

struct SealStamp: View {
    let text: String
    var size: CGFloat = 44
    var color: Color = LWColors.cinnabar

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [color, color.opacity(0.78)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Text(text)
                .font(.titleSong(size * 0.46))
                .foregroundStyle(.white)
        }
        .frame(width: size, height: size)
    }
}
