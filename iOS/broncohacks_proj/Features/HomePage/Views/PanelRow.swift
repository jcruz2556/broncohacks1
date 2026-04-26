import SwiftUI

struct PanelRow: View {
    let number: Int
    let location: String
    let outputKW: Double
    let efficiencyPct: Int
    let isOnline: Bool
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.orange.opacity(0.12))
                        .frame(width: 40, height: 40)
                    Image(systemName: "square.grid.2x2.fill")
                        .font(.system(size: 17))
                        .foregroundStyle(.orange)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Array #\(number)")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white)
                    Text(location)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.white.opacity(0.4))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 3) {
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        Text(isOnline ? String(format: "%.1f", outputKW) : "—")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                        if isOnline {
                            Text("kW")
                                .font(.system(size: 11))
                                .foregroundStyle(Color.white.opacity(0.45))
                        }
                    }

                    HStack(spacing: 4) {
                        Circle()
                            .fill(isOnline ? Color.green : Color.red)
                            .frame(width: 5, height: 5)
                        Text(isOnline ? "\(efficiencyPct)% eff." : "Offline")
                            .font(.system(size: 11))
                            .foregroundStyle(isOnline ? Color.green.opacity(0.8) : Color.red.opacity(0.7))
                    }
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.white.opacity(0.2))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack(spacing: 0) {
            PanelRow(number: 1, location: "Rooftop · South", outputKW: 1.6, efficiencyPct: 94, isOnline: true)
            Divider().background(Color.white.opacity(0.08))
            PanelRow(number: 4, location: "Rooftop · East", outputKW: 0.0, efficiencyPct: 0, isOnline: false)
        }
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 20)
    }
    .preferredColorScheme(.dark)
}
