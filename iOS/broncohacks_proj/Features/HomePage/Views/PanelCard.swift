import SwiftUI

struct PanelCard: View {
    // MARK: Data Shared With Me
    let name: String
    let location: String
    let outputKW: Double
    let efficiencyPct: Int
    let isOnline: Bool
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 9)
                            .fill(Color.orange.opacity(0.12))
                            .frame(width: 34, height: 34)
                        Image(systemName: "square.grid.2x2.fill")
                            .font(.system(size: 15))
                            .foregroundStyle(.orange)
                    }
                    Spacer()
                    HStack(spacing: 4) {
                        Circle()
                            .fill(isOnline ? Color.green : Color.red)
                            .frame(width: 6, height: 6)
                        Text(isOnline ? "Online" : "Offline")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(isOnline ? Color.green : Color.red)
                    }
                }
                .padding(.bottom, 10)

                Text("\(name)")
                    .font(.system(size: 14))
                    .foregroundStyle(.white)
                Text(location)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.white.opacity(0.4))
                    .padding(.bottom, 12)

                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text(isOnline ? String(format: "%.1f", outputKW) : "—")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(.white)
                    if isOnline {
                        Text("kW")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.white.opacity(0.45))
                    }
                }
                .padding(.bottom, 2)

                Text(isOnline ? "\(efficiencyPct)% efficiency" : "No output")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(isOnline ? Color.green.opacity(0.8) : Color.red.opacity(0.6))
                    .padding(.bottom, 10)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.white.opacity(0.08))
                            .frame(height: 3)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.orange)
                            .frame(width: geo.size.width * CGFloat(efficiencyPct) / 100, height: 3)
                    }
                }
                .frame(height: 3)
            }
            .padding()
            .frame(width: 150)
            .cardStyle()
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        HStack(spacing: 12) {
            PanelCard(name: "1", location: "Rooftop · South", outputKW: 1.6, efficiencyPct: 94, isOnline: true)
            PanelCard(name: "4", location: "Rooftop · East", outputKW: 0.0, efficiencyPct: 0, isOnline: false)
        }
        .padding()
    }
    .preferredColorScheme(.dark)
}
