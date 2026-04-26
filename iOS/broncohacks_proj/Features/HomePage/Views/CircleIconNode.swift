import SwiftUI

struct CircleIconNode: View {
    let icon: String
    let iconColor: Color
    let label: String

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 52, height: 52)
                Circle()
                    .stroke(iconColor.opacity(0.25), lineWidth: 1)
                    .frame(width: 52, height: 52)
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(iconColor)
            }

            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.4))
                .kerning(0.8)
        }
        .frame(width: 80)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        CircleIconNode(icon: "sun.max.fill", iconColor: .orange, label: "Solar")
    }
    .preferredColorScheme(.dark)
}
