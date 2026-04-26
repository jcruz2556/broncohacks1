import Foundation

struct HouseStatus: Codable {
    let house: House
    let panels: [Panel]

    var totalOutputKW: Double {
        panels.map { $0.outputKW }.reduce(0, +)
    }

    var onlinePanelCount: Int {
        panels.filter { $0.isOnline }.count
    }

    var totalPanelCount: Int {
        panels.count
    }

    var averageEfficiency: Int {
        let online = panels.filter { $0.isOnline }
        guard !online.isEmpty else { return 0 }
        return online.map { $0.efficiencyPct }.reduce(0, +) / online.count
    }

    var coveragePct: Int {
        // assumes ~3kW average home usage — swap with real data later
        min(100, Int((totalOutputKW / 3.0) * 100))
    }

    var allOnline: Bool {
        panels.allSatisfy { $0.isOnline }
    }
}
