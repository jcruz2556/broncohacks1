import SwiftUI

struct SystemActiveBanner: View {
    // MARK: Data owned by me
    @State private var pulsing = false

    // MARK: Data shared with me
    let panelsOnline: Int
    let totalPanels: Int
    let outputKW: Double

    var body: some View {
        HStack(spacing: 14) {
            pulsingGreenCircle

            VStack(alignment: .leading, spacing: 2) {
                Text("System Active")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.yellow.opacity(0.9))
                Text("\(panelsOnline) / \(totalPanels) panels online")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.white.opacity(0.45))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text(String(format: "%.1f", outputKW))
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                    Text("kW")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.white.opacity(0.5))
                }
                Text("LIVE OUTPUT")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.white.opacity(0.35))
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(Color.yellow.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.yellow.opacity(0.15), lineWidth: 0.5)
        )
    }
    
    var pulsingGreenCircle: some View{
        ZStack {
            Circle()
                .fill(Color.green.opacity(0.3))
                .frame(width: 16, height: 16)
                .scaleEffect(pulsing ? 1.8 : 1.0)
                .opacity(pulsing ? 0 : 1)
            Circle()
                .fill(Color.green)
                .frame(width: 8, height: 8)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 2.0).repeatForever(autoreverses: false)) {
                pulsing = true
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        SystemActiveBanner(panelsOnline: 4, totalPanels: 5, outputKW: 3.2)
    }
    .preferredColorScheme(.dark)
}
