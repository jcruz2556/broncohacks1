import SwiftUI

struct PanelHeroView: View {
    let panel: Panel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            header

            VStack{
                LiveBadgeView()
                    .padding(.bottom, 8)
                SolarPanelView(sensors: panel.sensors ?? [], panelIsOnline: panel.isOnline)
            }
            
            HStack(spacing: 0) {
                statItem(value: panel.isOnline ? String(format: "%.1f", panel.outputKW) : "—", unit: panel.isOnline ? "kW" : nil, label: "OUTPUT")
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 0.5, height: 36)
                statItem(value: panel.isOnline ? "\(panel.efficiencyPct)" : "—", unit: panel.isOnline ? "%" : nil, label: "EFFICIENCY")
            }
            .padding(.vertical, 14)
        }
    }
    
    var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("\(panel.name)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                Text(panel.location)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.white.opacity(0.4))
            }
            Spacer()
            HStack(spacing: 5) {
                Circle()
                    .fill(panel.isOnline ? Color.green : Color.red)
                    .frame(width: 7, height: 7)
                Text(panel.isOnline ? "Online" : "Offline")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(panel.isOnline ? Color.green : Color.red)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background((panel.isOnline ? Color.green : Color.red).opacity(0.12))
            .clipShape(Capsule())
        }
    }
    
    @ViewBuilder
    private func statItem(value: String, unit: String?, label: String) -> some View {
        VStack(spacing: 4) {
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                if let unit {
                    Text(unit)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.white.opacity(0.5))
                }
            }
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.4))
                .kerning(1.2)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        ScrollView {
            PanelHeroView(panel: Panel.mock[0])
                .padding(.top, 20)
                .padding(.horizontal, 20)
        }
    }
    .preferredColorScheme(.dark)
}
