import SwiftUI

struct SolarPanelView: View {
    let rows = 2
    let cols = 2
    let sensors: [SensorState]
    let panelIsOnline: Bool

    var body: some View {
        VStack(spacing: 8) {
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(0..<cols, id: \.self) { col in
                        let index = row * cols + col
                        let isOnline: Bool = index < sensors.count ? sensors[index].isOnline : panelIsOnline
                        SinglePanel(isOnline: isOnline)
                    }
                }
            }
        }
        .padding(20)
        .padding(.horizontal, 24)
        .shadow(color: Color.orange.opacity(0.12), radius: 20, x: 0, y: 8)
        .cardStyle()
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        SolarPanelView(sensors: Panel.mock[0].sensors ?? [], panelIsOnline: true)
            .frame(width: 280)
    }
    .preferredColorScheme(.dark)
}
