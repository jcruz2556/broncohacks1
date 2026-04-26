import SwiftUI

struct EnergyFlowView: View {
    let solarKW: Double
    let coveragePct: Int

    var body: some View {
        VStack(spacing: 12) {
            SectionHeader(title: "ENERGY FLOW")

            VStack(spacing: 16) {
                HStack(spacing: 0) {
                    CircleIconNode(
                        icon: "sun.max.fill",
                        iconColor: .orange,
                        label: "Solar"
                    )

                    FlowingLine(solarKW: solarKW)

                    CircleIconNode(
                        icon: "house.fill",
                        iconColor: .blue,
                        label: "Home"
                    )
                }

                coverageBar
            }
            .padding()
            .cardStyle()
        }
    }

    var coverageBar: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Solar coverage")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.white.opacity(0.4))
                Spacer()
                Text("\(coveragePct)%")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.orange)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.orange)
                        .frame(width: geo.size.width * CGFloat(coveragePct) / 100, height: 6)
                }
            }
            .frame(height: 6)
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        EnergyFlowView(solarKW: 3.2, coveragePct: 78)
            .padding(.horizontal, 20)
    }
    .preferredColorScheme(.dark)
}
