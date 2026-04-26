import SwiftUI
import Charts

struct TodayOverviewSection: View {
    let totalKWh: Double
    let targetKWh: Double
    let peakKW: Double

    let outputData: [(hour: Int, kwh: Double)]

//    var outputData: [(hour: Int, kwh: Double)] {
//        let currentHour = Calendar.current.component(.hour, from: Date())
//        let allHours = [0, 3, 6, 9, 12, 15, 18, 21, 23]
//        let curve: [Int: Double] = [
//            0: 0.0, 3: 0.0, 6: 0.4, 9: 2.1,
//            12: 3.6, 15: 3.2, 18: 1.8, 21: 0.3, 23: 0.0
//        ]
//        return allHours
//            .filter { $0 <= currentHour }
//            .map { h in (hour: h, kwh: curve[h] ?? 0.0) }
//    }

    var body: some View {
        VStack(spacing: 12) {
            SectionHeader(title: "TODAY'S OVERVIEW")

            VStack(spacing: 16) {
                chartTitle
                OverviewOutputChart(outputData: outputData)
            }
            .padding()
            .cardStyle()
        }
    }

    var chartTitle: some View {
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
                Text(String(format: "of %.1f kWh target", targetKWh))
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
    }
}

#Preview {
    ZStack {
        Color.appBackground.ignoresSafeArea()
        ScrollView {
            TodayOverviewSection(totalKWh: 18.6, targetKWh: 24.0, peakKW: 3.8, outputData: [
                (0, 0.0), (3, 0.0), (6, 0.3), (9, 1.4),
                (12, 1.8), (15, 1.6)
            ])
                .padding(.horizontal, 20)
        }
    }
    .preferredColorScheme(.dark)
}
