import SwiftUI

struct SealButton: View {
    let title: String
    var systemImage: String? = nil
    var isDisabled = false
    var fontSize: CGFloat = 16
    var verticalPadding: CGFloat = 12
    var cornerRadius: CGFloat = LWRadius.button
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button {
            HapticsManager.lightTap()
            action()
        } label: {
            HStack(spacing: 8) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 16, weight: .medium))
                }
                Text(title)
                    .font(.bodySong(fontSize).weight(.semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, verticalPadding)
            .background(
                LinearGradient(
                    colors: [LWColors.cinnabar, LWColors.cinnabarDark],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            )
            .scaleEffect(isPressed ? 0.98 : 1)
            .opacity(isDisabled ? 0.45 : 1)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}
