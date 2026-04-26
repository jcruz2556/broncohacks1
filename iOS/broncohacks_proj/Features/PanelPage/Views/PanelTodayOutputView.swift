import SwiftUI
import Charts

struct PanelTodayOutputView: View {
    let totalKWh: Double
    let peakKW: Double
    let outputData: [(hour: Int, kwh: Double)]

    var body: some View {
        VStack(spacing: 12) {
            SectionHeader(title: "TODAY'S OUTPUT")

            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(alignment: .lastTextBaseline, spacing: 3) {
                            Text(String(format: "%.1f", totalKWh))
                                .font(.system(size: 36, weight: .bold))
                                .foregroundStyle(.white)
                            Text("kWh")
                                .font(.system(size: 16))
                                .foregroundStyle(Color.white.opacity(0.5))
                        }
                        Text("generated today")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.white.opacity(0.4))
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 3) {
                        HStack(alignment: .lastTextBaseline, spacing: 2) {
                            Text(String(format: "%.1f", peakKW))
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(.white)
                            Text("kW")
                                .font(.system(size: 13))
                                .foregroundStyle(Color.white.opacity(0.5))
                        }
                        Text("peak output")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.white.opacity(0.4))
                    }
                }

                OverviewOutputChart(outputData: outputData)
            }
            .padding()
            .cardStyle()
        }
    }
}

#Preview {
    ZStack {
        Color.appBackground.ignoresSafeArea()
        ScrollView {
            PanelTodayOutputView(
                totalKWh: 6.2,
                peakKW: 1.8,
                outputData: [
                    (0, 0.0), (3, 0.0), (6, 0.3), (9, 1.4),
                    (12, 1.8), (15, 1.6)
                ]
            )
        }
    }
    .preferredColorScheme(.dark)
}
