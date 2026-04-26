import SwiftUI

struct ControlsStatusView: View {
    let panel: Panel

    var body: some View {
        VStack(spacing: 12) {
            
            SectionHeader(title: "CONTROL & STATUS")

            VStack(spacing: 6) {
                StatusRow(
                    icon: "bolt.fill",
                    iconColor: .orange,
                    title: "Energy generated",
                    subtitle: String(format: "%.1f kW current output", panel.outputKW),
                    value: nil,
                    valueColor: .white,
                    showProgress: true,
                    progress: min(1.0, panel.outputKW / (panel.maxOutputW / 1000))
                )
                
                Divider().background(Color.white.opacity(0.08))
                
                let sensors = panel.sensors ?? []
                    
                ForEach(Array(sensors).enumerated(), id:\.offset) { index, sensor in
                    StatusRow(
                        icon: "sensor.tag.radiowaves.forward.fill",
                        iconColor: sensor.isOnline ? .green : .red,
                        title: "Sensor #\(index + 1)",
                        subtitle: sensor.isOnline ? String(format: "%.1f W output", sensor.outputW) : "No signal",
                        value: sensor.isOnline ? "Online" : "Offline",
                        valueColor: sensor.isOnline ? .green : .red,
                        showProgress: false
                    )
                    if index < sensors.count - 1 {
                        Divider().background(Color.white.opacity(0.08))
                    }
                }
            }
            .padding()
            .cardStyle()
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        ControlsStatusView(panel: Panel.mock[1])
    }
    .preferredColorScheme(.dark)}
