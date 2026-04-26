import SwiftUI
import Charts

struct OverviewOutputChart: View {
    let outputData: [(hour: Int, kwh: Double)]

    var body: some View {
        Chart(outputData, id: \.hour) { point in
            AreaMark(
                x: .value("Hour", point.hour),
                y: .value("kWh", point.kwh)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [Color.orange.opacity(0.35), Color.orange.opacity(0.0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .interpolationMethod(.catmullRom)

            LineMark(
                x: .value("Hour", point.hour),
                y: .value("kWh", point.kwh)
            )
            .foregroundStyle(Color.orange)
            .lineStyle(StrokeStyle(lineWidth: 2))
            .interpolationMethod(.catmullRom)
        }
        .chartXScale(domain: 0...23)
        .chartXAxis {
            AxisMarks(values: [0, 6, 12, 18, 23]) { value in
                AxisValueLabel {
                    if let hour = value.as(Int.self) {
                        Text(hourLabel(from:hour))
                            .font(.system(size: 10))
                            .foregroundStyle(Color.white.opacity(0.35))
                    }
                }
            }
        }
        .chartYAxis(.hidden)
        .frame(height: 90)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        OverviewOutputChart(outputData: [
            (0, 0.0), (3, 0.0), (6, 0.4), (9, 2.1),
            (12, 3.6), (15, 3.2), (18, 1.8)
        ])
        .padding()
    }
    .preferredColorScheme(.dark)
}
