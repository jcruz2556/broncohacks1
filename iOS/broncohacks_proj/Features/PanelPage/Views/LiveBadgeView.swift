import SwiftUI

struct LiveBadgeView: View {
    @State private var pulsing = false
    @State private var currentTime = Date()

    var body: some View {
        HStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.3))
                    .frame(width: 14, height: 14)
                    .scaleEffect(pulsing ? 1.8 : 1.0)
                    .opacity(pulsing ? 0 : 1)
                Circle()
                    .fill(Color.green)
                    .frame(width: 7, height: 7)
            }
            Text("Live · \(timeString(from: currentTime))")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.green.opacity(0.15))
        .clipShape(Capsule())
        .onAppear {
            withAnimation(.easeOut(duration: 2.0).repeatForever(autoreverses: false)) {
                pulsing = true
            }
            Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                currentTime = Date()
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        LiveBadgeView()
    }
    .preferredColorScheme(.dark)
}
