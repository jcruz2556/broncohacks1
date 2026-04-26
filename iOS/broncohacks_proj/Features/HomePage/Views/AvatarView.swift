import SwiftUI

struct AvatarView: View {
    let label: String
    var size: CGFloat = 36
    var fillColor: Color = .orange.opacity(0.2)
    var strokeColor: Color = .orange.opacity(0.4)
    var labelColor: Color = .orange

    var body: some View {
        ZStack {
            Circle()
                .fill(fillColor)
                .frame(width: size, height: size)
            Circle()
                .stroke(strokeColor, lineWidth: 1)
                .frame(width: size, height: size)
            Text(label)
                .font(.system(size: size * 0.38, weight: .semibold))
                .foregroundStyle(labelColor)
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        AvatarView(label: "K")
    }
    .preferredColorScheme(.dark)
}
