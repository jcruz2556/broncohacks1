import SwiftUI

struct FlowingLine: View {
    let solarKW: Double
    @State private var flowing = false

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 0) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.orange.opacity(0.2))
                            .frame(height: 3)

                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.orange.opacity(0),
                                        Color.orange,
                                        Color.orange.opacity(0)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * 0.4, height: 3)
                            .offset(x: flowing ? geo.size.width : -geo.size.width * 0.4)
                            .animation(
                                .linear(duration: 2.0).repeatForever(autoreverses: false),
                                value: flowing
                            )
                    }
                    .clipped()
                }
                .frame(height: 2)

                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.orange)
            }

            VStack(spacing: 2) {
                Text("Generating")
                    .font(.system(size: 10))
                    .foregroundStyle(Color.white.opacity(0.4))
                Text(String(format: "%.1f kW", solarKW))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.orange.opacity(0.8))
            }
        }
        .onAppear { flowing = true }
    }
}
