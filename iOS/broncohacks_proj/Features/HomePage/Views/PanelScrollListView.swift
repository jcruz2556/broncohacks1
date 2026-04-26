import SwiftUI

struct PanelScrollListView: View {
    let panels: [Panel]
    @State private var showAll = false
    @State private var selectedPanel: Panel? = nil

    var body: some View {
        VStack(spacing: 12) {
            SectionHeader(title: "MY PANELS", actionLabel: "See all") {
                showAll = true
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(panels) { panel in
                        PanelCard(
                            name: panel.name,
                            location: panel.location,
                            outputKW: panel.outputKW,
                            efficiencyPct: panel.efficiencyPct,
                            isOnline: panel.isOnline
                        ) {
                            selectedPanel = panel
                        }
                    }
                }
            }
        }
        .navigationDestination(isPresented: $showAll) {
            PanelAllListView(panels: panels)
        }
        .navigationDestination(item: $selectedPanel) { panel in
            PanelPageView(panel: panel)
        }
    }
}

#Preview {
    NavigationStack {
        ZStack {
            Color.black.ignoresSafeArea()
            PanelScrollListView(panels: Panel.mock)
        }
        .preferredColorScheme(.dark)
    }
}
