import SwiftUI

struct PanelAllListView: View {
    let panels: [Panel]
    @State private var selectedPanel: Panel? = nil

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                SectionHeader(title: "MY PANELS")

                VStack(spacing: 0) {
                    ForEach(panels) { panel in
                        PanelRow(
                            number: panel.id,
                            location: panel.location,
                            outputKW: panel.outputKW,
                            efficiencyPct: panel.efficiencyPct,
                            isOnline: panel.isOnline
                        ) {
                            selectedPanel = panel
                        }
                        if panel.id != panels.last?.id {
                            Divider().background(Color.white.opacity(0.08))
                        }
                    }
                }
                .cardStyle()
            }
        }
        .padding()
        .background(Color.appBackground)
        .scrollIndicators(.hidden)
        .navigationDestination(item: $selectedPanel) { panel in
            PanelPageView(panel: panel)
        }
    }
}

#Preview {
    NavigationStack {
        PanelAllListView(panels: Panel.mock)
            .background(Color.appBackground)
    }
    .preferredColorScheme(.dark)
}
