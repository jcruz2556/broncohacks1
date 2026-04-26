import SwiftUI

struct AIInsightsView: View {
    var body: some View {
        VStack(spacing: 12) {
            SectionHeader(title: "AI INSIGHTS")

            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.purple.opacity(0.15))
                            .frame(width: 38, height: 38)
                        Image(systemName: "sparkles")
                            .font(.system(size: 16))
                            .foregroundStyle(.purple)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Solar Summary")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                        Text("Powered by Claude")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.white.opacity(0.35))
                    }
                }

                Divider().background(Color.white.opacity(0.08))

                Text("Your solar system is running at 78% efficiency with 3 of 4 panels online. Panel #4 is offline — check connections. You're on track to hit your 24 kWh daily target by 6 PM.")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.white.opacity(0.85))
                    .lineSpacing(4)
            }
            .padding()
            .cardStyle()
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.purple.opacity(0.2), lineWidth: 0.5)
            )
        }
    }
}

#Preview {
    ZStack {
        Color.appBackground.ignoresSafeArea()
        AIInsightsView()
    }
    .preferredColorScheme(.dark)
}
