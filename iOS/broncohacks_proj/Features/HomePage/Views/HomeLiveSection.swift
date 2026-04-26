//
//  HomeLiveSection.swift
//  broncohacks_proj
//
//  Created by Kenneth Sieu on 4/26/26.
//

import SwiftUI

struct HomeLiveSection: View {
    let data: HouseStatus

    var body: some View {
        SystemActiveBanner(
            panelsOnline: data.onlinePanelCount,
            totalPanels: data.panels.count,
            outputKW: data.totalOutputKW
        )
        EnergyFlowView(
            solarKW: data.totalOutputKW,
            coveragePct: data.coveragePct
        )
        PanelScrollListView(panels: data.panels)
        AIInsightsView()
        TodayOverviewSection(
            totalKWh: data.totalOutputKW,
            targetKWh: 24.0,
            peakKW: data.panels.map { $0.outputKW }.max() ?? 0,
            outputData: [
                (0, 0.0), (3, 0.0), (6, 0.3), (9, 1.4),
                (12, 1.8), (15, 1.6)
            ]
        )
    }
}

//#Preview {
//    HomeLiveSection()
//}
